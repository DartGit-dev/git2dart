---
schema_version: 1
id: BUG-20260817-Y7GX
display_number: 17
title: Failed index stash and diff OID operations leak output buffers
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
labels: [oid, native-memory, error-path, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "5/5 static paths"
  suspected_triggers: [failed write tree, failed stash save, failed patch ID]
blocking: []
relationships:
  - {bug: BUG-20260817-2TB4, type: related-to, state: proposed, evidence: []}
traceability:
  specs:
    - "_reversa_sdd/working-tree-and-index/design.md#ownership-and-errors"
    - "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/bindings/index.dart:128", "lib/src/bindings/index.dart:145", "lib/src/bindings/stash.dart:26", "lib/src/bindings/stash.dart:57", "lib/src/bindings/diff.dart:300"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Failed index stash and diff OID operations leak output buffers

## Summary

Five OID-producing adapters allocate their result before a fallible native call and throw without releasing it on failure.

## Expected Behavior

Temporary output buffers must be released before propagating native errors.

## Actual Behavior

Index write-tree, stash-save, and diff patch-ID paths call `calloc`, then `checkErrorAndThrow`, with no failure cleanup.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Every failure path frees its preallocated output exactly once.
- Successful returned OIDs retain one valid owner.
- Negative-loop instrumentation shows no growth.

## Resolution

Pending approved fix workflow.
