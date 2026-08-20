---
schema_version: 1
id: BUG-20260817-P5DB
display_number: 19
title: Merge operations leak native merge options
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: history-and-integration-operations
feature: history-and-integration-operations
labels: [merge, native-memory, options, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "3/3 static call families", suspected_triggers: [merge, merge commits, merge trees]}
blocking: []
relationships:
  - {bug: BUG-20260817-8HNA, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["_reversa_sdd/history-and-integration-operations/design.md", "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/merge.dart:197", "lib/src/bindings/merge.dart:366", "lib/src/bindings/merge.dart:404", "lib/src/bindings/merge.dart:478"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Merge operations leak native merge options

## Summary

The shared merge-options helper accepts an arena but allocates with `calloc`; none of its three call families frees the returned allocation.

## Expected Behavior

Temporary merge options must be arena-owned or explicitly released on all paths.

## Actual Behavior

Each merge, merge-commits, or merge-trees invocation leaks one options structure.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- One explicit owner releases options on success and error.
- Repeated merge instrumentation shows no per-call growth.

## Resolution

Pending approved fix workflow.
