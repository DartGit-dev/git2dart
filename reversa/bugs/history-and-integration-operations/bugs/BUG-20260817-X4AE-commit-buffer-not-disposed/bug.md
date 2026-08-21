---
schema_version: 1
id: BUG-20260817-X4AE
display_number: 21
title: Commit buffer operations do not dispose libgit2 storage
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
labels: [commit, git-buf, native-memory, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 static path", suspected_triggers: [serializing commit content]}
blocking: []
relationships: []
traceability:
  specs: ["reversa/sdd/history-and-integration-operations/design.md", "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/commit.dart:106", "lib/src/bindings/commit.dart:227"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Commit buffer operations do not dispose libgit2 storage

## Summary

Commit serialization and signature extraction copy text from libgit2 `git_buf` values but never dispose their internal native storage.

## Expected Behavior

Every successful or partially initialized `git_buf` is disposed after copying.

## Actual Behavior

The arena frees only the outer structure; libgit2-owned `ptr` storage remains allocated.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Buffer disposal occurs in guaranteed cleanup after copying or failure.
- Repeated serialization instrumentation shows no growth.

## Resolution

Pending approved fix workflow.
