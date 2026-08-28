---
protocol_version: 1
role: candidate
candidate_id: C
status: ok
ordering: descending-sha256
content_hash: 9FBF5303969CAE6185979F807E7DF699EAB82D8441D99625E75BD4EA090BA435
---

# Candidate C

## Fix strategy

Use one native initialization lease per Dart isolate, protected by isolate-local logical ownership accounting for every independently usable wrapper that owns libgit2 state. This retains the smallest sound part of all three proposals while removing deferred automatic shutdown and per-call native lease churn.

Add a private `_Libgit2Runtime` with three states: uninitialized, active, and terminal. `ensureInitialized()` calls `git_libgit2_init()` only when uninitialized, checks the result before changing state, and immediately throws `LibGit2Error` on a negative result. Calls made while active reuse the same lease. Calls made after terminal shutdown throw `StateError` rather than silently recreating global state without rerunning platform bootstrap and process-global option setup.

Replace all 66 direct initialization calls with `ensureInitialized()`. Global queries, global options, constructors, and `Merge.file` therefore share one isolate lease. `PlatformSpecific.initialize()` may keep using `Libgit2.version`; it will load symbols and acquire the same lease without another increment.

Introduce one private, one-shot managed cleanup token for every independently usable owned native wrapper. The token contains the native destructor, its completion state, and one logical runtime owner. A successful native constructor attaches that token to the wrapper finalizer. Explicit `free()` and fallback finalization invoke the same token, so native destruction happens at most once and the logical owner is released only after destruction succeeds. Ownership transfer detaches and completes the prior token without running its destructor. Borrowed views do not acquire tokens; duplicated, copied, or derived owned objects that can outlive their parent do.

The ownership audit must cover all existing finalizer-backed wrappers, including wrappers constructed from internal pointers, not only constructors that currently call initialization. A child such as a commit, remote, patch, iterator, or write stream must keep shutdown blocked if it can remain independently usable after its parent is freed. Constructor and validation failures must leave no logical owner behind.

Add one documented, idempotent `Libgit2.shutdown()` as the terminal boundary for the calling isolate. If the isolate is already terminal, it is a no op. If any logical owner remains, it throws `StateError` and leaves both manager and native state unchanged. With zero owners, it calls `git_libgit2_shutdown()` exactly once; a negative result is surfaced and leaves the manager active, while success makes the manager terminal. It never runs automatically when the logical owner count reaches zero and never runs from a finalizer.

Terminal behavior is deliberate. Libgit2 shutdown can release process-global configuration, including state established by Android bootstrap and global option setters. Allowing transparent reinitialization, or automatically shutting down when the last wrapper disappears, could restore the counter while silently losing that configuration. A later requirement for multiple runtime epochs should introduce an explicit rebootstrap contract rather than weakening this repair.

Multiple isolates remain safe because the Dart state is not treated as process global. Every participating isolate contributes at most one native increment. Libgit2's native reference count is the process-wide coordinator, so one isolate's terminal shutdown removes only its lease while leases from other isolates keep the runtime alive. Each isolate that uses git2dart must call shutdown in a `finally` block before normal exit.

No generated declaration, companion binary, or platform loader change is required. The change is reversible because the lifecycle manager and cleanup token remain private, direct call sites are mechanical substitutions, and the only public addition is terminal `Libgit2.shutdown()` with its required documentation and tests.

## Causa raiz proposta

The confirmed root cause is an ownership mismatch. Sixty-six public entry points acquire reference-counted process-global initialization, ignore initialization failure, and assign no owner to the increment; no package path performs shutdown. A correct repair must both collapse those increments into defined leases and establish a shutdown point that cannot precede destruction of any independently live native wrapper.

## Teste

1. In a fresh process, probe the native count, call `Libgit2.version` repeatedly plus representative global queries and options, and prove the isolate contributes exactly one increment. With no owners, terminal shutdown must restore the baseline, and a second shutdown must not decrement again.
2. Inject a negative initialization result through an internal lifecycle test seam. Assert that `LibGit2Error` is surfaced, active state is not cached, and a later successful initialization can proceed.
3. Create an owned wrapper and call shutdown while it is live. Assert `StateError`, an unchanged native count, and continued wrapper usability. After explicit `free()`, shutdown must decrement exactly once.
4. Create a repository and an independently owned child, free the repository, and prove shutdown remains rejected until the child is freed. This detects an unsafe root-wrapper-only audit.
5. Cover a transferred owner such as a write stream. Transfer must not run the destructor, must release the prior logical owner exactly once, and must not permit a later finalizer to destroy transferred state.
6. Exercise constructor validation and native failure paths. They must surface the original error, register no live owner, and still permit terminal shutdown of the isolate lease.
7. Test the cleanup token directly for explicit release, fallback release, duplicate release, transfer, and an injected destructor failure. Unexpected destructor failure must fail closed by retaining the logical owner rather than allowing premature shutdown; finalizer callbacks must not throw.
8. Coordinate two isolates behind barriers. After both initialize, the process count must show two additional leases. Shutdown of the first must leave the second usable and one lease present. Shutdown of the second must restore the original baseline.
9. Verify repeated Android and iOS bootstrap does not add increments. Android CA and representative process-global settings must remain effective until terminal shutdown. Any API use after successful terminal shutdown must throw without a native call.
10. Run formatting, zero-warning analysis, focused lifecycle tests, the full Flutter suite, and the Windows, Linux, macOS, Android, and iOS platform matrix.

## Impacto sobre a spec

The strategy implements FR-NP-01 with one owned initialize and shutdown pair per isolate and strengthens FR-NP-05 by making runtime shutdown depend on the same explicit, fallback, and transfer ownership exits as native handles. It preserves FL-NP-02's destructor paths and adds the rule that native destruction precedes logical runtime-owner release.

The effective specification does not need a verdict change. Its design and flows should clarify the process-global native counter, isolate-local manager state, terminal shutdown, live-owner rejection, transfer semantics, and the responsibility of normal isolate entry points to shut down in `finally`. The test specification should add count stability, initialization failure, parent and child lifetime, transfer, premature shutdown rejection, terminal post-shutdown rejection, platform configuration retention, and multiple-isolate scenarios.

The sole public API addition, `Libgit2.shutdown()`, requires documentation plus positive and negative tests under the repository policy. No FFI or ABI surface change is needed because the locked reproduction already uses both generated lifecycle functions.

## Riscos e efeitos colaterais

- The largest risk is an incomplete ownership inventory. Missing one independently usable owned wrapper creates a premature shutdown hole; incorrectly retaining borrowed data can block shutdown forever.
- Existing finalizers use several pointer and transfer patterns. The managed cleanup token must be one shot, and native destruction must complete before logical release. Transfer must be distinct from free.
- Dart finalizers are nondeterministic and are not guaranteed to run. Therefore they may keep shutdown blocked; deterministic callers must explicitly free wrappers. This is safer than automatic native teardown.
- A force-killed or abruptly terminated isolate may fail to release its one native lease. Fixing that guarantee requires a compatible native finalizer shim or a process coordinator and would expand the binary and platform surface beyond the smallest repair. Normal isolate shutdown remains explicit.
- Terminal shutdown prevents reuse in the same isolate. This is conservative but avoids silent loss of Android CA and global option state. Multiple lifecycle epochs require a separate, specified rebootstrap API.
- Global options and callbacks remain process global and unsynchronized across isolates. This repair owns lifetime but does not claim to solve that existing concurrency gap.
- If native shutdown fails, clearing Dart state would lose ownership. The manager must remain active and surface the failure.

## Evidence

- `problema.md` locks the facts: 66 initialization calls, zero shutdown calls, process-global native state, isolate-local Dart statics, unsafe premature shutdown, platform bootstrap through `Libgit2.version`, and mandatory initialization-error propagation.
- the first prior proposal identifies the need for an isolate lease, complete wrapper registration, destructor-before-release ordering, multi-isolate tests, and the limitation of ordinary Dart finalizers.
- the second prior proposal adds the decisive terminal-shutdown rule, one-shot cleanup tokens, transfer handling, constructor rollback, parent-child tests, and preservation of Android and global-option state.
- the third prior proposal correctly separates persistent platform configuration from temporary calls and shows why blind public shutdown and partial wrapper conversion are unsafe.
- The locked evidence references `bug.md`, `evidence/static-analysis.md`, `evidence/reproduction.md`, `evidence/reproduction_test.dart`, and `evidence/root-cause.md`; the reproduction proves two `Libgit2.version` calls grow the count from 2 to 3 to 4.
- The locked effective specification references FR-NP-01, FR-NP-05, FL-NP-02, and the native-runtime test specification.
- The locked official contracts define the native pair: https://libgit2.org/docs/reference/main/global/git_libgit2_init.html and https://libgit2.org/docs/reference/main/global/git_libgit2_shutdown.html.

## Confidence

medium. The revised ownership model is coherent across repeated calls, persistent wrappers, platform configuration, and multiple isolates, but implementation safety still depends on a complete classification of every finalizer-backed ownership and transfer path plus the full platform test matrix.

## Critique of the other proposals

prior proposal Y provides the strongest refinement of the isolate-lease family. Its terminal shutdown avoids the configuration-loss bug in my round-0 deferred auto-shutdown, and its one-shot cleanup token, explicit transfer operation, constructor rollback, and parent-child tests close important ownership gaps. I adopt those elements. I reject only its suggestion that logical ownership be released in `finally` after an injected destructor failure: if destruction did not complete, releasing the last owner could permit unsafe shutdown. The safer failure mode is to retain the owner and keep shutdown blocked. Its broad audit is not optional, but that breadth is mechanical and still smaller than native per-wrapper leases.

prior proposal Z correctly warns that process-global setters and Android bootstrap cannot use a temporary call scope, and its opaque owner is safer than a blind decrementing function. However, the hybrid strategy introduces three ownership models: call-scoped native leases, per-wrapper native leases, and retained platform scopes. That multiplies native refcount transitions, failure paths, and classification decisions. It also does not fit the existing transparent static option API without either a public usage change or a hidden retained scope. A guarded isolate manager already owns a precise lease, so `Libgit2.shutdown()` releases only that isolate's lease and cannot decrement another isolate's ownership. The live-owner guard removes the raw-shutdown hazard with less API and less runtime churn. prior proposal Z's transfer, parent-child, and platform-retention concerns are nevertheless incorporated into the revised strategy and tests.

