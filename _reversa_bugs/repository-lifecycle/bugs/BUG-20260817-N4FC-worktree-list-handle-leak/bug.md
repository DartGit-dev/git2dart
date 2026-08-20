---
schema_version: 1
id: BUG-20260817-N4FC
display_number: 27
title: Worktree list leaks every looked-up native worktree handle
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
labels: [worktree, list, native-memory, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "one handle per listed worktree", suspected_triggers: [Worktree.list]}
blocking: []
relationships: []
traceability:
  specs: ["_reversa_sdd/repository-lifecycle/flows.md#fl-rl-09-manage-a-linked-worktree", "_reversa_sdd/repository-lifecycle/flows.md#fl-rl-12-release-native-ownership"]
  affected_code: ["lib/src/bindings/worktree.dart:148", "lib/src/worktree.dart:64"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Worktree list leaks every looked-up native worktree handle

## Summary

The binding returns owning worktree handles, while the public list converts only their names and discards all handles without freeing them.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Every lookup handle is released after its name is copied, including exceptional paths.
- Repeated listing instrumentation shows no growth.

## Resolution

Pending approved fix workflow.
