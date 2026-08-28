---
protocol_version: 1
debate_id: BUG-20260817-ZC7X-repair-20260821-r0
bug_id: BUG-20260817-ZC7X
role: solver
solver_id: agent-1
engine: local
round: 0
status: ok
started_at: 2026-08-21T23:17:54+07:00
finished_at: 2026-08-21T23:18:22+07:00
---

## Fix strategy

Introduce one private `_Libgit2Runtime` state machine per Dart isolate and route every current direct `git_libgit2_init()` call through `ensureInitialized()`. The first use in an isolate acquires exactly one native initialization lease. Later calls in that isolate reuse it. A negative initialization result must be translated immediately with the existing libgit2 error path, and the manager must remain uninitialized so a later call may retry.

Expose one documented, idempotent `Libgit2.shutdown()` operation for normal isolate teardown. It should release at most the lease owned by the calling isolate. Calling it when the isolate has no lease is a no op. A successful native shutdown changes the isolate state back to uninitialized, so later use can start a new generation safely.

A boolean alone is insufficient because shutdown at native count zero while a wrapper is still live is unsafe. Add a private managed finalizer adapter around the existing `Finalizer` attach and detach pattern. The adapter should register each owned persistent native wrapper with `_Libgit2Runtime` when attached and unregister it only after its native destructor has run, whether through explicit `free()` or the existing fallback finalizer. Borrowed views and transferred ownership must follow their existing ownership classification rather than acquire an independent resource registration.

If `shutdown()` is requested while owned wrappers remain, do not call `git_libgit2_shutdown()`. Record a pending request and complete it exactly once after the last registered destructor finishes. A new initialization or resource acquisition before completion cancels that pending request, preserving compatibility and preventing a surprising shutdown during renewed use. Explicit `free()` remains the deterministic route; a Dart finalizer remains only a fallback.

This is the smallest coherent safe variant of the isolate lease strategy. The broad call site change is mechanical: replace the 66 direct increments in the nine affected source files with one manager call. The ownership change is centralized in the managed finalizer adapter so existing wrapper constructors and `free()` methods retain their present attach and detach structure. No generated declarations, native binaries, or platform loaders need to change.

Libgit2's own process global reference count coordinates isolates. Each participating isolate owns one native increment, not one increment per wrapper or operation. If isolates A and B are active, A's shutdown removes only A's lease; B's lease keeps the process global runtime initialized. Every isolate entry point that uses git2dart must request shutdown in a `finally` block before that isolate exits normally.

Do not use call scoped init and shutdown for pure global operations, because those calls share process global state and can coexist with persistent wrappers. Do not pair one native init with every wrapper, because that preserves high native counter churn and spreads lifecycle correctness across every constructor and finalizer. Do not use an ordinary Dart `Finalizer` to own the isolate lease itself: Dart does not guarantee that such a callback runs, and a static token is not collectible during normal isolate use.

## Causa raiz proposta

Confirmed root cause: 66 public entry points increment libgit2's process global initialization counter, no package path decrements it, and initialization return values are ignored. The repair must therefore replace per call increments with an owned lease, provide the matching decrement, and prevent that decrement from reaching zero before owned native wrappers have been destroyed.

## Teste

1. Adapt the reproduction into a fresh process or fresh isolate regression test. Probe the native count, call `Libgit2.version` twice and another global option, and prove the count increases only once. Request shutdown and prove the count returns to the baseline. A second shutdown must not decrement it again.
2. Create an owned wrapper such as `Config.empty()`. Request shutdown before `free()` and assert that shutdown is deferred, the native count is unchanged, and the wrapper remains usable. Free it explicitly and assert that its destructor runs before the one pending native shutdown restores the baseline.
3. Cover fallback cleanup separately, while avoiding a timing assertion that assumes Dart finalizers must run. The deterministic acceptance test must use explicit `free()`.
4. Use two coordinated isolates. Hold both after their first git2dart call and prove the process count has two additional leases. Shut down the first isolate, then prove the second can still use libgit2 and one lease remains. Shut down the second and prove the original baseline is restored.
5. Exercise shutdown followed by reuse in one isolate. The next API call must acquire one new lease, and a final shutdown must balance only that generation.
6. Add an internal injectable lifecycle adapter test in which initialization returns a negative result. Assert that a `LibGit2Error` is surfaced, no active state is cached, and a subsequent successful attempt can initialize.
7. Keep the existing `PlatformSpecific.initialize()` tests and add repeated bootstrap coverage so Android certificate setup and iOS eager symbol resolution use the same isolate lease without extra increments.
8. Run formatting, zero warning analysis, focused lifecycle tests, the full Flutter suite, and the declared Windows, Linux, macOS, Android, and iOS platform matrix.

## Impacto sobre a spec

The proposal implements FR-NP-01 by giving initialization and shutdown one explicit owner per isolate and implements FR-NP-05 by ordering wrapper destruction before lease release. It preserves FL-NP-02 because explicit free and fallback finalization still converge on one destructor path. The effective requirements do not need a verdict change.

The design and flow documentation should be clarified during the fix: the native runtime is process global, manager state is isolate local, libgit2's counter composes isolate leases, early shutdown is deferred while owned wrappers exist, and normal isolate entry points are responsible for shutdown in `finally`. The test specification should add the repeated call, premature shutdown, reinitialization, and coordinated multi isolate scenarios.

## Riscos e efeitos colaterais

- The resource registry must cover every owned libgit2 wrapper, including wrappers constructed from internal pointers. Missing one creates a premature shutdown hole. An implementation audit against all existing finalizer attachments is mandatory.
- Destructor ordering is critical. The managed finalizer callback must run the native destructor first and decrement the live resource count second; otherwise the last release can shut down libgit2 before freeing its object.
- Existing repeated free and post free guards are not universal. The adapter must make its registration detach idempotent so duplicate detach attempts cannot underflow the live resource count, without claiming to solve every existing double free defect.
- Ordinary Dart finalizers are not guaranteed to execute. If callers omit explicit `free()`, a requested shutdown may remain deferred. This is safe against premature teardown but may retain one bounded isolate lease. Documentation must prefer explicit release.
- Abrupt isolate termination cannot be made fully balanced by an isolate local Dart static. A guaranteed exit callback would require a compatible native finalizer shim or a process coordinator, expanding the companion binaries and platform surface. That is not justified for the smallest repair. Normal isolate entry points must use `try` and `finally`; force killed isolates remain a documented residual limitation.
- Process global options already affect all isolates. This repair does not add serialization for option races and must not imply that it does.
- The manager must retain active state if native shutdown reports an error, so the caller can observe the failure and retry without silently losing ownership.

## Evidence

- `bug.md` records the confirmed causal path, high change risk, and acceptance criteria.
- `evidence/static-analysis.md` and the fresh source scan record 66 initialization calls across `lib/src/libgit2.dart`, `config.dart`, `repository.dart`, `mailmap.dart`, `diff.dart`, `merge.dart`, `odb.dart`, `patch.dart`, and `signature.dart`, with zero package shutdown calls.
- `evidence/reproduction.md` and `evidence/reproduction_test.dart` show `Libgit2.version` moving the native count from 2 to 3 to 4 in one fresh process.
- `evidence/root-cause.md` confirms the missing paired lifecycle and the lack of a known good project commit.
- `lib/src/repository.dart:29-31`, `lib/src/repository.dart:438-440`, and `lib/src/repository.dart:945-947` demonstrate the existing constructor, explicit free, and fallback finalizer ownership boundary that can be wrapped centrally.
- `lib/src/config.dart:26-27`, `lib/src/config.dart:255-258`, and `lib/src/config.dart:277-279` show the same reusable ownership shape for wrappers produced from both public and internal pointers.
- `lib/src/platform_specific.dart` uses `Libgit2.version` for Android and iOS bootstrap, so transparent `ensureInitialized()` preserves that loading path.
- `reversa/sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements`, `flows.md#fl-np-02-explicit-and-fallback-release`, and `tests.md` require balanced runtime ownership, one destructor path, and repeated platform initialization coverage.
- The official libgit2 initialization and shutdown references define a process global, reference counted pair: https://libgit2.org/docs/reference/main/global/git_libgit2_init.html and https://libgit2.org/docs/reference/main/global/git_libgit2_shutdown.html. The official initialization guide recommends one pair around each worker lifetime: https://github.com/libgit2/libgit2#initialization.
- The Dart `Finalizer` contract explicitly does not guarantee callback execution, while `NativeFinalizer` requires a compatible native callback and still cannot cover abrupt process termination: https://api.dart.dev/dart-core/Finalizer-class.html and https://api.dart.dev/dart-ffi/NativeFinalizer-class.html.

## Confidence

High. The strategy directly removes the observed per call increments, uses libgit2's native reference count for cross isolate coordination, and makes premature shutdown fail safe by deferring it behind existing ownership release points. Residual uncertainty is confined to auditing every owned wrapper and to abrupt isolate termination, which the proposal identifies rather than hiding.
