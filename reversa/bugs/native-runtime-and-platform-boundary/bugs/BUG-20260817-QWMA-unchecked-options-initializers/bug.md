---
schema_version: 1
id: BUG-20260817-QWMA
display_number: 3
title: Native options initializer failures are ignored before structure use
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
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
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure:
  policy: package
  satisfied: false
resolution_kind: null
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

Pending `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

The exact mismatch behavior remains environment-dependent, but the unchecked negative path is statically complete.
