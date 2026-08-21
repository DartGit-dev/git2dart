---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
role: solver
solver_id: agente-2
engine: local
round: 1
status: ok
started_at: 2026-08-21T10:07:37.8185923+07:00
finished_at: 2026-08-21T10:08:00.3488259+07:00
---

# Strategy

Converge on one internal synchronous `RemoteCallbacks.withCallbackState<T>` helper, without a session class. Its `try` begins before `plug`, so partial installation is covered, and its `finally` performs only `reset`:

```dart
try {
  plug(callbacksOptions: callbacksOptions, callbacks: callbacks);
  return operation();
} finally {
  reset();
}
```

Migrate exactly six sites: remote connect/fetch/push, repository clone, and submodule update/clone. Remove their standalone resets. Repository clone assigns `remoteCbData` and `repositoryCbData` inside `operation`. Every native call remains immediately followed by `checkErrorAndThrow(error)` inside `operation`; therefore `LibGit2Error` copies current native error information before unwinding runs reset.

Keep reset as pure null assignments. Do not pass an arena into this helper, change payload allocation, restore previous static values, serialize calls, or add overlap behavior. This is the smallest repair that creates one structural cleanup owner while retaining idempotent cleanup.

# Proposed root cause

`plug` installs operation-scoped data in process-static fields but returns no lifetime owner. Remote connect/fetch/push and repository clone translate native errors before their normal-path reset, so negative results bypass cleanup. Submodule update/clone reset before translation but still have no `finally`, so Dart exceptions can bypass reset. Repository clone also installs two additional static callback-data fields. The defect is duplicated manual sequencing rather than absence of a reset capability.

# Test

Use synthetic values, local fixtures, and serial execution because the state is process-static.

1. Unit-test the helper with arena-initialized callback options. A successful body returns its sentinel and clears all eight fields. A body throwing a pre-created `StateError` rethrows the identical object and clears all fields. This proves Dart-error cleanup without claiming native-trampoline exception characterization.
2. Promote the restricted loopback fetch reproduction to the primary red-to-green test. It must throw `LibGit2Error`, retain a nonempty/stable native diagnostic, and leave every callback field null without manual cleanup before the assertion. A defensive teardown reset may prevent cross-test contamination after a red run.
3. Cover the special families: a failing repository clone installs both creation callback data values before failure, and an existing deterministic submodule failure supplies non-null callback data. Both must clear all fields.
4. Add postcondition assertions to existing deterministic connect, push, update, and clone tests where available. Independently review that all six native calls are inside the helper and that no migrated site retains a manual `plug`/`reset` pair.

The permanent tests should avoid exact OS-specific connection-error strings and real credentials. Run format, analysis, the three targeted files serially, then the full suite.

# Spec impact

No specification edit is needed. The repair implements FR-NP-03/05/08, FL-NP-06, EC-NP-10/14, and ADR-003. It proves synchronous Dart-unwind cleanup only; EC-NP-15 remains open for actual FFI trampoline propagation, and EC-NP-16 remains wholly out of scope. No public API, generated declaration, native ABI, or exported package surface changes.

# Risks and side effects

- The helper must remain synchronous; an asynchronous body would let static state outlive the lexical scope.
- Reset must remain non-native and non-throwing so it cannot replace the pending translated error.
- Overlapping operations can still overwrite or clear each other's static state. This repair intentionally does not mitigate that separate defect.
- Moving more tests onto loopback/native failure paths may introduce platform variance; prefer existing deterministic fixtures and stable error properties.
- The helper is internal and reversible, but all six migrations must be reviewed together to avoid mixed ownership.

# Evidence

- The restricted reproduction retained `credentials` after failed fetch in 3/3 isolated runs.
- `remote.dart:395-411`, `499-514`, `551-560`, and `repository.dart:196-224` reset only after error translation.
- `submodule.dart:120-132` and `243-252` reset without `finally`.
- `remote_callbacks.dart:250-316` centralizes static installation and pure null-reset, making it the narrowest lifecycle-helper location.
- The effective requirements demand immediate native-error capture, deterministic temporary cleanup, bounded callback lifetime, and separation of the EC-NP-16 concurrency gap.

# Confidence

High (0.94). All solvers identified the same lexical-lifetime repair. The remaining choice is scope: excluding payload ownership yields the smallest high-confidence patch while preserving a clean, separately testable 47ZS remediation.

# Critique of other proposals

Agent 1 correctly centralizes installation, operation, immediate error translation, and cleanup. However, `_RemoteCallbackSession`, a `_closed` flag, and arena plumbing add machinery that existing idempotent null-reset does not require. More importantly, moving the credential-attempt payload from `calloc` into the arena folds BUG-20260817-47ZS into O3B3. That allocation has distinct ownership, double-free, and closure accounting; O3B3 can satisfy every acceptance path by clearing Dart callback references alone. Combining them increases diff and test scope under a high-risk classification and risks closing 47ZS without its own complete proof. Keep 47ZS separate, while recognizing arena ownership as its likely repair.

Agent 3 is closest to the minimum: one generic helper, immediate translation inside the body, pure reset, and explicit payload separation. Its direct bridge-throw test is useful only as lexical Dart-error proof, as it correctly notes; it cannot characterize real FFI exception propagation. Repeated-reset testing has low value because reset is visibly null-only. The stronger addition is explicit repository-clone coverage for both extra fields plus review of all six migrated sites.
