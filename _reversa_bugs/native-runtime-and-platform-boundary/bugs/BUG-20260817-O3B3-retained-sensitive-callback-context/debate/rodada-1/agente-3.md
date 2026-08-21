---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
role: solver
solver_id: agente-3
engine: local
round: 1
status: ok
started_at: 2026-08-21T10:06:00+07:00
finished_at: 2026-08-21T10:08:00+07:00
---

# Strategy

Adopt the common round-0 core: add one synchronous generic
`RemoteCallbacks.withCallbackState<T>` helper. Its `try` starts before `plug`,
returns the supplied operation result, and its sole `finally` action is
`reset()`. Migrate all six operations—remote connect/fetch/push, repository
clone, and submodule update/clone—and remove their manual resets.

Keep the native call and adjacent `checkErrorAndThrow(error)` inside the helper
closure. Dart constructs `LibGit2Error` from current `git_error_last()` before
unwinding runs the pure-Dart reset. Repository clone must assign
`remoteCbData` and `repositoryCbData` inside the closure so partial setup is
also covered.

Do not add a session object or `_closed` flag. The helper invokes `reset`
exactly once structurally, while reset's null assignments are already
idempotent. This is the smallest reversible implementation and adds no public
export or native ABI surface.

Keep credential payload allocation unchanged in O3B3. Its ownerless `calloc`
is a confirmed path of BUG-20260817-47ZS, not the sensitive Dart-reference
retention reproduced here. Fixing only that one 47ZS path would partially mix
bug closures while leaving its SSH allocation path open. Repair payload
ownership atomically under 47ZS, where arena conversion, allocation tests, and
traceability can be reviewed together.

# Proposed root cause

`plug` installs operation data into process-static Dart fields, but callers own
cleanup through manually sequenced trailing resets. Four call sites translate
native failure first, so the throw bypasses reset. The two submodule sites
reset before translation but still lack protection from Dart exceptions during
installation or invocation. The missing invariant is one lexical lifetime from
the first state mutation through native call, immediate translation, result
construction, and every exit.

# Test

Use synthetic values and serial execution:

1. Add the decisive red-to-green fetch regression with loopback port 1 and a
   synthetic `UserPass`. Require `LibGit2Error` with a nonempty diagnostic and
   require all eight static fields to be null afterward. Keep unconditional
   teardown reset so the intentionally red baseline cannot contaminate tests.
2. Test `withCallbackState` with arena-initialized callback options. A success
   closure returns a sentinel and clears all fields. A closure throwing a
   pre-created `StateError` rethrows the identical object and clears all fields.
   Call reset twice to prove idempotence.
3. Directly invoke an installed throwing progress bridge inside the helper and
   verify error identity plus cleared state. This proves synchronous Dart
   callback cleanup without claiming native-trampoline propagation.
4. Add migration checks for repository clone's two special callback fields and
   the existing submodule failure fixture. Extend one local success test with
   the same null-state postcondition. Avoid live services and OS-specific full
   error strings.
5. Run formatting, the three focused test files serially, analysis, and the
   full suite.

# Spec impact

No spec change. The repair enforces FR-NP-08, FL-NP-06, EC-NP-10, and EC-NP-14
while preserving immediate translation. FR-NP-03/05 remain relevant, but
47ZS—not O3B3—owns the existing native allocation violation. EC-NP-15 remains
open beyond synchronous cleanup, and EC-NP-16 remains entirely out of scope.
No public API, generated binding, or ABI changes occur.

# Risks and side effects

- Static overlap/reentrancy remains unsafe; do not add locks, zones, saved
  state, depth counters, or active-session assertions.
- Cleanup must remain nonthrowing and free of libgit2 calls, or it could mask a
  pending translated error.
- All migrated manual resets must be removed so the helper is the only owner.
- Preserve connect's existing success lifetime: reset when connect returns,
  not at disconnect.
- Separating payload ownership leaves 47ZS active; it must not be misreported
  as fixed by O3B3.

# Evidence

- The restricted reproduction retains credentials after 3/3 failed fetches.
- `remote.dart:395-411`, `499-514`, `551-560`, and
  `repository.dart:196-224` translate before reset.
- `submodule.dart:120-132` and `243-252` reset without `finally`.
- `remote_callbacks.dart:250-316` centralizes static installation/reset and
  separately allocates the attempt payload.
- The 47ZS root cause identifies two ownership paths, confirming that moving
  only the attempt payload is not a complete 47ZS repair.

# Confidence

High (0.94). All solvers independently converged on the lexical helper. Keeping
47ZS separate reduces change and test scope without weakening O3B3 cleanup.

# Critique of other proposals

Agente-2 is closest to the minimal safe repair: it correctly scopes `plug`, all
six invocations, and immediate translation in one `try/finally`, and keeps
payload ownership separate. Its proposed six-operation failure matrix is
strong but may be unnecessarily slow or flaky; helper contract tests plus
targeted family migrations provide sufficient structural coverage.

Agente-1 correctly notices the ownerless payload and proposes sound arena
lifetime mechanics. However, folding that change into O3B3 broadens a
high-risk patch and only partially addresses 47ZS because its separate SSH
allocation path remains. The extra session class and `_closed` flag also add
machinery without improving the exactly-once helper-finally invariant.

My round-0 proposal matches agente-2 on scope. I refine it by explicitly tying
the separation decision to atomic 47ZS closure and by reducing the test matrix
to deterministic helper semantics plus targeted family integration checks.
