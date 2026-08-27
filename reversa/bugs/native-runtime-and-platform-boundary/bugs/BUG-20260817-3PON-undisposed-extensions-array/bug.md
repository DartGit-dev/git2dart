---
schema_version: 1
id: BUG-20260817-3PON
display_number: 4
title: Libgit2 extensions getter leaks native string array storage
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
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
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#non-functional-requirements"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code:
    - "lib/src/libgit2.dart:521"
  root_cause:
    state: confirmed
    hypothesis: "The extensions getter converted a libgit2-owned string array but freed only its Dart outer allocation, omitting the matching native disposer."
    causal_path: ["extensions getter receives native string array", "Dart strings are converted", "outer allocation is freed", "native string-array storage remains live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original getter lacked the matching native disposer while comparable adapters used it."}
      - {ref: "evidence/current-head-audit.md", observation: "Current getter disposes the native array in finally before freeing outer storage."}
    code_refs:
      - {file: "lib/src/libgit2.dart", symbol: "Libgit2.extensions", commit: "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"}
  reproduction_tests: []
  regression_tests: ["test/libgit2_test.dart#sets and returns the list of git extensions"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/libgit2_test.dart", purpose: "Exercise the local extension getter/setter round trip.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/libgit2.dart", purpose: "Dispose the native extension string array in finally before freeing outer storage.", evidence: "evidence/current-head-audit.md"}
closure:
  policy: package
  satisfied: false
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

The confirmed root cause was a missing native string-array disposer after Dart
conversion. Current `Libgit2.extensions` converts the values, then calls
`git_strarray_dispose` in `finally` before freeing its outer allocation. The
required plan is recorded in `fix/plan.html`.

Focused local extension behavior and analysis are green. No current source or
test gap was demonstrated, so this audit applied no code or test diff. The
authorized evidence-based verdict is `spec-correta`: the existing memory
safety requirement and ADR-003 already require the matching native disposer.

Commit `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.

## Agent Notes

This finding is confirmed by comparison with existing correct disposal patterns in the same repository.
