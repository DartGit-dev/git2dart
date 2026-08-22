---
protocol_version: 1
debate_id: BUG-20260817-ZC7X-repair-20260821
bug_id: BUG-20260817-ZC7X
role: solver
solver_id: agent-2
engine: local
round: 0
status: ok
started_at: 2026-08-21T22:55:00+07:00
finished_at: 2026-08-21T23:20:05+07:00
---

## Fix strategy

Use one native libgit2 initialization lease per Dart isolate, protected by one
logical owner token per live Dart wrapper. Do not use one native
`git_libgit2_init()` increment per wrapper, and do not shut libgit2 down after
each pure global call. The literal per-wrapper/native-counter design is
coherent only if every current owned wrapper and transfer path is converted;
that would multiply native refcount operations and still require the same
ownership audit. A single native lease plus wrapper-level logical retains is
the smaller safe implementation of the same lifetime rule.

Add an internal `_Libgit2Runtime` state with these rules:

1. `ensureInitialized()` invokes `git_libgit2_init()` at most once in the
   isolate. It checks the returned value before marking the state initialized
   and throws `LibGit2Error` for a negative result.
2. A managed cleanup token represents each wrapper that owns native state or
   can continue calling libgit2 independently of its parent. The token records
   the destructor, increments the isolate's live-owner count, and is the value
   attached to the wrapper finalizer. Explicit `free()` detaches the finalizer
   and runs the same token exactly once. Finalization runs the destructor first
   and releases the logical runtime owner in `finally`.
3. Native ownership transfer has a separate token operation: detach without
   running the destructor, then release the logical owner. This is required for
   `BlobWriteStream.detach()` after `createFromStreamCommit`; treating transfer
   as `free()` would double-destroy the stream.
4. Replace the 66 direct initialization calls with the manager. The 47 calls
   in `Libgit2` and the call in `Merge.file` become idempotent runtime guards.
   The 18 calls in owning constructors acquire before the first native call,
   transfer the logical owner to the successful wrapper, and release it on
   every validation/native exception path.
5. Audit all ownership-producing constructors, not only the 18 constructors
   that currently call `git_libgit2_init()`. Current code has 39 `Finalizer`
   declarations across 30 files. Derived objects such as `Commit`, `Remote`,
   `Patch.fromDiff`, `Mailmap.fromRepository`, duplicate objects, iterators,
   and write streams can outlive the wrapper used to create them. Each
   independently usable owned result must receive its own logical token.
   Borrowed views that cannot outlive or call independently through their
   parent receive no token; copied/duplicated results do.
6. Add a documented, idempotent `Libgit2.shutdown()` as the only operation that
   releases the isolate's one native lease. It throws `StateError` without
   changing native state when live-owner count is nonzero. After successful
   shutdown the isolate runtime is terminal; later native API use fails with a
   clear `StateError`. This avoids silently losing Android CA and other global
   options through shutdown/reinitialization.
7. Do not automatically shut down when the owner count reaches zero. A
   transient zero between operations would reset process-global configuration.
   `PlatformSpecific.initialize()` may continue to bootstrap through
   `Libgit2.version`; that call now acquires only the isolate lease, and the
   Android certificate option remains active until explicit terminal shutdown.

This is cross-isolate coherent without pretending that a Dart static is
process-global: every isolate contributes at most one native initialization,
and libgit2's process-global native counter keeps other isolates alive when one
isolate shuts its own lease down.

## Causa raiz proposta

The confirmed cause is an ownership mismatch: 66 public entry points acquire
reference-counted native initialization, but no object, call scope, isolate, or
application lifecycle owns the matching shutdown. The current finalizers own
individual native pointers only; their payloads contain no runtime lease.

Pairing shutdown only with the 18 constructors that currently initialize would
be unsafe. For example, `Repository.free()` can release the repository lease
while a `Commit`, `Remote`, `Diff`, or other independently finalized child is
still live. Conversely, adding `try/finally` shutdown to every global setter
would allow the count to reach zero immediately after Android SSL setup and
could discard process-global configuration before the next repository call.

## Teste

1. Replace the reproduction assertion with a regression assertion: two or many
   `Libgit2.version` calls leave the native probe count unchanged after the
   first isolate lease is acquired; `Libgit2.shutdown()` restores exactly the
   pre-package count.
2. Add positive explicit-lifetime tests for representative owner families:
   repository, config, standalone object (`Diff.parse` or
   `Patch.fromBuffers`), and a child created from a repository. While a live
   owner exists, `Libgit2.shutdown()` must throw and the probe count must remain
   unchanged. After every owner is freed, shutdown must decrement exactly once.
3. Add the critical parent/child negative test: create a repository and a
   commit (or remote), free the repository, and verify shutdown is still
   rejected until the child is freed. This proves the implementation did not
   confuse a root wrapper lease with all descendant lifetimes.
4. Add a constructor-failure test using `Config.open` with a missing path and a
   native-failure path where practical. The failure must not leave a live-owner
   token, and terminal shutdown must still balance the one isolate lease.
5. Add transfer coverage for `BlobWriteStream`: successful stream commit must
   detach/transfer without calling the stream destructor twice and without
   retaining a logical owner.
6. Unit-test the internal runtime through an injected native adapter: negative
   init is surfaced as `LibGit2Error`, the initialized flag remains false,
   shutdown failure does not clear state, explicit cleanup is idempotent, and
   destructor failure still releases the logical owner.
7. Add a two-isolate barrier test. Both isolates initialize; one shuts down;
   the other continues a native operation and then shuts down. Probe deltas
   must show one balanced increment per isolate, never premature process-global
   teardown.
8. Run formatting, zero-warning analysis, the focused lifecycle suite, the
   full Flutter suite, and platform CI on Windows, Linux, macOS, Android, and
   iOS. Platform bootstrap tests must verify repeated initialization and that
   Android SSL configuration remains available until terminal shutdown.

## Impacto sobre a spec

This implements FR-NP-01 with a defined initialize/shutdown owner and strengthens
FR-NP-05 by making runtime ownership follow the same explicit/fallback release
boundary as native pointers. FL-NP-02 should state that an owned wrapper cleanup
first runs its native destructor and then releases its logical runtime owner;
transfer detaches both responsibilities from the prior wrapper without running
the destructor. The runtime test matrix should gain repeated-call, live-owner
shutdown rejection, parent/child lifetime, transfer, constructor-failure, and
multi-isolate scenarios.

The only public API addition is the documented terminal
`Libgit2.shutdown()`. It requires one positive test and at least one negative
test under the repository policy. No generated FFI declaration or companion
binary change is required because both lifecycle functions already exist in
the dependency API.

## Riscos e efeitos colaterais

- The ownership audit is the dominant risk. The 39 finalizer declarations and
  all constructors that create independently usable owned results must be
  classified. Missing one can permit premature shutdown; retaining a borrowed
  view unnecessarily can block shutdown.
- Dart finalization is nondeterministic. Therefore finalizers may delay an
  explicit shutdown, but they must never trigger shutdown automatically.
  Deterministic callers should use existing `free()` methods before shutdown.
- Cleanup ordering matters: native destructor before logical release, and
  init acquisition before any native constructor call. Reversing either order
  creates a zero-count native call window.
- `Config.open` currently initializes before a Dart file-existence exception;
  construction must use exception-safe acquisition or it will keep leaking on
  failure.
- Terminal shutdown is intentionally conservative. It avoids an Android or
  global-option reset on reinitialization, but applications that want multiple
  runtime epochs would need a later, separately specified platform rebootstrap
  API.
- Global options and callbacks remain process-global and unsynchronized across
  isolates. This proposal balances lifetime but does not close the existing
  concurrency gap in the effective specification.
- The change is broad but mechanical and reversible: the manager and managed
  finalizer adapter are internal, direct call sites remain recognizable, and
  no ABI or binary artifact changes.

## Evidence

- `bug.md`: confirmed 66 initialization calls, zero shutdown calls, and high
  change risk across wrappers, global calls, platform bootstrap, and isolates.
- `evidence/reproduction.md` and `evidence/reproduction_test.dart`: two
  `Libgit2.version` calls increased the observed count from 2 to 3 to 4.
- `evidence/root-cause.md`: confirms that every unmatched initialization
  permanently increases process-global native state.
- `lib/src/libgit2.dart:20-28`: a pure version query initializes on every call.
- `lib/src/repository.dart:29-31`, `lib/src/repository.dart:438-447`, and
  `lib/src/commit.dart:25-40`: repository and child wrappers have independent
  pointer finalizers, but no shared runtime lifetime.
- `lib/src/config.dart:47-60`: initialization precedes a Dart validation
  exception, proving failure-path balancing is required.
- `lib/src/blob.dart:93-99` and `lib/src/writestream.dart:45-61`: successful
  stream commit transfers ownership by detaching rather than freeing.
- `lib/src/platform_specific.dart:12-31`: Android and iOS bootstrap through
  `Libgit2.version`; Android then stores a process-global SSL option.
- `reversa/sdd/native-runtime-and-platform-boundary/requirements.md`: FR-NP-01
  requires initialization/shutdown and FR-NP-05 requires exactly one
  owner/destructor path.
- `reversa/sdd/native-runtime-and-platform-boundary/flows.md#fl-np-02-explicit-and-fallback-release`:
  explicit free, finalization, and transfer are distinct ownership exits.
- Official libgit2 contracts state that initialization is required before any
  other libgit2 call and that shutdown must be called as many times as init:
  https://libgit2.org/docs/reference/main/global/git_libgit2_init.html and
  https://libgit2.org/docs/reference/main/global/git_libgit2_shutdown.html.

## Confidence

medium — the one-native-lease/per-wrapper-logical-owner model is coherent with
the current API, platform bootstrap, and process-global native refcount, but the
repository's 39 finalizer declarations make an ownership inventory and
cross-platform validation mandatory before implementation can be considered
safe.
