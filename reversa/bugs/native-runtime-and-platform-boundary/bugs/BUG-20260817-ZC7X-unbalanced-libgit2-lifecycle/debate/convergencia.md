# Debate Convergence Audit

## Round 0

- Valid proposals: 3/3; quorum requirement: 2; quorum satisfied.
- Strong convergence: all proposals reject the current per-call native
  increments and recommend at most one native initialization lease per Dart
  isolate, relying on libgit2's process-global counter across isolates.
- Strong convergence: all proposals reject unconditional call-scoped shutdown
  around global options because persistent wrappers and process-global
  configuration may remain active.
- Shared safety requirement: initialization failures must not cache active
  state; shutdown must never reach native zero while independently usable owned
  wrappers remain live.
- Main divergence: agent 1 defers a shutdown request until all logical owners
  are released; agent 2 rejects shutdown while owners live and makes shutdown
  terminal for the isolate; agent 3 favors opaque runtime scopes and a hybrid
  split between pure calls and wrapper lifetimes while rejecting a raw public
  shutdown function.
- Main implementation dispute: how broadly to retrofit wrapper/finalizer owner
  tokens, and whether resetting process-global options after reinitialization is
  an acceptable contract.
- Confidence: all three proposals report high confidence in the confirmed cause
  and medium-to-high confidence in their distinct lifecycle policy.

Convergence is recorded for audit only. The fixed two-epoch schedule continues.

## Round 1

- Valid proposals: 3/3; quorum requirement: 2; quorum satisfied.
- Unanimous strategy: one checked native initialization lease per Dart isolate,
  reused by all current entry points, followed by an explicit, idempotent,
  terminal shutdown owned by that isolate.
- Unanimous safety boundary: shutdown fails synchronously while any independently
  usable owned wrapper remains live; it never runs automatically from a
  finalizer and successful shutdown forbids transparent reinitialization.
- Unanimous ownership requirement: every finalizer-backed ownership-producing
  path must be classified; explicit release and fallback cleanup share a
  one-shot token; transfer releases ownership without invoking the destructor;
  borrowed views do not acquire ownership.
- Unanimous platform constraint: Android bootstrap and process-global options
  remain valid for the entire isolate lease; multiple lifecycle epochs require
  a separate rebootstrap design.
- Residual divergence: agent 3 adds transient logical call pins to block
  reentrant shutdown during an active native operation; agents 1 and 2 track
  persistent wrapper owners only. Agent 1 and agent 3 retain the owner if native
  destruction cannot be confirmed, while agent 2 releases it in `finally`.
- Judge discriminator: weigh the extra call-pin complexity and cleanup-failure
  semantics against root-cause elimination, smallest coherent change,
  regression risk, reversibility, and specification adherence.

The fixed two-epoch solver schedule is complete. Final proposals proceed to the
isolated judge in anonymized deterministic order.
