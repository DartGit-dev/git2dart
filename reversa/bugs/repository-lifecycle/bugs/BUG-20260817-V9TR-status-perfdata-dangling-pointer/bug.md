---
schema_version: 1
id: BUG-20260817-V9TR
display_number: 29
title: Status performance data returns an arena-freed pointer
status: resolved
phase: closed
severity: critical
priority: P0
created: 2026-08-17
updated: 2026-08-27
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
  specs: ["reversa/sdd/repository-lifecycle/design.md#observability", "reversa/sdd/repository-lifecycle/edge-cases.md#native-ownership-and-lifecycle", "reversa/sdd/addenda/bug-BUG-20260817-V9TR-v001.md"]
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
      - {ref: "evidence/current-head-audit.md", observation: "Current HEAD retains version initialization, managed copying, the approved tests, and the approved spec addendum."}
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
    artifact: "reversa/sdd/addenda/bug-BUG-20260817-V9TR-v001.md"
    purpose: "Define the status perfdata initialization and managed ownership contract."
    diff: "fix/CHG-003.diff"
delivery:
  branch: "0.5.5"
  commit: "764fbd712fb6065bcfee9e5179c57530c3eb5c16"
  superseded_recorded_commit: "6d65b30ce2ed7e8e8a531930834195e94328a74b"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: "USER-CONFIRMED on 2026-08-29; package registry not independently verified"
versions:
  fixed_in: "0.5.5"
backports: []
closure: {policy: package, satisfied: true}
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
`reversa/sdd/addenda/bug-BUG-20260817-V9TR-v001.md`; the original
specifications remain unchanged.

| Change | Kind | Artifact | Diff |
| --- | --- | --- | --- |
| CHG-001 | test | `test/repository_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/status.dart` | `fix/CHG-002.diff` |
| CHG-003 | specification | `reversa/sdd/addenda/bug-BUG-20260817-V9TR-v001.md` | `fix/CHG-003.diff` |

Red proof: the function type exposed `Pointer<git_diff_perfdata>`, and the
runtime call failed with `invalid version 0`. Green proof: 2 focused tests and
46 repository tests passed, static analysis found no issues, and the full suite
passed 931 tests with 24 skips.

### Current HEAD audit

The code, tests, and approved `spec-gap` addendum are present on current HEAD.
The originally recorded delivery commit was superseded by equivalent commit
`764fbd7`, which is contained by both local and `origin/0.5.5`. The smallest
current validation (`flutter test -j 1 test/repository_test.dart --plain-name
"status performance"`) passed both targeted tests. See
`evidence/current-head-audit.md`.

No persistent data was affected, so no data repair is required. Package closure
is not satisfied until the correction is merged and a fixed package version is
published. The bug therefore remains active in the delivering phase.
