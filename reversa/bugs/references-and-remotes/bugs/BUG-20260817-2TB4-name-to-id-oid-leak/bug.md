---
schema_version: 1
id: BUG-20260817-2TB4
display_number: 12
title: Reference nameToId leaks its native OID allocation
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: references-and-remotes
feature: references-and-remotes
labels: [reference, oid, native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [reference name to OID lookup]
blocking: []
relationships:
  - bug: BUG-20260817-3FWN
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#functional-requirements"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/reference.dart:297", "lib/src/bindings/reference.dart:844", "lib/src/oid.dart"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Reference nameToId leaks its native OID allocation

## Summary

Reference name lookup returns a heap-allocated OID through a wrapper that has no ownership or release path.

## Expected Behavior

FR-RR-01, FR-RR-12, and ADR-003 require returned native allocations to have explicit ownership and release.

## Actual Behavior

The binding allocates `git_oid` with `calloc` and returns it. `Oid` stores the pointer but has no finalizer or free method for this allocation.

## Steps to Reproduce

Trace `Reference.nameToId` through the binding and `Oid` constructor.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Reference-to-OID conversion ownership.

## Acceptance Criteria

- The returned OID is copied into managed storage or receives one explicit native owner.
- Success and error paths release temporary allocations.
- Repeated name lookup shows no growth under instrumentation.

## Traceability

FR-RR-01, FR-RR-12, ADR-003, reference binding, and OID wrapper.

## Resolution

Pending approved fix workflow.

## Agent Notes

The positive test proves value correctness but not allocation ownership.
