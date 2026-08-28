---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
role: solver
solver_id: agente-1
engine: local
round: 1
status: ok
started_at: 2026-08-21T10:06:00+07:00
finished_at: 2026-08-21T10:07:27.3796254+07:00
---

# Strategy

Add one internal synchronous lexical-session primitive, `RemoteCallbacks.withCallbackState<T>`. Its `try` must begin before `plug`, and its `finally` must contain only `reset`:

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

This helper is the single cleanup owner; structural scoping makes double cleanup impossible at migrated call sites, while `reset` remains idempotent. Route exactly remote connect/fetch/push, repository clone, and submodule update/clone through it and remove their standalone resets. Keep the native call and its immediately following `checkErrorAndThrow(error)` inside `operation`, so `LibGit2Error` captures `git_error_last()` before unwinding performs pure-Dart cleanup. Put repository clone's `remoteCbData` and `repositoryCbData` assignments inside the same operation scope.

Do not change payload allocation, add concurrency guards, save/restore prior static values, or alter exports/ABI. The payload ownership defect belongs to BUG-20260817-47ZS and must remain a separate change set.

# Proposed root cause

Callback state installation has no lexical lifetime owner. Remote connect/fetch/push and repository clone translate native failure before a trailing reset, so throwing bypasses cleanup. Submodule update/clone reset before translation, but setup, callback, or native-call Dart errors can still bypass it. Repository clone separately installs creation callback data. Duplicated manual sequencing, not missing reset capability, is the confirmed O3B3 cause.

# Test

1. In `remote_test.dart`, directly exercise `withCallbackState` with arena-initialized callback options. Verify a successful closure returns its sentinel and clears all eight static slots. Verify a closure throwing a pre-created `StateError` rethrows the identical object and clears all slots.
2. Install a progress callback that throws a sentinel, invoke its bridge directly inside the helper, and assert identical-error propagation plus cleanup. This proves synchronous Dart-error cleanup without claiming characterization of exception propagation through a real FFI trampoline; EC-NP-15 remains open.
3. Adapt the existing three-run loopback fetch reproduction using only synthetic `UserPass` values and `127.0.0.1:1`. Assert `LibGit2Error`, a nonempty native diagnostic, and null callback state. Use defensive teardown reset so the intentionally red pre-fix run cannot contaminate later tests.
4. Add a compact family matrix: controlled callback-bearing native failures for connect/fetch/push, repository clone, and submodule update/clone in the three named test files. Reuse invalid/local fixtures where possible. Add the same null-state postcondition to one existing local successful callback operation. Tests remain serial because state is process-static.
5. Verify that each of the six native call plus error-check pairs is inside the helper scope. Run formatting, analysis, the three focused test files serially, then the full suite.

# Spec impact

No specification, public API, generated declaration, or ABI change. The repair implements deterministic state cleanup required by FR-NP-05/08, FL-NP-06, EC-NP-10/14, while preserving immediate native-error translation. FR-NP-03's callback payload allocation aspect remains tracked by 47ZS. EC-NP-15's native-trampoline behavior and EC-NP-16 concurrency remain explicit gaps.

# Risks and side effects

- `withCallbackState` must remain synchronous; an escaping future would outlive static state.
- `reset` must remain non-native and non-throwing so it cannot mask the pending native or Dart error.
- Do not free or re-home `callbacksOptions.payload` here. Folding 47ZS into O3B3 expands scope and creates double-free/duplicate-remediation risk.
- The helper does not serialize or isolate overlapping operations; process-static concurrency remains unsafe and out of scope.
- Clone callback-data assignments must be inside the lexical scope, and all old manual resets must be removed.
- Direct bridge testing proves cleanup only, not full FFI callback-exception semantics.

# Evidence

- The restricted reproduction observes retained credentials in 3/3 failed fetches.
- `remote.dart:395-411`, `499-514`, and `551-560`, plus `repository.dart:196-224`, place reset after error translation.
- `submodule.dart:120-132` and `243-252` reset without `finally`.
- `remote_callbacks.dart:250-316` already centralizes installation and pure-Dart null reset, making it the narrowest repair point.
- The frozen problem explicitly separates concurrency, requires immediate error capture, and accepts idempotent or structurally single-shot cleanup.

# Confidence

High (0.94). All solvers independently converged on the same lexical `try/finally` boundary and six call sites. Separating 47ZS reduces the O3B3 diff and regression surface without weakening proof of the confirmed retained-Dart-state defect.

# Critique of other proposals

Agent 2 identifies the smallest correct mechanism and correctly keeps payload ownership separate. Its test matrix is strong; the only refinement is to include a direct throwing-bridge test so “Dart callback failure” is demonstrated without overclaiming native trampoline behavior.

Agent 3 likewise preserves the crucial native-error ordering, explicitly tests idempotence, and most clearly explains why 47ZS must not be folded in. Its family-level test subset is safer than requiring every operation to use live-like network setup, but source verification should still confirm all six migrations.

My round-0 proposal overreached by moving the credential-attempt payload into the caller arena. Although architecturally attractive and consistent with ADR-003, that change repairs the separately confirmed 47ZS ownership path, enlarges this high-risk patch, and complicates independent closure/deduplication. I therefore adopt the narrower Agent 2/3 boundary: O3B3 owns deterministic clearing of static callback references; 47ZS owns allocation/destruction changes.
