---
schema_version: 1
id: BUG-20260817-DQPX
display_number: 2
title: Global libgit2 option APIs silently ignore native failures
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
labels: [error-contract, global-options, silent-failure]
visibility: normal
security_suspected: false
reproduction:
  classification: not-reproduced
  rate: "0/0"
  suspected_triggers: [invalid native option value, unsupported platform option]
blocking:
  - kind: external
    reason: "Focused runtime execution is blocked by stale Flutter tool locks outside the repository."
    since: 2026-08-17
relationships:
  - bug: BUG-20260817-QWMA
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "_reversa_sdd/native-runtime-and-platform-boundary/requirements.md#business-rules"
    - "_reversa_sdd/native-runtime-and-platform-boundary/flows.md#fl-np-05-set-a-global-option"
    - "_reversa_sdd/adrs/004-centralize-native-error-translation.md#decision"
  affected_code:
    - "lib/src/libgit2.dart"
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

# Global libgit2 option APIs silently ignore native failures

## Summary

Most global option getters and setters discard the native return code, so an unsuccessful option operation can appear successful to the caller.

## Expected Behavior

BR-NP-03, FR-NP-04, FL-NP-05, and ADR-004 require immediate translation of negative native results.

## Actual Behavior

`lib/src/libgit2.dart` invokes global option functions without passing their results to `checkErrorAndThrow`. The pack maximum object size accessors are the notable checked exception.

## Steps to Reproduce

1. Enumerate calls beginning with `libgit2Opts.git_libgit2_opts_`.
2. Compare each call with the checked pattern at lines 462-475.
3. Observe that the other option calls discard their native status.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Typed process-global option facade in `Libgit2`.

## Acceptance Criteria

- Every fallible global option call checks its native result immediately.
- Negative cases are covered without changing unrelated process-global state.
- Successful get and set behavior remains covered on supported platforms.

## Traceability

- Specs: BR-NP-03, FR-NP-04, FL-NP-05, ADR-004.
- Code: `lib/src/libgit2.dart`.

## Resolution

Pending `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

The inspection did not infer that every option can fail on every platform. The defect is the systematic loss of a fallible native status.
