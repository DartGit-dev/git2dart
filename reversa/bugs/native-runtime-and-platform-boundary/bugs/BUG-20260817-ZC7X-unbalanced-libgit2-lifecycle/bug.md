---
schema_version: 1
id: BUG-20260817-ZC7X
display_number: 1
title: Libgit2 initialization refcount is never balanced by shutdown
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
labels: [native-lifecycle, resource-retention]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1; initialization probe increased 2 -> 3 -> 4"
  suspected_triggers: [repeated public API calls]
blocking: []
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
      - {ref: "evidence/companion-lifecycle-contract.md", observation: "Companion commit ea87cf2 implements the managed lifecycle API and clears the prerequisite for a separately gated git2dart consumer migration."}
    code_refs:
      - {file: "lib/src/libgit2.dart", symbol: "Libgit2.version and global option entry points", commit: "0933dbf4af4e3fcf5cab067f757a365c24ad510a"}
      - {file: "lib/src/repository.dart", symbol: "Repository constructors", commit: "0933dbf4af4e3fcf5cab067f757a365c24ad510a"}
  reproduction_tests:
    - "evidence/reproduction_test.dart"
    - "test/libgit2_lifecycle_source_test.dart"
  regression_tests:
    - "fix/CHG-001.diff (historical approved RED contract; superseded and not active in the working test suite)"
    - "test/libgit2_lifecycle_test.dart"
spec_verdict: spec-correta
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
    purpose: "Preserve the historical approved RED contract; it is superseded by the refreshed consumer CHG-002 plan."
    diff: fix/CHG-001.diff
  - id: CHG-002
    kind: test
    artifact: "test/libgit2_lifecycle_source_test.dart and test/libgit2_lifecycle_test.dart"
    purpose: "Prove the removed-global migration and the managed lifecycle consumer contract."
    diff: fix/CHG-002.diff
  - id: CHG-003
    kind: migration
    artifact: "Managed runtime API migration across 58 source and test files"
    purpose: "Replace removed companion globals and all direct initialization increments with the companion-owned managed runtime API."
    diff: fix/CHG-003.diff
  - id: CHG-004
    kind: code
    artifact: "lib/src/helpers/native_owner.dart, lib/src/repository.dart, and lib/src/commit.dart"
    purpose: "Guard Repository and independently usable Commit owners with exact-once runtime leases."
    diff: fix/CHG-004.diff
  - id: CHG-005
    kind: api-contract
    artifact: "lib/src/libgit2.dart, README.md, and doc/types/libgit2.md"
    purpose: "Expose and document guarded terminal shutdown and owner-release behavior."
    diff: fix/CHG-005.diff
  - id: CHG-006
    kind: dependency
    artifact: "pubspec.yaml and tool/api_diff/git2dart_binaries.baseline"
    purpose: "Require the companion 1.12.2 managed-runtime contract."
    diff: fix/CHG-006.diff
closure:
  policy: package
  satisfied: false
resolution_kind: fixed
delivery:
  branch: "0.5.5"
  commit: "131f7c8f405fd818affd1bf4cc3fd60cd2b52f60"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
  compatible_companion: unavailable-on-pub-dev
versions: {fixed_in: null}
backports: []
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
- `evidence/companion-lifecycle-contract.md`
- `evidence/consumer-plan-approval.md`
- `evidence/gate-1-chg-002-approval.md`
- `evidence/gate-1-chg-002-red.md`
- `evidence/gate-2-proposal-validation.md`
- `evidence/gate-2-approval.md`
- `evidence/gate-2-green.md`
- `evidence/spec-verdict-recommendation.md`
- `evidence/spec-verdict.md`
- `evidence/delivery-status.md`

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

### Root cause

Confirmed. Sixty-six public constructors, getters, and operations repeatedly
called reference-counted `git_libgit2_init()` while the package exposed no
balancing shutdown path. The companion package now owns the managed runtime;
the consumer correction removes the uncontrolled increments and uses that
single lifecycle boundary without duplicating native loading.

### Specification verdict

`spec-correta`, selected by the user on 2026-08-23. FR-NP-01 already requires
libgit2 initialization and shutdown, FR-NP-05 requires exactly one
owner/destructor path, and FL-NP-02 defines explicit release, finalizer
fallback, and ownership transfer. The code diverged from the effective
specification. No specification or addendum was changed.

### Correction change set

| Change | Kind | Artifact | Purpose | Diff |
| --- | --- | --- | --- | --- |
| CHG-002 | test | `test/libgit2_lifecycle_source_test.dart`; `test/libgit2_lifecycle_test.dart` | Prove removed-global migration and managed lifecycle behavior. | `fix/CHG-002.diff` |
| CHG-003 | migration | 58 managed-runtime source/test consumers | Replace removed globals and direct initialization increments with the companion runtime API. | `fix/CHG-003.diff` |
| CHG-004 | code | `lib/src/helpers/native_owner.dart`; `lib/src/repository.dart`; `lib/src/commit.dart` | Guard Repository and independently usable Commit owners with exact-once leases. | `fix/CHG-004.diff` |
| CHG-005 | api-contract | `lib/src/libgit2.dart`; `README.md`; `doc/types/libgit2.md` | Expose and document guarded terminal shutdown. | `fix/CHG-005.diff` |
| CHG-006 | dependency | `pubspec.yaml`; `tool/api_diff/git2dart_binaries.baseline` | Require the companion 1.12.2 managed-runtime contract. | `fix/CHG-006.diff` |

The historical CHG-001 RED contract is superseded and is not part of the
active applied resolution.

### Red-to-green proof

- RED: the approved CHG-002 tests exited 1 because production still referenced
  removed `libgit2`/`libgit2Opts` globals and `Libgit2.shutdown()` did not
  exist. See `evidence/gate-1-chg-002-red.md`.
- GREEN scoped lifecycle: 8/8 tests passed.
- GREEN bounded Repository/Commit/Libgit2 suites: 111/111 tests passed.
- GREEN static validation: `flutter analyze lib test` reported no issues.
- The Windows proof used the direct companion checkout for Dart lifecycle code
  and hosted 1.12.1 only for the missing DLL payload. It does not prove the
  wider owner inventory, full suite, other platforms, or CI.

### Data and delivery

No persistent data is changed and no data repair is required. The approved
consumer change set is committed as
`131f7c8f405fd818affd1bf4cc3fd60cd2b52f60` directly on branch `0.5.5`.
Current-head audit confirms the lifecycle correction remains contained by
local and origin `0.5.5`, and all focused lifecycle tests remain green. No
fixed `git2dart` package version is published. The current consumer constraint
is `git2dart_binaries >=1.13.0 <1.14.0`, while pub.dev currently publishes
only 1.12.1; green local tests resolve cached 1.13.0 instead. See
`evidence/current-head-audit.md` and `evidence/delivery-status.md`.

The package closure policy therefore remains unsatisfied. The bug stays
`active` in `delivering`, `versions.fixed_in` remains null, and no `DONE.md`
lock may be created until compatible companion and consumer versions are
published.

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
workspace. The companion feature is now available at commit `ea87cf2` and its
own Gate 2 is GREEN on Windows. The original blocker is cleared, but the
companion evidence explicitly leaves the `git2dart` consumer gate closed. The
next mandatory checkpoint is approval of the refreshed consumer-only plan,
followed by a newly adapted Gate 1 test diff.

The refreshed consumer-only plan was approved on 2026-08-23 with the exact
phrase `APPROVE PLAN ZC7X CONSUMER`. CHG-002 is now prepared as the complete,
formatted, apply-clean proposal in `fix/CHG-002.proposed.diff`; it adds
`test/libgit2_lifecycle_source_test.dart` and
`test/libgit2_lifecycle_test.dart`. Neither test file has been applied. The
workflow is paused at the distinct Gate 1 human approval.

Gate 1 CHG-002 was approved and applied on 2026-08-23. The scoped run produced
the required RED result recorded in `evidence/gate-1-chg-002-red.md`.
Production/dependency diffs CHG-003 through CHG-006 were then constructed and
validated only in a disposable ordinary clone. They remain unapplied. The
bounded proposal is paused at Gate 2; its proof boundary, including the local
checkout's missing Windows DLL payload and the still-unassigned companion
1.12.2 package contract, is recorded in
`evidence/gate-2-proposal-validation.md`.

Gate 2 was approved on 2026-08-23 with the exact phrase
`APPROVE GATE 2 ZC7X`, authorizing only the previously presented CHG-003
through CHG-006 proposals. All four diffs were applied in order and saved as
byte-identical `fix/CHG-003.diff` through `fix/CHG-006.diff`. Formatting changed
none of the 62 touched Dart files. `flutter analyze lib test`, all 8 scoped
lifecycle tests, and all 111 bounded Repository/Commit/Libgit2 tests passed.
The Windows run used the direct companion checkout for Dart API/lifecycle code
and hosted 1.12.1 only for its missing DLL payload. The wider owner inventory,
cross-platform/full-suite validation, compatible 1.12.2 publication, merge,
and release remain outside the proof. The workflow is paused for the mandatory
human specification verdict; no specification has been changed.

The user selected `spec-correta` on 2026-08-23. The verdict is recorded in
`evidence/spec-verdict.md`; no specification or addendum was changed. With the
confirmed root cause, applied regression coverage, GREEN proof, and approved
verdict, `resolution_kind` is now `fixed`. Package delivery remains open:
the consumer change set is committed and present on `origin/0.5.5`, but there
is no published compatible companion 1.12.2 package and no published consumer
version containing the fix. Closure remains unsatisfied and the phase is
`delivering`.
