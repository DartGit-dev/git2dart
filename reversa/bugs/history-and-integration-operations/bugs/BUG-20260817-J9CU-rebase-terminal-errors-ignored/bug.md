---
schema_version: 1
id: BUG-20260817-J9CU
display_number: 18
title: Rebase finish and abort silently ignore native failures
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: repository-operations
module: history-and-integration-operations
feature: history-and-integration-operations
labels: [rebase, state, error-contract, silent-failure]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "2/2 static paths", suspected_triggers: [failed rebase finish, failed rebase abort]}
blocking: []
relationships:
  - {bug: BUG-20260817-6KRT, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/history-and-integration-operations/flows.md", "reversa/sdd/history-and-integration-operations/edge-cases.md"]
  affected_code: ["lib/src/bindings/rebase.dart:149", "lib/src/bindings/rebase.dart:155", "lib/src/rebase.dart:169", "lib/src/rebase.dart:176"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Rebase finish and abort silently ignore native failures

## Summary

The two terminal rebase operations discard libgit2 return codes, so callers cannot know whether repository state was finalized or restored.

## Expected Behavior

Every state-changing terminal operation must translate native failure and leave its outcome observable.

## Actual Behavior

Both binding functions return `void` directly from fallible libgit2 calls without checking their integer status.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Both statuses are checked and translated.
- Negative tests distinguish successful finish/abort from retained rebase state.

## Resolution

Pending approved fix workflow.
