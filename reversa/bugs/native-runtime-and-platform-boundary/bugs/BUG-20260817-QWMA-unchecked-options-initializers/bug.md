---
schema_version: 1
id: BUG-20260817-QWMA
display_number: 3
title: Native options initializer failures are ignored before structure use
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-27
origin:
  type: inspection
  external_ref: null
area: native-integration
module: native-runtime-and-platform-boundary
feature: native-runtime-and-platform-boundary
labels: [abi, error-contract, native-options]
visibility: normal
security_suspected: false
reproduction:
  classification: environment-dependent
  rate: "0/0"
  suspected_triggers: [unsupported options version, ABI mismatch]
blocking:
  - kind: external
    reason: "A mismatched ABI harness and five-platform load matrix were not authorized or available."
    since: 2026-08-17
relationships: []
traceability:
  specs:
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "reversa/sdd/native-runtime-and-platform-boundary/tests.md#coverage-matrix"
    - "reversa/sdd/adrs/004-centralize-native-error-translation.md#decision"
    - "reversa/sdd/references-and-remotes/tests.md#coverage-matrix"
    - "reversa/sdd/working-tree-and-index/tests.md#coverage-matrix"
    - "reversa/sdd/history-and-integration-operations/tests.md"
    - "reversa/sdd/git-objects-and-object-database/tests.md"
    - "reversa/sdd/repository-lifecycle/tests.md"
  affected_code:
    - "lib/src/bindings/checkout.dart"
    - "lib/src/bindings/remote.dart"
    - "lib/src/bindings/repository.dart"
    - "lib/src/bindings/merge.dart"
    - "lib/src/bindings/submodule.dart"
    - "lib/src/bindings/diff.dart"
    - "lib/src/bindings/stash.dart"
    - "lib/src/bindings/reset.dart"
    - "lib/src/bindings/commit.dart"
    - "lib/src/bindings/blob.dart"
    - "lib/src/bindings/status.dart"
    - "lib/src/bindings/worktree.dart"
  root_cause:
    state: confirmed
    hypothesis: "Each fallible native options initializer must have its result checked before the initialized structure is populated, read, or passed to a dependent native call."
    causal_path: ["native options initializer", "negative ABI or version status", "unchecked status", "structure use", "undefined or false-success option behavior"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original inspection identified unchecked initializer paths across the binding layer."}
      - {ref: "evidence/current-head-audit.md", observation: "All 44 current *_options_init call sites across 16 binding files check their status before structure use; historical source contains the direct unchecked calls."}
    code_refs:
      - {file: "lib/src/bindings", symbol: "*_options_init", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
  reproduction_tests:
    - "test/checkout_test.dart"
    - "test/remote_test.dart"
    - "test/repository_test.dart"
    - "test/stash_test.dart"
    - "test/rebase_test.dart"
    - "test/blob_test.dart"
    - "test/diff_test.dart"
    - "test/commit_test.dart"
  regression_tests:
    - "evidence/current-head-audit.md#static-completeness"
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: code, artifact: "lib/src/bindings/{blob,checkout,commit,diff,merge,rebase,remote,repository,stash}.dart", purpose: "Check native initializer statuses before the affected options structures are used.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: test, artifact: "existing focused binding consumer suites", purpose: "Preserve option initialization and downstream native-operation behavior on the available runtime.", evidence: "evidence/current-head-audit.md"}
delivery:
  branch: "0.5.5"
  commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
  platform_matrix: pending
versions:
  fixed_in: null
backports: []
closure:
  policy: package
  satisfied: false
resolution_kind: fixed
---

# Native options initializer failures are ignored before structure use

## Summary

Binding adapters commonly ignore fallible native options initializer results and proceed to populate or pass the structure.

## Expected Behavior

FR-NP-03, FR-NP-04, FR-NP-09, and ADR-004 require safe initialization, immediate error translation, and ABI-compatible option layouts.

## Actual Behavior

Many adapters call functions such as `git_checkout_options_init`, `git_fetch_options_init`, and `git_merge_options_init` without checking the returned status. The same structures are then used by native operations.

## Steps to Reproduce

1. Search binding adapters for native functions ending in `_options_init`.
2. Compare unchecked calls with checked initializer patterns in patch, rebase, and apply bindings.
3. Observe that unchecked structures flow into subsequent native calls.

## Evidence

- `evidence/static-analysis.md`
- `evidence/references-and-remotes-occurrence.md`
- `evidence/working-tree-and-index-occurrence.md`
- `evidence/later-depth-inspection-occurrences.md`

## Suspected Area

Shared binding adapter initialization and ABI failure handling.

## Acceptance Criteria

- Every fallible native options initializer is checked before the structure is read or passed onward.
- Version mismatch tests fail before the dependent native operation.
- Current platform artifacts pass the required load and focused test matrix.

## Traceability

- Specs: FR-NP-03, FR-NP-04, FR-NP-09, native test coverage matrix.
- Code: option-using binding adapters.

## Resolution

The confirmed root cause is failure to translate a fallible options-initializer
status before the initialized structure is used. Current-head static audit
enumerates all 44 `*_options_init` call sites in 16 binding files and confirms
that each is checked before structure use. The corrective source is contained
by `1914a9053af88c6295fb58e6ed4e357dd8c27134`; see
`evidence/current-head-audit.md`.

The effective specification already requires immediate native error
translation, so the authorized evidence-based verdict is `spec-correta`; see
`evidence/spec-verdict.md`. The available focused suite and targeted analysis
are green. The external ABI mismatch harness and five-platform load matrix
remain unavailable, and package publication remains pending. Consequently the
bug is `active` / `delivering`; no source, test, or original specification was
changed by this audit.

## Agent Notes

The exact mismatch behavior remains environment-dependent, but the unchecked negative path is statically complete.
