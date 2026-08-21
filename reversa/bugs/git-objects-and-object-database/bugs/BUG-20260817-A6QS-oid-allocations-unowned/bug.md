---
schema_version: 1
id: BUG-20260817-A6QS
display_number: 22
title: Oid wrappers never release owned native allocations
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: git-objects-and-object-database
feature: git-objects-and-object-database
labels: [oid, native-memory, ownership, pervasive-leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "all owned Oid instances", suspected_triggers: [OID parsing, object creation, ODB write, merge base]}
blocking: []
relationships:
  - {bug: BUG-20260817-2TB4, type: related-to, state: proposed, evidence: []}
  - {bug: BUG-20260817-Y7GX, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/git-objects-and-object-database/design.md", "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/oid.dart:15", "lib/src/bindings/oid.dart", "lib/src/bindings/odb.dart", "lib/src/bindings/blob.dart", "lib/src/bindings/commit.dart", "lib/src/bindings/tree.dart", "lib/src/bindings/tag.dart"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Oid wrappers never release owned native allocations

## Summary

`Oid` has no finalizer or `free` method although its public constructors and many object-producing bindings allocate `git_oid` with `calloc`.

## Expected Behavior

Owned OIDs must be copied into managed storage or released exactly once; borrowed OIDs must remain non-owning.

## Actual Behavior

Owned and borrowed pointers share one wrapper with no ownership marker. Every owned allocation survives for process lifetime.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Ownership is explicit for all OID constructors and getters.
- Owned pointers are released; borrowed pointers are never freed.
- Cross-feature allocation tests cover success and failure paths.

## Resolution

Pending approved fix workflow.
