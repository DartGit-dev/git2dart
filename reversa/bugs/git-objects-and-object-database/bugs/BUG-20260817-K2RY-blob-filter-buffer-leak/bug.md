---
schema_version: 1
id: BUG-20260817-K2RY
display_number: 25
title: Blob filtering does not dispose libgit2 buffer storage
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
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
  specs: ["reversa/sdd/git-objects-and-object-database/design.md", "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/blob.dart:229"]
  root_cause:
    state: confirmed
    hypothesis: "Blob filtering copied a libgit2-owned buffer without disposing its internal native storage."
    causal_path: ["filter fills native buffer", "Dart copies buffer content", "outer arena releases structure", "internal libgit2 storage remains live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original filter path omitted the matching native buffer disposer."}
      - {ref: "evidence/current-head-audit.md", observation: "Current filter disposes the native buffer in finally after success or error translation."}
    code_refs:
      - {file: "lib/src/bindings/blob.dart", symbol: "filterContent", commit: "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"}
  reproduction_tests: ["test/blob_test.dart#throws when trying to filter content of a blob and error occurs"]
  regression_tests: ["test/blob_test.dart#filters content of a blob", "test/blob_test.dart#filters content of a blob with provided commit for attributes"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/blob_test.dart", purpose: "Exercise local blob-filter success and error behavior.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/blob.dart", purpose: "Dispose the libgit2 filter buffer in finally.", evidence: "evidence/current-head-audit.md"}
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

# Blob filtering does not dispose libgit2 buffer storage

## Summary

Blob filtering copies a returned `git_buf` but does not dispose its internal native storage.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- The buffer is disposed after copying and on any partially initialized failure path.
- Repeated filtering instrumentation shows no growth.

## Resolution

The confirmed root cause was omission of the native buffer disposer after Dart
conversion. Current blob filtering translates the native result and disposes
the buffer in `finally`, so both success and throwing paths release internal
libgit2 storage. The required plan is recorded in `fix/plan.html`.

Focused local blob success and error tests pass with focused analysis clean. No
current source or test gap was demonstrated, so this audit applied no code or
test diff. The authorized evidence-based verdict is `spec-correta`: the
existing ownership design and ADR-003 already require native buffer disposal.

Commit `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
