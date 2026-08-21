---
schema_version: 1
id: BUG-20260817-VG7G
display_number: 9
title: Remote advertisement listing does not guarantee disconnect
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
labels: [remote-ls, cleanup, transport]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [post-connect advertisement failure]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#responsibilities-and-rules"
    - "reversa/sdd/references-and-remotes/flows.md#fl-rr-03-list-remote-advertisements"
    - "reversa/sdd/references-and-remotes/edge-cases.md#references-and-remotes-edge-cases"
  affected_code: ["lib/src/remote.dart:260"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Remote advertisement listing does not guarantee disconnect

## Summary

`Remote.ls` disconnects only after advertisement retrieval succeeds.

## Expected Behavior

BR-RR-06, FR-RR-07, FL-RR-03, and EC-RR-12 require connection cleanup on success and failure.

## Actual Behavior

The method connects, reads advertisements, and then disconnects sequentially without `try/finally`. A post-connect failure bypasses disconnect.

## Steps to Reproduce

Trace `lib/src/remote.dart:260-282` and follow an exception from `lsRemotes`.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Remote advertisement connection lifecycle.

## Acceptance Criteria

- A successful connection is disconnected on every later exit.
- Original errors remain observable if disconnect also fails.
- Positive and post-connect failure tests verify final connection state.

## Traceability

BR-RR-06, FR-RR-07, FL-RR-03, EC-RR-12, and `Remote.ls`.

## Resolution

Pending approved fix workflow.

## Agent Notes

No live remote was contacted during inspection.
