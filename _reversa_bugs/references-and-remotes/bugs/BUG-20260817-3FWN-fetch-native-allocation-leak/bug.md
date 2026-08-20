---
schema_version: 1
id: BUG-20260817-3FWN
display_number: 8
title: Remote fetch leaks native options and refspec allocations
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: references-and-remotes
feature: references-and-remotes
labels: [remote-fetch, native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [remote fetch]
blocking: []
relationships:
  - bug: BUG-20260817-47ZS
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "_reversa_sdd/references-and-remotes/requirements.md#functional-requirements"
    - "_reversa_sdd/references-and-remotes/flows.md#fl-rr-04-fetch"
    - "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/bindings/remote.dart:473"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Remote fetch leaks native options and refspec allocations

## Summary

Every fetch allocates three native containers outside the arena and never releases them.

## Expected Behavior

FR-RR-08, FR-RR-12, FL-RR-04, and ADR-003 require remote options and temporary refspec storage to be released on success and error.

## Actual Behavior

`fetch` allocates `git_strarray`, its pointer array, and `git_fetch_options` with `calloc`. The enclosing arena does not own these allocations and no explicit free exists.

## Steps to Reproduce

Trace allocations and cleanup in `lib/src/bindings/remote.dart:473-516`.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Remote fetch option and refspec marshalling.

## Acceptance Criteria

- Each allocation has one owner and is released on all exits.
- Repeated fetch instrumentation reports no growth.
- Callback payload cleanup remains correctly ordered.

## Traceability

FR-RR-08, FR-RR-12, FL-RR-04, ADR-003, and the remote fetch binding.

## Resolution

Pending approved fix workflow.

## Agent Notes

The source remained read-only during inspection.
