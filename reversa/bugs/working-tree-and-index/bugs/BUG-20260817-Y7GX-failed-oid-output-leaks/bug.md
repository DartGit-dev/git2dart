---
schema_version: 1
id: BUG-20260817-Y7GX
display_number: 17
title: Failed index stash and diff OID operations leak output buffers
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
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
    - "reversa/sdd/working-tree-and-index/design.md#ownership-and-errors"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/bindings/index.dart:128", "lib/src/bindings/index.dart:145", "lib/src/bindings/stash.dart:26", "lib/src/bindings/stash.dart:57", "lib/src/bindings/diff.dart:300"]
  root_cause:
    state: confirmed
    hypothesis: "Five OID-producing adapters allocated output before a fallible native call and originally propagated errors without releasing that output."
    causal_path: ["adapter allocates output OID", "native operation returns error", "error translation throws", "unreleased OID remains live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original five adapters lacked failure cleanup."}
      - {ref: "evidence/current-head-audit.md", observation: "Each current adapter frees the output in catch before rethrowing and returns it only on success."}
    code_refs:
      - {file: "lib/src/bindings/index.dart", symbol: "writeTree and writeTreeTo", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
      - {file: "lib/src/bindings/stash.dart", symbol: "save and saveWithOpts", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
      - {file: "lib/src/bindings/diff.dart", symbol: "patchOid", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
  reproduction_tests: ["test/index_test.dart#throws when trying to write tree to invalid repository", "test/stash_test.dart#throws when trying to save and error occurs"]
  regression_tests: ["test/index_test.dart", "test/stash_test.dart", "test/diff_test.dart"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/index_test.dart; test/stash_test.dart; test/diff_test.dart", purpose: "Exercise local OID-producing success and error paths.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/{index,stash,diff}.dart", purpose: "Release preallocated OID output before rethrowing native errors.", evidence: "evidence/current-head-audit.md"}
closure: {policy: package, satisfied: false}
resolution_kind: fixed
delivery:
  branch: "0.5.5"
  commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
versions:
  fixed_in: null
backports: []
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

The confirmed root cause was failure-path OID ownership being lost after a
native call threw. Current index write-tree, stash-save, and diff patch-ID
adapters return their output only on success and free it before rethrow on a
native failure. The required plan is recorded in `fix/plan.html`.

Focused local success and error-path suites pass with focused analysis clean.
No current source or test gap was demonstrated, so this audit applied no code
or test diff. The authorized evidence-based verdict is `spec-correta`: the
existing ownership design and ADR-003 already require temporary output release
before error propagation.

Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
