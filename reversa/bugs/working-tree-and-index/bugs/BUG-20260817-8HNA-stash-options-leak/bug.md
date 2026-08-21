---
schema_version: 1
id: BUG-20260817-8HNA
display_number: 14
title: Stash apply and pop leak checkout option allocations
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: working-tree-and-index
feature: working-tree-and-index
labels: [stash, checkout, native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "2/2 static paths"
  suspected_triggers: [stash apply, stash pop]
blocking: []
relationships:
  - {bug: BUG-20260817-47ZS, type: related-to, state: proposed, evidence: []}
traceability:
  specs:
    - "reversa/sdd/working-tree-and-index/flows.md#fl-wi-07-stash-lifecycle"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/bindings/checkout.dart:178", "lib/src/bindings/stash.dart:87", "lib/src/bindings/stash.dart:146"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Stash apply and pop leak checkout option allocations

## Summary

Every stash apply or pop allocates checkout options, and optionally a pointer array, outside the surrounding arena without freeing either allocation.

## Expected Behavior

ADR-003 requires temporary native allocations to be arena-scoped or explicitly released on all paths.

## Actual Behavior

`checkout.initOptions` uses `calloc`; its callers copy the structure into stash options and discard all returned ownership handles.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Options and path arrays have one explicit owner and are released on success and error.
- Repeated apply/pop instrumentation shows no per-call growth.

## Resolution

Pending approved fix workflow.
