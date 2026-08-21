---
schema_version: 1
id: BUG-20260817-VGYQ
display_number: 11
title: Reflog indexing wraps a null native entry for out-of-range access
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: repository-operations
module: references-and-remotes
feature: references-and-remotes
labels: [reflog, null-pointer, error-contract]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [reflog index outside valid range]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#functional-requirements"
    - "reversa/sdd/references-and-remotes/edge-cases.md#references-and-remotes-edge-cases"
  affected_code: ["lib/src/reflog.dart:84", "lib/src/bindings/reflog.dart:132"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Reflog indexing wraps a null native entry for out-of-range access

## Summary

Out-of-range reflog access creates a `RefLogEntry` backed by a null pointer rather than throwing the documented error.

## Expected Behavior

FR-RR-04 and the public index operator documentation require explicit failure for an out-of-range index.

## Actual Behavior

`git_reflog_entry_byindex` can return null, but the binding and wrapper do not validate the result before later field access.

## Steps to Reproduce

Access `reflog[reflog.length]` and then read an entry property.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Reflog borrowed entry lookup and null-result translation.

## Acceptance Criteria

- Out-of-range lookup fails immediately with the documented error.
- No public `RefLogEntry` contains a null native pointer.
- Empty, first, last, and out-of-range tests exist.

## Traceability

FR-RR-04, reflog edge cases, and reflog wrappers.

## Resolution

Pending approved fix workflow.

## Agent Notes

Existing tests cover invalid removal but not invalid lookup.
