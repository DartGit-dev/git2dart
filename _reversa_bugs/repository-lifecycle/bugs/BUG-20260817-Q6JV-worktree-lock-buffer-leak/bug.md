---
schema_version: 1
id: BUG-20260817-Q6JV
display_number: 28
title: Worktree lock inspection does not dispose reason buffer
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: native-integration
module: repository-lifecycle
feature: repository-lifecycle
labels: [worktree, git-buf, native-memory, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "locked worktree queries", suspected_triggers: [reading isLocked on a locked worktree]}
blocking: []
relationships:
  - {bug: BUG-20260817-K2RY, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["_reversa_sdd/repository-lifecycle/flows.md#fl-rl-09-manage-a-linked-worktree", "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/worktree.dart:194"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Worktree lock inspection does not dispose reason buffer

## Summary

Lock inspection asks libgit2 to populate a `git_buf` and returns the boolean result without disposing internal buffer storage.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Reason storage is disposed on every result and error path.
- Repeated locked-worktree queries show no growth.

## Resolution

Pending approved fix workflow.
