---
schema_version: 1
id: BUG-20260817-ZC7X
display_number: 1
title: Libgit2 initialization refcount is never balanced by shutdown
status: active
phase: planning
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-22
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
  classification: deterministic
  rate: "1/1; initialization probe increased 2 -> 3 -> 4"
  suspected_triggers: [repeated public API calls]
blocking:
  - "The native lifecycle and library-loading contract must be implemented first as a new Reversa feature in git2dart_binaries."
relationships:
  - bug: BUG-20260817-3PON
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "reversa/sdd/native-runtime-and-platform-boundary/flows.md#fl-np-02-explicit-and-fallback-release"
  affected_code:
    - "lib/src/libgit2.dart"
    - "lib/src/repository.dart"
    - "lib/src/merge.dart:266"
  root_cause:
    state: confirmed
    hypothesis: "Public entry points call reference-counted git_libgit2_init repeatedly, but the package has no git_libgit2_shutdown path."
    causal_path:
      - "Sixty-six public constructors, getters, and operations call git_libgit2_init."
      - "libgit2 increments and returns a process-global initialization count for every call."
      - "No package source path calls git_libgit2_shutdown."
      - "Repeated public calls therefore grow the native initialization count without a balancing lifecycle."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "Fresh scan finds 66 init calls and zero shutdown calls under lib/."}
      - {ref: "evidence/reproduction.md", observation: "Two Libgit2.version calls increased the isolated native probe count from 2 to 3 to 4."}
      - {ref: "evidence/companion-eager-init.md", observation: "The companion package owns native loading and its exported binding currently performs an eager init in each isolate, so the lifecycle correction belongs in git2dart_binaries."}
    code_refs:
      - {file: "lib/src/libgit2.dart", symbol: "Libgit2.version and global option entry points", commit: "0933dbf4af4e3fcf5cab067f757a365c24ad510a"}
      - {file: "lib/src/repository.dart", symbol: "Repository constructors", commit: "0933dbf4af4e3fcf5cab067f757a365c24ad510a"}
  reproduction_tests:
    - "evidence/reproduction_test.dart"
  regression_tests:
    - "fix/CHG-001.diff (approved RED consumer contract; not active in the working test suite)"
spec_verdict: null
change_risk:
  classification: high
  reasons:
    - "The correction changes process-global native lifecycle behavior across 66 call sites."
    - "Repository wrappers, pure global calls, platform bootstrap, and multiple Dart isolates have different lifetime requirements."
    - "Premature shutdown could invalidate live native objects, while missing shutdown preserves the leak."
change_set:
  - id: CHG-001
    kind: test
    artifact: fix/CHG-001.diff
    purpose: "Preserve the approved RED consumer contract for adaptation after git2dart_binaries exposes the lifecycle API."
    diff: fix/CHG-001.diff
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
- `evidence/reproduction.md`
- `evidence/reproduction_test.dart`
- `evidence/root-cause.md`

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

The git2dart-side Gate 2 plan is superseded. Implementation must begin as a new
Reversa feature in `git2dart_binaries`; this package will consume the resulting
public lifecycle API without loading or locating native libraries itself.

## Agent Notes

No source code was changed during inspection or debate. Fresh Flutter
reproduction completed deterministically on 2026-08-21, so the former external
tool-lock blocker no longer applies. The approved repair strategy is the
isolated judge's Candidate A synthesis in `debate/resposta-final.md`; source
changes remain gated by approval of `fix/plan.html`, Gate 1, and Gate 2.

Gate 1 was approved and applied on 2026-08-22, producing the expected compile
failure recorded in `evidence/gate-1-red.md`. Before commit, the RED test was
withdrawn from the active suite because its missing contract must be supplied
by `git2dart_binaries`; the approved patch remains in `fix/CHG-001.diff` for
later adaptation.

The earlier Gate 2 source proposal and its isolated validation are superseded:
they duplicated native library loading inside `git2dart`, violating the
confirmed package boundary. No Gate 2 production source remains in this
workspace. The next action is a new Reversa feature in `git2dart_binaries` to
own native loading, the process-level init/shutdown refcount, isolate behavior,
and the public lifecycle contract. After that feature passes its own gates,
`git2dart` should consume the API and add compatible regression coverage.
