---
schema_version: 1
id: BUG-20260817-K2RY
display_number: 25
title: Blob filtering does not dispose libgit2 buffer storage
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: git-objects-and-object-database
feature: git-objects-and-object-database
labels: [blob, git-buf, native-memory, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 static path", suspected_triggers: [blob filtering]}
blocking: []
relationships:
  - {bug: BUG-20260817-X4AE, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["_reversa_sdd/git-objects-and-object-database/design.md", "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/blob.dart:229"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Blob filtering does not dispose libgit2 buffer storage

## Summary

Blob filtering copies a returned `git_buf` but does not dispose its internal native storage.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- The buffer is disposed after copying and on any partially initialized failure path.
- Repeated filtering instrumentation shows no growth.

## Resolution

Pending approved fix workflow.
