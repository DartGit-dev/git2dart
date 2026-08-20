---
schema_version: 1
id: BUG-20260817-V9TR
display_number: 29
title: Status performance data returns an arena-freed pointer
status: open
phase: triaging
severity: critical
priority: P0
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: repository-lifecycle
feature: repository-lifecycle
labels: [status, perfdata, use-after-free, ffi]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 calls", suspected_triggers: [reading status list performance data]}
blocking: []
relationships: []
traceability:
  specs: ["_reversa_sdd/repository-lifecycle/design.md#observability", "_reversa_sdd/repository-lifecycle/edge-cases.md#native-ownership-and-lifecycle"]
  affected_code: ["lib/src/bindings/status.dart:134"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Status performance data returns an arena-freed pointer

## Summary

`listPerfdata` returns a pointer allocated inside `using`; the arena frees that pointer before the caller can read it.

## Expected Behavior

Performance data must be copied into a Dart value or returned with a valid owner.

## Actual Behavior

The function exits the arena and returns its freed allocation, creating a deterministic dangling pointer.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- No pointer outlives its arena.
- The API returns managed values or explicit owned storage.
- Tests read performance data under memory instrumentation.

## Resolution

Pending approved fix workflow.
