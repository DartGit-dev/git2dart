---
schema_version: 1
id: BUG-20260817-Q6JV
display_number: 28
title: Worktree lock inspection does not dispose reason buffer
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
labels: [worktree, git-buf, native-memory, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "locked worktree queries", suspected_triggers: [reading isLocked on a locked worktree]}
blocking: []
relationships:
  - {bug: BUG-20260817-K2RY, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/repository-lifecycle/flows.md#fl-rl-09-manage-a-linked-worktree", "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/worktree.dart:194"]
  root_cause:
    state: confirmed
    hypothesis: "The lock-state adapter returned before releasing a libgit2-populated git_buf used for the lock reason."
    causal_path: "A locked-worktree query could allocate native reason storage; the historical adapter returned the boolean result without git_buf_dispose."
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
      test: "locks and unlocks worktree"
      command: "flutter test -j 1 test/worktree_test.dart"
      result: "16 passed"
spec_verdict: spec-correta
change_set:
  - id: CHG-001
    kind: code
    path: lib/src/bindings/worktree.dart
    commit: e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca
    diff: fix/CHG-001.diff
    summary: "Dispose the git_buf reason storage in finally around the lock-state query."
closure: {policy: package, satisfied: false}
resolution_kind: fixed
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

Historically, the lock-state adapter returned the boolean result from `git_worktree_is_locked` without disposing the native reason buffer. Commit `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` encloses the query in `try/finally` and calls `git_buf_dispose(reason)` on every return and exception path. Current-head inspection confirms the correction is still present.

`flutter test -j 1 test/worktree_test.dart` passed all 16 tests, including the locked-state transition. Focused `flutter analyze` passed with no issues. The local harness does not expose allocator-growth instrumentation; the deterministic ownership proof is the `finally` disposal enclosing the native query.

The effective specification requires native output buffers to be disposed, so the default verdict is `spec-correta`. The correction is contained by local `HEAD` and `origin/0.5.5`; package publication remains required by closure policy, so this record remains `active/delivering`.

### Delivery

- Branch: `0.5.5`
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca`
- Containment: verified in local `HEAD` and `origin/0.5.5`
- Local audit: `evidence/current-head-audit.md`
- Publication: pending; no version/backport has been published or claimed
