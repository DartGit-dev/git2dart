---
schema_version: 1
id: BUG-20260817-VGYQ
display_number: 11
title: Reflog indexing wraps a null native entry for out-of-range access
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: repository-operations
module: references-and-remotes
feature: references-and-remotes
labels: [reflog, null-pointer, error-contract]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [reflog index outside valid range]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#functional-requirements"
    - "reversa/sdd/references-and-remotes/edge-cases.md#references-and-remotes-edge-cases"
  affected_code: ["lib/src/reflog.dart:84", "lib/src/bindings/reflog.dart:132"]
  root_cause:
    state: confirmed
    hypothesis: "The reflog binding forwards a null result from git_reflog_entry_byindex, allowing the index operator to construct a RefLogEntry whose pointer cannot be dereferenced."
    causal_path: ["invalid index", "git_reflog_entry_byindex returns nullptr", "bindings.getByIndex returns nullptr", "RefLog operator creates RefLogEntry", "property dereference"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The nullable native entry result is forwarded and wrapped without validation."}
      - {ref: "evidence/reproduction.md", observation: "The focused out-of-range lookup did not complete before the correction; after the boundary guard, both invalid indexes throw Git2DartError."}
      - {ref: "evidence/current-head-audit.md", observation: "Commit 1914a9053af88c6295fb58e6ed4e357dd8c27134 rejects nullptr before public wrapping; lower/upper invalid lookup and valid lookup pass the focused suite."}
    code_refs:
      - {file: "lib/src/bindings/reflog.dart", symbol: "getByIndex", commit: null}
      - {file: "lib/src/reflog.dart", symbol: "RefLog.operator []", commit: null}
  reproduction_tests: ["test/reflog_test.dart:56-59"]
  regression_tests: ["test/reflog_test.dart:35-59"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/reflog_test.dart", purpose: "Cover empty, valid, and invalid reflog entry lookups.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/reflog.dart", purpose: "Reject null native reflog entries before public wrapping.", diff: "fix/CHG-002.diff"}
delivery:
  branch: "0.5.5"
  commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
versions:
  fixed_in: null
backports: []
closure: {policy: package, satisfied: false}
resolution_kind: fixed
change_risk:
  classification: low
  reasons:
    - "The patch adds one null guard at the Dart FFI boundary."
    - "The valid lookup path, borrowed-entry lifetime, public API, and native ABI are unchanged."
---

# Reflog indexing wraps a null native entry for out-of-range access

## Summary

Out-of-range reflog access creates a `RefLogEntry` backed by a null pointer rather than throwing the documented error.

## Expected Behavior

FR-RR-04 and the public index operator documentation require explicit failure for an out-of-range index.

## Actual Behavior

`git_reflog_entry_byindex` can return null, but the binding and wrapper do not validate the result before later field access.

## Steps to Reproduce

Access `reflog[reflog.length]` and then read an entry property.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Reflog borrowed entry lookup and null-result translation.

## Acceptance Criteria

- Out-of-range lookup fails immediately with the documented error.
- No public `RefLogEntry` contains a null native pointer.
- Empty, first, last, and out-of-range tests exist.

## Traceability

FR-RR-04, reflog edge cases, and reflog wrappers.

## Resolution

### Reproduction and root cause

The focused test did not complete after requesting an invalid reflog entry
before the correction, showing that the invalid pointer reached the native
dereference path. The root cause is confirmed: `bindings.getByIndex` forwarded
`nullptr` from `git_reflog_entry_byindex`, and `RefLog.operator []` created a
public `RefLogEntry` wrapper around it.

### Applied change set

| ID | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/reflog_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/reflog.dart` | `fix/CHG-002.diff` |

The test suite now proves empty reflogs, valid first and last entries, and
immediate `Git2DartError` for both lower and upper out-of-range indexes.

### Validation

- `flutter test -j 1 test/reflog_test.dart` — red/non-completing before CHG-002, green after it.
- `flutter analyze` — passed with no issues.
- `git diff --check` — passed.

### Pending human decisions and delivery

The evidence-backed default specification verdict is `spec-correta`: the
reflog requirements and test matrix already require invalid index states to
fail without projecting an invalid native value. The user's automatic-
remediation authorization permits recording this verdict; see
`evidence/spec-verdict.md`. The correction is contained by local and remote
`0.5.5`, while package publication remains pending. The bug therefore remains
`active` / `delivering` until delivery closure is proven.

## Agent Notes

Existing tests cover invalid removal but not invalid lookup.
