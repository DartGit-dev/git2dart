---
schema_version: 1
id: BUG-20260817-M2VF
display_number: 15
title: Reference and commit checkout do not guarantee lookup-object cleanup
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
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
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
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

Pending approved fix workflow.
