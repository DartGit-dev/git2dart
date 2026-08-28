---
schema_version: 1
id: BUG-20260817-N4FC
display_number: 27
title: Worktree list leaks every looked-up native worktree handle
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
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
  specs: ["reversa/sdd/repository-lifecycle/flows.md#fl-rl-09-manage-a-linked-worktree", "reversa/sdd/repository-lifecycle/flows.md#fl-rl-12-release-native-ownership"]
  affected_code: ["lib/src/bindings/worktree.dart:148", "lib/src/worktree.dart:64"]
  root_cause:
    state: confirmed
    hypothesis: "The public worktree-list projection discarded binding-owned git_worktree handles after reading their names."
    causal_path: "Each list entry was looked up as an owning native handle; name projection returned only strings and the historical public method never freed those handles."
    evidence:
      - "evidence/static-analysis.md"
      - "evidence/current-head-audit.md"
      - "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"
  reproduction_tests:
    - path: "evidence/static-analysis.md"
      kind: static-historical-path
      result: reproduced-by-inspection
  regression_tests:
    - path: "test/worktree_test.dart"
      command: "flutter test -j 1 test/worktree_test.dart"
      result: "16 passed"
spec_verdict: spec-correta
change_set:
  - id: CHG-001
    kind: code
    path: lib/src/worktree.dart
    commit: e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca
    diff: fix/CHG-001.diff
    summary: "Free every binding-owned worktree handle in a finally block after copying its name."
closure: {policy: package, satisfied: false}
resolution_kind: fixed
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

Historically, `Worktree.list` read names from binding-owned `git_worktree` handles and discarded the handles. Commit `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` adds a `try/finally` that releases every returned worktree after name projection, including exceptional paths. Current-head inspection confirms the correction is still present.

`flutter test -j 1 test/worktree_test.dart` passed all 16 tests, and focused `flutter analyze` passed with no issues. Allocation-growth instrumentation is not exposed by this local harness; the deterministic ownership proof is the `finally` release loop paired with the behavior suite.

The effective specification already requires explicit native-resource release, so the default verdict is `spec-correta`. The correction is contained by local `HEAD` and `origin/0.5.5`; package publication remains required by closure policy, so this record remains `active/delivering`.

### Delivery

- Branch: `0.5.5`
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca`
- Containment: verified in local `HEAD` and `origin/0.5.5`
- Local audit: `evidence/current-head-audit.md`
- Publication: pending; no version/backport has been published or claimed
