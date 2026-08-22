---
protocol_version: 1
debate_id: BUG-20260817-ZC7X-repair-20260821
bug_id: BUG-20260817-ZC7X
role: solver
solver_id: agent-3
engine: local
round: 0
status: ok
started_at: 2026-08-21T23:05:00+07:00
finished_at: 2026-08-21T23:19:20+07:00
---

## Fix strategy

Use one internal lease abstraction, but give each lease the narrowest lifetime that is safe. The native reference count, rather than an isolate local Dart singleton, remains the cross isolate coordinator.

1. Add a private runtime lease in the hand written binding layer. Acquiring it calls `git_libgit2_init()`, checks the returned value, and throws `LibGit2Error` on a negative result. Releasing it is idempotent and calls `git_libgit2_shutdown()` exactly once. No generated declaration or companion binary change is needed because the reproduction already compiles and calls both native functions.
2. Replace pure, non persistent operations with a call scoped helper that acquires the lease, executes the operation, and releases the lease in `finally`. This applies to read only runtime queries such as version and features and to stateless operations such as `Merge.file`. It must not be applied mechanically to process global setters because shutdown may tear down or reset the state that the setter was intended to preserve.
3. Give every independently usable wrapper that owns a native handle a lifetime lease. Acquire before creating the native handle, release immediately if construction fails, and otherwise store the lease in the same finalizer token as the pointer. Explicit `free()` must destroy the native handle first, detach the finalizer, and then release the lease. The fallback finalizer must perform the same order. This includes the currently initializing constructors in `Repository`, `Config`, `Mailmap`, `Diff`, `Odb`, `Patch`, and `Signature`, and it requires an ownership audit of other finalizer backed wrappers that can outlive the object from which they were obtained. A partial conversion is unsafe because an unleased child could survive after the last leased repository is freed.
4. Treat long lived process global configuration and platform bootstrap as an explicit runtime scope, not as a call scoped operation. Android certificate configuration in particular must remain valid after `PlatformSpecific.initialize()` returns. The scope should own exactly one lease and should be idempotently closable only after its dependent wrappers are released. Repeated platform initialization should reuse the same scope instead of incrementing the native count.
5. Do not expose a raw public `Libgit2.shutdown()` that blindly decrements process global state. Such an API can release a lease it does not own, can be called while wrappers are live, and cannot validate other isolates through isolate local static state. If callers need an application lifetime boundary for persistent global options, expose an opaque `Libgit2Runtime` owner returned by initialization, with `close()` releasing only that owner's lease once. That scoped owner is safer than a general shutdown command. If persistent options can be owned entirely by an existing application lifecycle object, no new public shutdown API is necessary.

This is larger than adding a single shutdown call, but it is the smallest coherent repair that both balances the confirmed increments and avoids premature global teardown.

## Causa raiz proposta

The confirmed cause is ownership ambiguity, not merely a missing function call. Sixty six public entry points independently increment the process global libgit2 reference count, ignore initialization failure, and assign no owner to the increment. The package therefore has no safe point at which it can decrement the count. Adding shutdown to arbitrary `free()` methods or after every call would trade the leak for premature teardown, especially for derived wrappers, process global settings, and platform initialization.

## Teste

Add focused native count regression tests around the existing probe.

1. Repeated `Libgit2.version`, features, and a stateless operation leave the observed count unchanged after each call.
2. A standalone owned wrapper raises the count while live and restores the baseline after explicit `free()`.
3. Constructor failure restores the baseline and surfaces the original native failure. A test seam for the private initializer should also prove that a negative initialization result throws and does not call shutdown.
4. Double close of a lease does not decrement twice. A public scoped runtime owner, if added, must have positive close coverage and negative close while dependents remain live coverage.
5. A child wrapper remains usable after its repository wrapper is released, and the native count returns to baseline only after the child is also released. This discriminates a complete ownership repair from a dangerous root only repair.
6. While one wrapper lease is live, a temporary global query does not reduce the native count below the wrapper's lease.
7. Two isolates acquire independent leases. Releasing one isolate's lease leaves the other usable and does not drive the process global count to zero.
8. Repeated Android and iOS initialization is idempotent. Android CA configuration remains effective for a later TLS operation, and the retained platform scope can be closed only after dependent work ends.
9. Run formatting, zero warning analysis, the full Flutter test suite, and native platform smoke tests on Windows, Linux, macOS, Android, and iOS. Add sanitizer or allocator instrumentation when available to cover destructor before shutdown ordering.

## Impacto sobre a spec

The strategy implements FR NP 01 by making initialization and shutdown an owned pair and FR NP 05 by giving each native lifetime one destructor path. FL NP 02 should gain a runtime lease state alongside handle ownership: acquired, retained by calls or wrappers, released after native destruction, and closed once. The test specification should add count stability, initialization failure, constructor rollback, parent and child lifetime, multiple isolate, and platform scope scenarios.

An addendum should clarify that process global option changes require a live runtime scope and that a shutdown operation must release only a scope owned by the caller. This is a clarification of the existing requirements, not a generated FFI or ABI change.

## Riscos e efeitos colaterais

The main risk is premature shutdown caused by incomplete wrapper classification. Every finalizer backed owner that may outlive its parent must either own a lease or retain a shared parent lease before shutdown is introduced.

Finalizer and explicit free paths can race or double release unless the finalizer token carries both destruction and one shot lease state. Destruction must happen before shutdown.

Call scoping process global setters may erase or invalidate configuration. Libgit2 global shutdown registers settings cleanup, so option methods and Android certificate bootstrap require characterization and a retained scope.

Dart static variables are isolate local. They may optimize repeated acquisition within one isolate, but they must not be treated as the authority for process global native lifetime. Native reference counts owned by opaque leases remain safe across isolates.

A new public runtime owner adds documentation and positive and negative test obligations. It is still safer than a raw public shutdown, but it should be added only for the persistent configuration boundary, not as a shortcut for internal ownership.

The ownership audit touches more files than a one line shutdown patch. The change remains reversible because it is centralized behind one private lease abstraction and does not alter generated declarations or native artifacts.

## Evidence

* `bug.md` records 66 initialization calls, zero package shutdown calls, and high change risk.
* `evidence/reproduction.md` and `evidence/reproduction_test.dart` show deterministic native count growth from 2 to 3 to 4 after two `Libgit2.version` calls.
* `evidence/root-cause.md` confirms the unowned, reference counted lifecycle as the causal path.
* `lib/src/libgit2.dart` contains the repeated global query and option initialization sites.
* `lib/src/repository.dart`, `config.dart`, `mailmap.dart`, `diff.dart`, `odb.dart`, `patch.dart`, and `signature.dart` show native owning constructors with explicit and finalizer release paths.
* `lib/src/platform_specific.dart` uses `Libgit2.version` before Android CA setup and for iOS symbol loading, proving that platform bootstrap needs deliberate lifetime treatment.
* `reversa/sdd/native-runtime-and-platform-boundary/requirements.md` defines FR NP 01 and FR NP 05.
* `reversa/sdd/native-runtime-and-platform-boundary/flows.md` defines explicit and fallback native release and the Android and iOS initialization flows.
* `reversa/sdd/native-runtime-and-platform-boundary/tests.md` identifies repeated platform initialization, parent lifetime, injected failure, and cross platform execution as required gaps.
* The official libgit2 initialization and shutdown references state that initialization is reference counted and requires matching shutdown calls, while cleanup occurs only after all outstanding initializations are released.

## Confidence

High. The deterministic reproduction and official native contract prove the leak, and the proposed lease boundaries directly match call, object, and application lifetimes. Confidence is not absolute because process global option persistence and the complete parent to child wrapper graph still require dynamic characterization before source edits.
