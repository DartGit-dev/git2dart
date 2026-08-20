---
schema_version: 1
id: BUG-20260817-BVMB
display_number: 10
title: Remote getRefspec wraps a null native pointer for invalid indexes
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
labels: [refspec, null-pointer, error-contract]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [refspec index outside valid range]
blocking: []
relationships:
  - bug: BUG-20260817-VGYQ
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "_reversa_sdd/references-and-remotes/requirements.md#functional-requirements"
    - "_reversa_sdd/references-and-remotes/edge-cases.md#references-and-remotes-edge-cases"
  affected_code: ["lib/src/remote.dart:231", "lib/src/bindings/remote.dart:294", "lib/src/refspec.dart"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Remote getRefspec wraps a null native pointer for invalid indexes

## Summary

An invalid refspec index produces a wrapper around a null pointer instead of the documented error.

## Expected Behavior

FR-RR-05 and the public `getRefspec` contract require invalid lookup to fail explicitly.

## Actual Behavior

The native nullable pointer is returned without validation and immediately wrapped. Later property access dereferences it.

## Steps to Reproduce

Call `getRefspec(refspecCount)` and access a `Refspec` property.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Borrowed refspec lookup and null-result translation.

## Acceptance Criteria

- Invalid indexes fail at lookup with the documented Dart/native error.
- No public wrapper can contain a null refspec pointer.
- Boundary indexes have positive and negative tests.

## Traceability

FR-RR-05, refspec edge cases, and remote/refspec wrappers.

## Resolution

Pending approved fix workflow.

## Agent Notes

The positive tests cover only index zero.
