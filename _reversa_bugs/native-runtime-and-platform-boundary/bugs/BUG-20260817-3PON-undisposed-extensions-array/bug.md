---
schema_version: 1
id: BUG-20260817-3PON
display_number: 4
title: Libgit2 extensions getter leaks native string array storage
status: open
phase: triaging
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-17
origin:
  type: inspection
  external_ref: null
area: native-integration
module: native-runtime-and-platform-boundary
feature: native-runtime-and-platform-boundary
labels: [native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [reading Libgit2.extensions]
blocking: []
relationships: []
traceability:
  specs:
    - "_reversa_sdd/native-runtime-and-platform-boundary/requirements.md#non-functional-requirements"
    - "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code:
    - "lib/src/libgit2.dart:521"
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

# Libgit2 extensions getter leaks native string array storage

## Summary

The extensions getter releases the outer allocation but not the native strings returned inside the array.

## Expected Behavior

The memory safety requirement and ADR-003 require the matching native disposer for manually returned temporary data.

## Actual Behavior

`Libgit2.extensions` frees only the `calloc<git_strarray>()` allocation. Other repository adapters handling native output string arrays call `git_strarray_dispose` before their arena or outer allocation is released.

## Steps to Reproduce

1. Read `Libgit2.extensions`.
2. Trace the native output through the Dart conversion.
3. Observe `calloc.free(array)` without `git_strarray_dispose(array)`.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Manual temporary ownership in the global extensions getter.

## Acceptance Criteria

- The matching native string-array disposer runs on success and conversion failure.
- Repeated getter calls show no growth under native allocation instrumentation.
- Returned Dart strings remain valid after native disposal.

## Traceability

- Specs: native memory safety NFR and ADR-003.
- Code: `lib/src/libgit2.dart:521-535`.

## Resolution

Pending `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

This finding is confirmed by comparison with existing correct disposal patterns in the same repository.
