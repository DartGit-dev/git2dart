---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
agent: agente-3
role: solver
engine: local
round: 0
status: ok
started_at: 2026-08-21T09:54:00+07:00
finished_at: 2026-08-21T10:05:00+07:00
---

# Strategy

Add one internal generic scope helper to `RemoteCallbacks`, tentatively
`withCallbacks<T>`. It accepts an initialized `git_remote_callbacks` value,
the Dart `Callbacks`, and a synchronous operation closure. Its complete control
flow is:

```dart
try {
  plug(callbacksOptions: callbacksOptions, callbacks: callbacks);
  return operation();
} finally {
  reset();
}
```

Migrate remote connect/fetch/push, repository clone, and submodule update/clone
to it, removing their standalone `plug` and `reset` calls. Repository clone
must assign `remoteCbData` and `repositoryCbData` inside the operation closure,
so partial clone setup is covered too.

Keep each native call immediately followed by `checkErrorAndThrow(error)`
inside the closure. Thus `LibGit2Error` is constructed from
`git_error_last()` before unwinding reaches cleanup. `reset` must remain free
of libgit2 calls in this repair. It is already idempotent because it only
assigns null; test that property and make the helper the single reset owner.
This changes neither exports nor ABI.

# Proposed root cause

Cleanup capability exists, but duplicated sequencing is unsafe. Remote
connect/fetch/push and repository clone call `checkErrorAndThrow` before reset,
so native failure skips cleanup. Submodule update/clone reset before error
translation, but still skip reset if callback setup or invocation throws a
Dart exception. Reordering six sites independently would fix only observed
native-error exits and remain drift-prone. One lexical `try/finally` scope
covers success, native error, and any Dart error reaching the call frame.

# Test

Use only synthetic values and run these tests serially because callback state
is process-static.

1. In `test/remote_test.dart`, adapt the restricted reproduction with
   `synthetic-user`, `synthetic-password`, and
   `http://127.0.0.1:1/repository.git`. Assert fetch throws
   `LibGit2Error`, then assert every `RemoteCallbacks` field is null. Current
   code fails on `credentials`. Keep defensive test teardown reset so a red run
   cannot contaminate later tests.
2. Unit-test the helper with arena-initialized callbacks: a closure returning a
   sentinel preserves its result and clears state; a closure throwing a
   specific `StateError` rethrows the identical object and clears state. Call
   `reset()` twice afterward and verify state remains clear.
3. Install a progress callback that throws a sentinel and invoke its bridge
   directly inside the helper. Verify the same Dart error and null state. This
   proves lexical callback-error cleanup without claiming full native
   trampoline characterization.
4. Add deterministic family checks: loopback fetch failure, loopback repository
   clone failure into a temporary directory, and the existing submodule failure
   fixture. Add a null-state assertion to one existing local success operation.
   This verifies all migrated families without live services or credentials.
5. Run formatting, focused remote/repository/submodule tests,
   `flutter analyze`, and full `flutter test`.

For the native failure, also assert a nonempty translated diagnostic after
cleanup. That guards both error preservation and exception type.

# Spec impact

No specification edit is needed. The change implements FR-NP-03, FR-NP-05,
FR-NP-08, FL-NP-06, EC-NP-10, and EC-NP-14. It characterizes synchronous Dart
cleanup only; EC-NP-15's native-trampoline exception gap remains explicit.
The helper stays under `lib/src/bindings`; no public Dart API, generated
declaration, native symbol, layout, or ABI changes.

# Risks and side effects

- Process-static concurrency/reentrancy remains unsolved; do not add locks,
  zones, depth counters, or registries. That is EC-NP-16's separate defect.
- Do not free `callbacksOptions.payload` here. Its unmanaged ownership is the
  separate confirmed credential-allocation defect; combining it would expand
  scope and risk double-free. This repair clears Dart reachability only.
- Put both repository clone callback-data assignments inside helper scope.
- Remove all migrated standalone resets. Although reset is currently
  idempotent, one structural owner protects future cleanup changes.
- Preserve connect's current successful lifetime: cleanup still occurs when
  `git_remote_connect` returns, not at disconnect.
- Direct bridge testing does not close the broader EC-NP-15 runtime gap.

# Evidence

- The reproduction records retained state in 3/3 failed fetches and observes
  non-null `RemoteCallbacks.credentials` after `LibGit2Error`.
- `remote.dart:395-411`, `499-514`, and `551-560`, plus
  `repository.dart:196-224`, place reset after error translation.
- `submodule.dart:120-132` and `243-252` reset without `finally`.
- `remote_callbacks.dart:250-316` already centralizes plug/null-reset, making it
  the narrowest helper location.
- Requirements lines 32-37, flows lines 67-73, edge cases lines 16-22, and
  ADR-003 require deterministic temporary cleanup, callback lifetime
  containment, immediate error translation, and separation of concurrency.

# Confidence

High (0.91). The failing edge and reproduction are direct, and one internal
`try/finally` removes duplicated sequencing with minimal reversible edits.
Residual uncertainty is limited to explicitly out-of-scope native callback
exception behavior and static overlap.
