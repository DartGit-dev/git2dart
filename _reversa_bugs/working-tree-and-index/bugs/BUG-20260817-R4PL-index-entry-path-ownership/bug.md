---
schema_version: 1
id: BUG-20260817-R4PL
display_number: 16
title: IndexEntry path mutation overwrites borrowed native storage
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: working-tree-and-index
feature: working-tree-and-index
labels: [index-entry, borrowed-pointer, native-memory, mutation]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static setter"
  suspected_triggers: [setting IndexEntry.path]
blocking: []
relationships: []
traceability:
  specs:
    - "_reversa_sdd/working-tree-and-index/design.md#ownership-and-errors"
    - "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/index.dart:485", "lib/src/index.dart:507", "lib/src/bindings/index.dart:160"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# IndexEntry path mutation overwrites borrowed native storage

## Summary

The public path setter replaces a pointer inside a libgit2-owned, documented non-modifiable index entry with an unmanaged allocation.

## Expected Behavior

Borrowed entries must remain immutable, or mutation must occur on an independently owned copy with explicit path ownership.

## Actual Behavior

`IndexEntry.path` calls `toCharAlloc` and overwrites the borrowed structure field. The original pointer becomes unreachable and the replacement has no Dart owner.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Borrowed libgit2 entries are not mutated directly.
- A mutable entry uses copied storage and releases replaced paths exactly once.
- Repeated path changes and index disposal pass ownership instrumentation.

## Resolution

Pending approved fix workflow.
