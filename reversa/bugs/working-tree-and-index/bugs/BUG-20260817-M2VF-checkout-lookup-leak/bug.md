---
schema_version: 1
id: BUG-20260817-M2VF
display_number: 15
title: Reference and commit checkout do not guarantee lookup-object cleanup
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: repository-operations
module: working-tree-and-index
feature: working-tree-and-index
labels: [checkout, native-memory, cleanup, error-path]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "2/2 static paths"
  suspected_triggers: [reference checkout, failed tree checkout]
blocking: []
relationships:
  - {bug: BUG-20260817-VG7G, type: related-to, state: proposed, evidence: []}
traceability:
  specs:
    - "reversa/sdd/working-tree-and-index/flows.md#fl-wi-06-checkout-content"
    - "reversa/sdd/working-tree-and-index/design.md#ownership-and-errors"
  affected_code: ["lib/src/checkout.dart:102", "lib/src/checkout.dart:147"]
  root_cause:
    state: confirmed
    hypothesis: "Reference and commit checkout temporarily own lookup objects that were originally released only after successful native checkout."
    causal_path: ["checkout creates temporary lookup owner", "native checkout may throw", "post-success-only cleanup is bypassed", "temporary native owner remains live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original paths omitted reference cleanup and placed treeish cleanup after the fallible call."}
      - {ref: "evidence/current-head-audit.md", observation: "Current reference and commit paths release each lookup owner in finally."}
    code_refs:
      - {file: "lib/src/checkout.dart", symbol: "Checkout.reference and Checkout.commit", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
  reproduction_tests: ["test/checkout_test.dart#throws when trying to checkout reference with invalid alternative directory", "test/checkout_test.dart#throws when trying to checkout commit with invalid alternative directory"]
  regression_tests: ["test/checkout_test.dart#checkouts reference", "test/checkout_test.dart#checkouts commit"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/checkout_test.dart", purpose: "Exercise local reference and commit checkout success/error paths.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/checkout.dart", purpose: "Release temporary reference and treeish owners in finally.", evidence: "evidence/current-head-audit.md"}
closure: {policy: package, satisfied: false}
resolution_kind: fixed
delivery:
  branch: "0.5.5"
  commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
versions:
  fixed_in: null
backports: []
---

# Reference and commit checkout do not guarantee lookup-object cleanup

## Summary

Reference checkout never releases its looked-up `Reference`, and both reference and commit checkout release the treeish object only after a successful checkout.

## Expected Behavior

Checkout temporaries must be released regardless of whether native checkout succeeds.

## Actual Behavior

Cleanup is placed after the fallible call rather than in `finally`; the reference object has no cleanup call at all.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Reference and treeish owners are released exactly once on success and failure.
- Negative checkout tests verify cleanup under instrumentation.

## Resolution

The confirmed root cause was temporary checkout lookup ownership not being
lexically guarded around a fallible native call. Current reference checkout
uses nested `try/finally` blocks for reference and treeish owners; commit
checkout guards its treeish owner in `finally`. The required plan is recorded
in `fix/plan.html`.

Focused local checkout success and failure scenarios pass with focused analysis
clean. No current source or test gap was demonstrated, so this audit applied
no code or test diff. The authorized evidence-based verdict is `spec-correta`:
the existing checkout flow and ownership design already require every temporary
lookup object to be released on all exits.

Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
