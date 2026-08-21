---
schema_version: 1
id: BUG-20260817-O3B3
display_number: 6
title: Remote failure cleanup retains sensitive callback context
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-21
origin:
  type: inspection
  external_ref: null
area: native-integration
module: native-runtime-and-platform-boundary
feature: native-runtime-and-platform-boundary
labels: [restricted-security-review, callback-cleanup]
visibility: restricted
security_suspected: true
reproduction:
  classification: deterministic
  rate: "3/3 isolated local failures"
  suspected_triggers: [remote operation failure]
blocking: []
relationships:
  - bug: BUG-20260817-47ZS
    type: related-to
    state: confirmed
    evidence:
      - "evidence/reproduction.md"
      - "../BUG-20260817-47ZS-unreleased-credential-callback-allocations/evidence/root-cause.md"
  - bug: BUG-20260817-CIKD
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "reversa/sdd/native-runtime-and-platform-boundary/flows.md#fl-np-06-native-callback"
  affected_code:
    - "lib/src/bindings/remote.dart"
    - "lib/src/bindings/repository.dart"
    - "lib/src/bindings/remote_callbacks.dart"
    - "lib/src/bindings/submodule.dart"
    - "lib/src/remote.dart"
  root_cause:
    state: confirmed
    hypothesis: "Remote callback state cleanup is sequenced only on normal completion instead of being guaranteed for every exit."
    causal_path:
      - "A remote operation installs callback state before entering native code."
      - "Selected failure paths translate the native error before cleanup runs."
      - "The thrown error bypasses cleanup and leaves callback state retained."
    evidence:
      - {ref: "evidence/restricted-static-analysis.md", observation: "Control-flow inspection identified cleanup-bypassing exits."}
      - {ref: "evidence/reproduction.md", observation: "Three isolated local failures reproduced retained callback state."}
    code_refs:
      - {file: "lib/src/bindings/remote.dart", symbol: "connect, fetch, and push", commit: "9683aa78b8eba77da50965d3a635005b6030d431"}
      - {file: "lib/src/bindings/repository.dart", symbol: "clone", commit: "9683aa78b8eba77da50965d3a635005b6030d431"}
  reproduction_tests: []
  regression_tests:
    - "test/callbacks_test.dart"
    - "test/remote_test.dart"
    - "test/repository_clone_test.dart"
    - "test/submodule_test.dart"
spec_verdict: spec-correta
change_risk:
  classification: high
  reasons:
    - "The cleanup contract is shared by remote connect, fetch, push, repository clone, and submodule operations."
    - "The retained state can include authentication context and therefore requires restricted handling."
    - "The separate process-static callback concurrency defect remains outside this correction."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/callbacks_test.dart"
    purpose: "Prove synchronous lexical cleanup on success, Dart error, callback-bridge error, and repeated reset."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: test
    artifact: "test/remote_test.dart"
    purpose: "Prove repeated local fetch failures clear callback state without losing the translated error."
    diff: "fix/CHG-002.diff"
  - id: CHG-003
    kind: test
    artifact: "test/repository_clone_test.dart"
    purpose: "Prove both repository-clone callback-data fields clear after a controlled failure."
    diff: "fix/CHG-003.diff"
  - id: CHG-004
    kind: test
    artifact: "test/submodule_test.dart"
    purpose: "Prove submodule callback postconditions and two-site lexical migration completeness."
    diff: "fix/CHG-004.diff"
  - id: CHG-005
    kind: code
    artifact: "lib/src/bindings/remote_callbacks.dart"
    purpose: "Add the internal synchronous callback-state lexical owner."
    diff: "fix/CHG-005.diff"
  - id: CHG-006
    kind: code
    artifact: "lib/src/bindings/remote.dart"
    purpose: "Migrate remote connect, fetch, and push with immediate error translation inside the cleanup scope."
    diff: "fix/CHG-006.diff"
  - id: CHG-007
    kind: code
    artifact: "lib/src/bindings/repository.dart"
    purpose: "Migrate clone and both clone callback-data assignments into the lexical scope."
    diff: "fix/CHG-007.diff"
  - id: CHG-008
    kind: code
    artifact: "lib/src/bindings/submodule.dart"
    purpose: "Migrate submodule update and clone into the lexical scope."
    diff: "fix/CHG-008.diff"
delivery:
  branch: "0.5.5"
  commit: null
  pull_request: null
  merge: pending
  publication: pending
versions:
  fixed_in: null
backports: []
closure:
  policy: package
  satisfied: false
resolution_kind: fixed
---

# Remote failure cleanup retains sensitive callback context

## Summary

Failure cleanup does not promptly clear sensitive callback context.

## Expected Behavior

FR-NP-08 requires callback state to remain operation-scoped and to be cleaned on every exit path.

## Actual Behavior

Static inspection confirmed a failure path that exits before operation callback cleanup. Detailed security-sensitive reproduction information is intentionally restricted.

## Steps to Reproduce

Use an isolated test credential and a controlled failing remote operation. Do not use production credentials or include secret material in logs.

## Evidence

- `evidence/restricted-static-analysis.md`
- `evidence/restricted-references-and-remotes-occurrence.md`

## Suspected Area

Restricted remote callback cleanup path.

## Acceptance Criteria

- Sensitive callback context is cleared on success, native failure, and Dart callback failure.
- Tests use synthetic credentials and prove no sensitive context remains reachable after completion.
- Restricted evidence remains excluded from generated public views.

## Traceability

- Specs: FR-NP-08 and FL-NP-06.
- Code: restricted callback cleanup paths.

## Resolution

The confirmed root cause was corrected by adding one internal synchronous
lexical owner for remote callback state. Its `try` begins before state
installation, the native call and immediate error translation execute inside
the protected operation, and its `finally` performs the existing pure-Dart
reset. Remote connect, fetch, and push; repository clone; and submodule update
and clone now use that owner.

The human-approved specification verdict is `spec-correta`. FR-NP-05,
FR-NP-08, FL-NP-06, and EC-NP-14 already require bounded callback lifetimes
and prohibit retaining callback-scoped data. The correction restores code
conformance, so no specification artifact was changed or added.

### Change Set

| ID | Kind | Artifact | Applied diff |
| --- | --- | --- | --- |
| CHG-001 | test | `test/callbacks_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | test | `test/remote_test.dart` | `fix/CHG-002.diff` |
| CHG-003 | test | `test/repository_clone_test.dart` | `fix/CHG-003.diff` |
| CHG-004 | test | `test/submodule_test.dart` | `fix/CHG-004.diff` |
| CHG-005 | code | `lib/src/bindings/remote_callbacks.dart` | `fix/CHG-005.diff` |
| CHG-006 | code | `lib/src/bindings/remote.dart` | `fix/CHG-006.diff` |
| CHG-007 | code | `lib/src/bindings/repository.dart` | `fix/CHG-007.diff` |
| CHG-008 | code | `lib/src/bindings/submodule.dart` | `fix/CHG-008.diff` |

### Verification

- Gate 1 RED: `evidence/gate-1-red.md`.
- Gate 2 GREEN: `evidence/gate-2-green.md`.
- Focused suite: 60 passed, 15 network-tagged tests skipped.
- Full local suite: 938 passed, 24 network-tagged tests skipped.
- Static analysis: no issues found.

### Delivery state

The correction is present only in the local working tree on branch `0.5.5`.
No commit, pull request, merge, package version, publication, or backport has
been produced by this workflow. Under the `package` closure policy the bug
therefore remains `active` in phase `delivering`; `closure.satisfied` remains
false and no `DONE.md` lock is created.

## Agent Notes

The user explicitly confirmed restricted visibility. Do not place detailed reproduction data, credentials, or secret-like values in generated views or external harnesses.
