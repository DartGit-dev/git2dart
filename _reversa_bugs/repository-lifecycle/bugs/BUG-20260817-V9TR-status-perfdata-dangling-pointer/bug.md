---
schema_version: 1
id: BUG-20260817-V9TR
display_number: 29
title: Status performance data returns an arena-freed pointer
status: active
phase: delivering
severity: critical
priority: P0
created: 2026-08-17
updated: 2026-08-21
origin: {type: inspection, external_ref: null}
area: native-integration
module: repository-lifecycle
feature: repository-lifecycle
labels: [status, perfdata, use-after-free, ffi]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 calls", suspected_triggers: [reading status list performance data]}
blocking: []
relationships: []
traceability:
  specs: ["_reversa_sdd/repository-lifecycle/design.md#observability", "_reversa_sdd/repository-lifecycle/edge-cases.md#native-ownership-and-lifecycle", "_reversa_sdd/addenda/bug-BUG-20260817-V9TR-v001.md"]
  affected_code: ["lib/src/bindings/status.dart:134-140"]
  root_cause:
    state: confirmed
    hypothesis: "listPerfdata leaves the perfdata version at zero and returns its Arena-managed output pointer after using has released the Arena."
    causal_path:
      - "listPerfdata allocates git_diff_perfdata through the callback Arena."
      - "The allocation remains zero-initialized, including its required version field, so libgit2 rejects the call before producing counters."
      - "After the version is initialized, the native call can write valid counters into that allocation."
      - "The callback returns the allocation pointer instead of copying its fields."
      - "ffi using executes arena.releaseAll in finally before the caller receives the pointer."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The returned pointer is allocated by the local Arena."}
      - {ref: "evidence/reproduction.md", observation: "The structural invariant reproduced 1/1 and the installed FFI source closes the release path."}
      - {ref: "evidence/red-tests.md", observation: "The approved runtime tests fail because libgit2 rejects version 0 before either ownership assertion can execute."}
    code_refs:
      - {file: "lib/src/bindings/status.dart", symbol: "listPerfdata", commit: "ca9e4a6810793028d245bc9a404f4d970e5ac8cd"}
  reproduction_tests:
    - "test/repository_test.dart::does not expose a pointer for status performance data"
  regression_tests:
    - "test/repository_test.dart::keeps status performance counters readable after return"
regression_analysis:
  good_commit: "f87ce8db749ddf5f83eb2d0f3d0654c5993f01bf"
  culprit_commit: "ca9e4a6810793028d245bc9a404f4d970e5ac8cd"
  method: "git log -S, parent comparison, and an isolated six-step git bisect"
change_risk:
  classification: low
  reasons:
    - "The defect is isolated to one private binding helper with no current call sites."
    - "An identical managed-value pattern already exists in the diff binding."
    - "The change is local, reversible, and has no persistent data impact."
spec_verdict: spec-gap
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/repository_test.dart"
    purpose: "Reject the raw pointer return contract and verify readable managed counters."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: code
    artifact: "lib/src/bindings/status.dart"
    purpose: "Initialize perfdata version and copy native counters into a managed Dart value."
    diff: "fix/CHG-002.diff"
  - id: CHG-003
    kind: specification
    artifact: "_reversa_sdd/addenda/bug-BUG-20260817-V9TR-v001.md"
    purpose: "Define the status perfdata initialization and managed ownership contract."
    diff: "fix/CHG-003.diff"
delivery:
  branch: "0.5.5"
  commit: null
  pull_request: null
  merge: pending
  publication: pending
versions:
  fixed_in: null
backports: []
closure: {policy: package, satisfied: false}
resolution_kind: fixed
---

# Status performance data returns an arena-freed pointer

## Summary

`listPerfdata` passes an unversioned output structure to libgit2 and returns a pointer allocated inside `using`; the arena frees that pointer before the caller can read it.

## Expected Behavior

Performance data must be copied into a Dart value or returned with a valid owner.

## Actual Behavior

Libgit2 first rejects the zero structure version. Once that is corrected, the function exits the arena and returns its freed allocation, creating a deterministic dangling pointer.

## Evidence

- `evidence/static-analysis.md`
- `evidence/reproduction.md`
- `evidence/red-tests.md`
- `evidence/green-tests.md`

## Acceptance Criteria

- No pointer outlives its arena.
- The API returns managed values or explicit owned storage.
- Tests reject the raw pointer return contract and read managed performance counters.

## Resolution

The root cause is confirmed. The helper neither initialized the required native
structure version nor converted the Arena-owned result into a managed Dart
value. The correction initializes `GIT_DIFF_PERFDATA_VERSION` and copies both
counters into `StatusPerfData` before the Arena is released.

The user approved `spec-gap`. The new behavior is specified by
`_reversa_sdd/addenda/bug-BUG-20260817-V9TR-v001.md`; the original
specifications remain unchanged.

| Change | Kind | Artifact | Diff |
| --- | --- | --- | --- |
| CHG-001 | test | `test/repository_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/status.dart` | `fix/CHG-002.diff` |
| CHG-003 | specification | `_reversa_sdd/addenda/bug-BUG-20260817-V9TR-v001.md` | `fix/CHG-003.diff` |

Red proof: the function type exposed `Pointer<git_diff_perfdata>`, and the
runtime call failed with `invalid version 0`. Green proof: 2 focused tests and
46 repository tests passed, static analysis found no issues, and the full suite
passed 931 tests with 24 skips.

No persistent data was affected, so no data repair is required. Package closure
is not satisfied until the correction is merged and a fixed package version is
published. The bug therefore remains active in the delivering phase.
