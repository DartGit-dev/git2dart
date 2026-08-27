---
schema_version: 1
id: BUG-20260817-X4AE
display_number: 21
title: Commit buffer operations do not dispose libgit2 storage
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
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
  root_cause:
    state: confirmed
    hypothesis: "Commit buffer operations copied libgit2-managed git_buf values while the historical paths omitted disposal of their internal storage."
    causal_path: ["native operation fills buffer", "Dart copies text", "outer arena releases structure", "internal libgit2 buffer remains live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original serialization and signature paths omitted matching buffer disposal."}
      - {ref: "evidence/current-head-audit.md", observation: "Current paths dispose every buffer in finally after success or error translation."}
    code_refs:
      - {file: "lib/src/bindings/commit.dart", symbol: "createBuffer and extractSignature", commit: "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"}
  reproduction_tests: ["test/commit_test.dart#throws when trying to write commit into a buffer and error occurs"]
  regression_tests: ["test/commit_test.dart#writes commit without parents into the buffer", "test/commit_test.dart#writes commit into the buffer"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/commit_test.dart", purpose: "Exercise local commit-buffer success and error behavior.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/commit.dart", purpose: "Dispose libgit2 buffers in finally after conversion or error translation.", evidence: "evidence/current-head-audit.md"}
closure: {policy: package, satisfied: false}
resolution_kind: fixed
delivery:
  branch: "0.5.5"
  commit: "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
versions:
  fixed_in: null
backports: []
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

The confirmed root cause was omission of internal native-buffer disposal after
Dart conversion. Current commit serialization and signature extraction dispose
their libgit2 buffers in `finally`, covering success and a translated native
error. The required plan is recorded in `fix/plan.html`.

Focused local commit success and error tests pass with focused analysis clean.
No current source or test gap was demonstrated, so this audit applied no code
or test diff. The authorized evidence-based verdict is `spec-correta`: the
existing design and ADR-003 already require native buffer disposal.

Commit `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
