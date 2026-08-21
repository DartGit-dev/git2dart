---
schema_version: 1
id: BUG-20260817-6KRT
display_number: 13
title: Index read and write operations silently ignore native failures
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: repository-operations
module: working-tree-and-index
feature: working-tree-and-index
labels: [index, persistence, error-contract, silent-failure]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "3/3 static paths"
  suspected_triggers: [invalid index, read failure, write failure]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/working-tree-and-index/requirements.md#functional-requirements"
    - "reversa/sdd/working-tree-and-index/flows.md#fl-wi-01-stage-paths-and-write-a-tree"
  affected_code: ["lib/src/bindings/index.dart:98", "lib/src/bindings/index.dart:110", "lib/src/bindings/index.dart:347", "lib/src/index.dart:277", "lib/src/index.dart:285", "lib/src/index.dart:294"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Index read and write operations silently ignore native failures

## Summary

Three public index persistence paths discard libgit2 status codes and therefore report success when the native operation fails.

## Expected Behavior

FR-WI-03, FR-WI-04, and the central native error contract require every failed read, tree read, or write to throw a translated error.

## Actual Behavior

`read`, `readTree`, and `write` call fallible libgit2 APIs without passing the result to `checkErrorAndThrow`.

## Steps to Reproduce

Trace the three high-level methods to their binding functions and follow the returned native integer.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- All three return codes are checked.
- Negative tests demonstrate that invalid or unwritable index operations throw.
- Successful behavior remains unchanged on the supported platform matrix.

## Resolution

Pending approved fix workflow.
