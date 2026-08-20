---
schema_version: 1
id: BUG-20260817-O3B3
display_number: 6
title: Remote failure cleanup retains sensitive callback context
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin:
  type: inspection
  external_ref: null
area: native-integration
module: native-runtime-and-platform-boundary
feature: native-runtime-and-platform-boundary
labels: [restricted-security-review, callback-cleanup]
visibility: restricted
security_suspected: true
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [remote operation failure]
blocking: []
relationships:
  - bug: BUG-20260817-47ZS
    type: related-to
    state: proposed
    evidence: []
  - bug: BUG-20260817-CIKD
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "_reversa_sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "_reversa_sdd/native-runtime-and-platform-boundary/flows.md#fl-np-06-native-callback"
  affected_code:
    - "lib/src/bindings/remote.dart"
    - "lib/src/bindings/repository.dart"
    - "lib/src/bindings/remote_callbacks.dart"
    - "lib/src/remote.dart"
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure:
  policy: package
  satisfied: false
resolution_kind: null
---

# Remote failure cleanup retains sensitive callback context

## Summary

Failure cleanup does not promptly clear sensitive callback context.

## Expected Behavior

FR-NP-08 requires callback state to remain operation-scoped and to be cleaned on every exit path.

## Actual Behavior

Static inspection confirmed a failure path that exits before operation callback cleanup. Detailed security-sensitive reproduction information is intentionally restricted.

## Steps to Reproduce

Use an isolated test credential and a controlled failing remote operation. Do not use production credentials or include secret material in logs.

## Evidence

- `evidence/restricted-static-analysis.md`
- `evidence/restricted-references-and-remotes-occurrence.md`

## Suspected Area

Restricted remote callback cleanup path.

## Acceptance Criteria

- Sensitive callback context is cleared on success, native failure, and Dart callback failure.
- Tests use synthetic credentials and prove no sensitive context remains reachable after completion.
- Restricted evidence remains excluded from generated public views.

## Traceability

- Specs: FR-NP-08 and FL-NP-06.
- Code: restricted callback cleanup paths.

## Resolution

Pending restricted `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

The user explicitly confirmed restricted visibility. Do not place detailed reproduction data, credentials, or secret-like values in generated views or external harnesses.
