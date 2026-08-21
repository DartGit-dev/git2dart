---
schema_version: 1
id: BUG-20260817-L8WX
display_number: 26
title: Repository identity lookup silently ignores native failures
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: repository-operations
module: repository-lifecycle
feature: repository-lifecycle
labels: [repository, identity, error-contract, silent-failure]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 static path", suspected_triggers: [invalid repository identity lookup]}
blocking: []
relationships:
  - {bug: BUG-20260817-6KRT, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/repository-lifecycle/requirements.md", "reversa/sdd/repository-lifecycle/edge-cases.md"]
  affected_code: ["lib/src/bindings/repository.dart:629"]
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# Repository identity lookup silently ignores native failures

## Summary

The identity adapter ignores `git_repository_ident` status and returns an empty or partial list as if lookup succeeded.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Native failure is checked and translated before output pointers are read.
- Temporary pointers are released in guaranteed cleanup.
- Negative tests distinguish no configured identity from repository failure.

## Resolution

Pending approved fix workflow.
