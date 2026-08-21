---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
role: judge
engine: local
round: final
status: ok
started_at: 2026-08-21T03:10:32.392Z
finished_at: 2026-08-21T03:10:33.392Z
---

## Recommendation

Adopt Proposal C as the winning proposal, with selected test-coverage details from Proposals A and B. Implement one internal synchronous generic `RemoteCallbacks.withCallbackState<T>` whose `try` begins before callback-state installation and whose `finally` performs the existing pure-Dart reset. Move the complete operation-scoped sequence for every affected family into that lexical scope: state assignment, the native call, and immediate native-error translation. Migrate remote connect/fetch/push, repository clone, and submodule update/clone, then remove their manual resets.

This repair should remain narrowly confined to operation-scoped callback-state ownership. It must not introduce a public API or ABI change, a session abstraction, native-payload ownership changes, locking, save/restore behavior, or process-static concurrency work.

## Winning synthesis

Proposal C is the strongest overall fit because it combines the minimal lexical-owner repair with the most decisive failure regression: a repeated synthetic loopback fetch test, direct synchronous callback-bridge failure coverage, explicit repository-clone and submodule-family checks, and success-path cleanup. It also clearly preserves immediate error translation inside the protected operation and explicitly keeps native-trampoline exception propagation and process-static overlap outside this repair.

The implementation shape should be:

1. Enter `withCallbackState<T>`.
2. Start `try` before installing any operation-scoped callback data.
3. Install all state required by that operation, including both repository-clone callback-data fields.
4. Invoke the native operation and translate its error immediately, before leaving the closure.
5. Return the operation result on success.
6. Unconditionally reset callback state in `finally`, including when installation, the native call, immediate native-error translation, or other synchronous Dart code throws.

The helper must remain synchronous; accepting an asynchronous operation would extend state lifetime and create unsupported overlap semantics.

## Contributions adopted from other proposals

From Proposal A, adopt the compact six-family failure/postcondition matrix and source-level migration review. These provide economical evidence that every affected call site has moved under the same lexical owner and that obsolete manual cleanup paths are gone. Also retain its requirement that a thrown bridge error be preserved unchanged while cleanup still occurs.

From Proposal B, adopt the special failing repository-clone case that verifies both `remoteCbData` and `repositoryCbData`, plus diagnostic assertions that require a nonempty translated native error without matching unstable operating-system wording. Also adopt deterministic submodule failure coverage and postcondition assertions on already-existing connect, push, update, and clone tests where those assertions can be added without broad fixture churn.

Proposal B's preference to omit repeated-reset and direct throwing-bridge tests is not adopted: both are cheap, deterministic checks of the helper's lexical guarantee. Proposal A's broad matrix is useful, but Proposal C remains the winner because it better combines repeated-failure evidence with clone/submodule family checks and explicit open-risk boundaries.

## Rubric assessment

1. **Root-cause elimination:** The proposed `try`/`finally` lexical owner covers success, translated native error, and synchronous Dart error. Beginning `try` before installation also covers partial installation failure. Keeping `checkErrorAndThrow` inside the operation ensures native error information is translated while callback state is still valid; cleanup then runs during unwinding.

2. **Smallest coherent change:** One internal helper plus migration of exactly the six affected operation families is the smallest change that establishes one ownership rule everywhere the confirmed defect exists. Removing displaced manual resets prevents split ownership and inconsistent exceptional paths.

3. **Regression risk:** The change reuses existing installation and reset behavior, remains synchronous, and does not redesign callbacks or memory ownership. Focused synthetic tests exercise the helper and representative special cases, while the six-family matrix guards migration completeness under the stated high change risk.

4. **Reversibility and compatibility:** The helper is internal, no public signature or native layout changes, and each migration is structurally local. The patch can be reverted without data migration or compatibility handling.

5. **Specification and restricted-note adherence:** The synthesis preserves immediate native-error translation, guarantees cleanup of operation-scoped sensitive callback context, keeps ownership explicit and bounded, and avoids expanding into native payload allocation or process-static concurrency. This is consistent with FR-NP-03/05/08, FL-NP-06, EC-NP-10/14 and the stated restricted notes.

6. **Red-to-green evidence without credentials:** The repeated loopback fetch failure should fail before the repair because stale state remains after a failed exit and pass afterward. Helper-level Dart-error and success tests, clone/submodule special cases, and family postconditions provide deterministic local coverage without network credentials or external services.

## Test plan

- Add a helper success test that returns the exact value and verifies every callback-state field is clear afterward.
- Add a helper Dart-error test that throws a specific `StateError`, verifies the identical object or equivalent preserved identity contract is rethrown, and verifies all fields are clear.
- Add a repeated-reset idempotence test so `finally` remains safe if a setup path or legacy edge already cleared state.
- Add a direct synchronous throwing callback-bridge test to prove cleanup is lexical rather than dependent on native return handling.
- Add the decisive three-run synthetic/local loopback fetch failure regression. Each run must preserve the translated `LibGit2Error` type and a nonempty diagnostic, and each postcondition must show cleared callback state. Do not assert exact OS-dependent messages.
- Add a failing repository-clone test that installs and then verifies cleanup of both `remoteCbData` and `repositoryCbData`.
- Add a deterministic submodule failure test and at least one successful operation postcondition.
- Apply a compact failure/postcondition matrix across connect, fetch, push, repository clone, submodule update, and submodule clone, reusing existing synthetic fixtures where possible.
- Review the source migration to confirm the native call and immediate error translation remain inside each helper closure and no affected manual reset remains.
- Run focused tests first, then the full local suite serially if shared process-static test state requires isolation.

## Spec impact

No public product behavior, API, or ABI changes are intended. The repair strengthens the internal lifecycle invariant: operation-scoped remote callback state is installed, consumed, translated, and cleared under one synchronous lexical owner. Existing specifications should need only a traceability or implementation-note update if they currently describe cleanup without stating the exceptional-exit guarantee.

## Risks and exclusions

The primary residual risk is incomplete call-site migration; the six-family matrix and source review address it. Another risk is accidentally moving native-error translation outside the scope, which could erase data needed for diagnostics; tests must assert preserved translated error type and nonempty diagnostics. The helper must not accept `Future`-returning operations, because asynchronous use would create a wider lifetime and overlap hazards.

Native payload allocation and release remain exclusively under BUG-20260817-47ZS. Process-static callback concurrency, reentrancy, locking, and save/restore semantics remain a separate defect. Native-trampoline exception propagation is also not established by these tests and remains open. No test may require real credentials, a remote hosted service, or unstable external network behavior.

## Confidence

High (0.95). All three proposals converge on the correct minimal ownership mechanism. Proposal C wins because its core validation most directly exercises repeated exceptional exits and synchronous lexical cleanup, while the adopted matrix and clone-specific assertions close the main coverage gaps without expanding implementation scope.
