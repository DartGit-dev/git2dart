---
schema_version: 1
id: BUG-20260817-ZC7X
display_number: 1
title: Libgit2 initialization refcount is never balanced by shutdown
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
labels: [native-lifecycle, resource-retention]
visibility: normal
security_suspected: false
reproduction:
  classification: not-reproduced
  rate: "0/0"
  suspected_triggers: [repeated public API calls]
blocking:
  - kind: external
    reason: "Focused runtime execution is blocked by stale Flutter tool locks outside the repository."
    since: 2026-08-17
relationships:
  - bug: BUG-20260817-3PON
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "_reversa_sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "_reversa_sdd/native-runtime-and-platform-boundary/flows.md#fl-np-02-explicit-and-fallback-release"
  affected_code:
    - "lib/src/libgit2.dart"
    - "lib/src/repository.dart"
    - "lib/src/merge.dart:266"
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

# Libgit2 initialization refcount is never balanced by shutdown

## Summary

The package repeatedly initializes libgit2 but exposes no matching shutdown path.

## Expected Behavior

FR-NP-01 requires a balanced initialize and shutdown lifecycle for the native runtime.

## Actual Behavior

Static inspection found 66 `git_libgit2_init()` calls under `lib/` and no `git_libgit2_shutdown()` call. Read-only getters such as `Libgit2.version` also increment the native initialization counter.

## Steps to Reproduce

1. Search `lib/` for `git_libgit2_init()`.
2. Search `lib/` and `test/` for `git_libgit2_shutdown()`.
3. Observe repeated initialization call sites and no balancing shutdown path.

## Evidence

- `evidence/static-analysis.md`
- `evidence/history-and-integration-occurrence.md`

## Suspected Area

Native runtime lifecycle management shared by all wrappers.

## Acceptance Criteria

- Every native initialization increment has a defined balancing lifecycle.
- Initialization failure is surfaced rather than ignored.
- Regression coverage proves repeated public API use does not grow an unbounded native initialization count.

## Traceability

- Specs: FR-NP-01 and FL-NP-02.
- Code: `lib/src/libgit2.dart`, `lib/src/repository.dart`, and other initialization call sites.

## Resolution

Pending `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

No source code was changed during inspection. Runtime reproduction remains blocked by external Flutter tool locks.
