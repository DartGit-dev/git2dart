---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
agent: agente-2
role: solver
engine: local
round: 0
started_at: 2026-08-21T10:02:48+07:00
finished_at: 2026-08-21T10:03:32+07:00
status: ok
---

# Strategy

Add one internal synchronous lifecycle method to `RemoteCallbacks`, for example `withCallbackState<T>`. Its `try` begins before `plug`, covering partial installation, and its only `finally` action is `reset`:

```dart
static T withCallbackState<T>({
  required git_remote_callbacks callbacksOptions,
  required Callbacks callbacks,
  required T Function() operation,
}) {
  try {
    plug(callbacksOptions: callbacksOptions, callbacks: callbacks);
    return operation();
  } finally {
    reset();
  }
}
```

Route all six callback-bearing operations through it: remote `connect`, `fetch`, and `push`; repository `clone`; and submodule `update` and `clone`. Remove their manual `reset` calls. Keep each native call and its immediate `checkErrorAndThrow(error)` inside `operation`. Repository clone also installs `remoteCbData` and `repositoryCbData` there before `git_clone`.

Never move `checkErrorAndThrow` after `withCallbackState` or into `finally`. `LibGit2Error` must be constructed from current `git_error_last()` first; unwinding then performs the pure-Dart reset.

Keep `reset` as null assignments. Do not save prior static values, add locks, introduce zone/isolate state, or alter callback payload allocation. One lifecycle method makes cleanup structurally single-shot; `reset` remains idempotent.

# Proposed root cause

`RemoteCallbacks.plug` stores operation data in process-static fields. In remote `connect`, `fetch`, `push`, and repository `clone`, `checkErrorAndThrow` precedes trailing `reset`, so a negative native result bypasses cleanup. Submodule `update` and `clone` reset before translation but still lack `finally`; a Dart exception can bypass cleanup. Repository clone can additionally retain its creation callback data.

The missing invariant is a lexical lifetime enclosing installation, later setup, the native call, immediate translation, and return preparation.

# Test

Use only non-secret sentinels and loopback/local fixtures:

1. In `remote_test.dart`, test `withCallbackState` with `using(Arena)` and `initCallbacks`: success returns a sentinel and clears state; a body throwing a pre-created `StateError` rethrows the identical object and clears state.
2. Convert the loopback fetch reproduction into the primary red-to-green native-failure test. Supply synthetic callback data, require `LibGit2Error` with its native diagnostic intact, then require cleared state without manual test cleanup.
3. Add a native-failure matrix: connect/fetch/push in `remote_test.dart`, repository clone in `repository_test.dart`, and submodule update/clone in `submodule_test.dart`. Each receives non-null callback data and fails through an existing invalid/local fixture or unused loopback port. Clone also sets both creation callback fields.
4. Extend one existing successful callback operation with the same postcondition. Keep network cases under existing tags; helper success/Dart-error cases stay local.

A shared assertion checks all eight static slots. Before the fix, loopback fetch leaves `credentials` reachable; afterward, success, native-error, and Dart-error cases pass. Run formatting, analysis, the three targeted test files serially, then the full suite.

# Spec impact

No effective specification change is required. This implements FR-NP-03/05/08, FL-NP-06, EC-NP-10/14, and ADR-003. Only EC-NP-15's cleanup aspect is narrowed; exception propagation remains a characterization gap. EC-NP-16 remains open. There is no public API or native ABI change.

# Risks and side effects

- The helper must remain synchronous; otherwise state may escape its lexical operation.
- Cleanup must stay non-native and non-throwing so it cannot mask the pending error.
- Callback payload allocation ownership is deliberately unchanged; it belongs to the related allocation defect.
- Static callback overlap remains unsafe. Saving/restoring state or serialization would expand into the concurrency defect.
- Loopback tests should assert stable error fields/non-empty diagnostics, not OS-specific full messages.

# Evidence

- `evidence/reproduction.md` and the restricted test establish retained state after failed fetch in 3/3 runs.
- `lib/src/bindings/remote.dart:395-411`, `499-514`, and `551-560` install static callback state, translate a negative native result, and reset only afterward.
- `lib/src/bindings/repository.dart:196-225` has the same ordering and also installs remote/repository creation callback data.
- `lib/src/bindings/submodule.dart:120-132` and `243-252` reset before error translation but have no exceptional-path guarantee.
- `remote_callbacks.dart` shows `plug` writes static slots and `reset` nulls them.
- The specification requires immediate error translation, deterministic cleanup, bounded callback lifetimes, and one cleanup path while retaining EC-NP-15/16 gaps.

# Confidence

High. It encloses the leak window from first state mutation through every exit, preserves error translation before cleanup, covers all six call sites, and leaves allocation ownership and concurrency unchanged.
