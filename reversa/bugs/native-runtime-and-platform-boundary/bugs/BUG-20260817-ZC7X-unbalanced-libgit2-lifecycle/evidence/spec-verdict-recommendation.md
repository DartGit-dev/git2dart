# Specification Verdict Recommendation

## Compared effective specification

- `requirements.md` FR-NP-01 requires loading and balanced
  initialize/shutdown behavior for libgit2.
- `requirements.md` FR-NP-05 requires exactly one owner/destructor path for
  owned native resources.
- `flows.md` FL-NP-02 defines explicit free, finalizer fallback, and ownership
  transfer as the release state machine.
- The same flow explicitly records that repeated-free/post-free guards are not
  yet universal.

## Observed correction alignment

CHG-003 removes the 66 uncontrolled initialization increments and routes calls
through the companion-owned managed runtime. CHG-004 adds exact-once owner
guards for the Gate 1-proven `Repository` and independently usable `Commit`
paths. CHG-005 exposes documented terminal shutdown. The GREEN evidence shows
that this bounded correction behaves as required on the tested Windows path.

## Recommendation

Recommended verdict: `spec-correta`.

The defect is an implementation deviation from existing FR-NP-01, FR-NP-05,
and FL-NP-02 rather than evidence that those requirements are stale. The
recorded non-universal owner-guard gap also already preserves the boundary that
CHG-004 does not close for the wider owner inventory.

Alternative verdicts remain available if the human reviewer considers the
public terminal-shutdown contract missing (`spec-gap`) or the existing
initialize/shutdown wording inaccurate (`spec-desatualizada`). Either
alternative requires an additive specification addendum after approval; the
original reverse-engineered specification must not be rewritten.

