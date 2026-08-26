---
schema_version: 1
id: BUG-20260817-BVMB
display_number: 10
title: Remote getRefspec wraps a null native pointer for invalid indexes
status: active
phase: awaiting-human
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-26
origin: {type: inspection, external_ref: null}
area: repository-operations
module: references-and-remotes
feature: references-and-remotes
labels: [refspec, null-pointer, error-contract]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [refspec index outside valid range]
blocking: []
relationships:
  - bug: BUG-20260817-VGYQ
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#functional-requirements"
    - "reversa/sdd/references-and-remotes/edge-cases.md#references-and-remotes-edge-cases"
  affected_code: ["lib/src/remote.dart:231", "lib/src/bindings/remote.dart:294", "lib/src/refspec.dart"]
  root_cause:
    state: confirmed
    hypothesis: "The remote binding forwards a null result from git_remote_get_refspec, allowing Remote.getRefspec to construct a Refspec whose pointer cannot be dereferenced."
    causal_path: ["invalid index", "git_remote_get_refspec returns nullptr", "bindings.getRefspec returns nullptr", "Remote.getRefspec constructs Refspec", "property dereference"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The nullable native result is returned without validation and then wrapped immediately."}
      - {ref: "evidence/reproduction.md", observation: "Before the correction, lower-bound lookup returned a wrapper and failed later during refspec property access instead of throwing Git2DartError at lookup."}
    code_refs:
      - {file: "lib/src/bindings/remote.dart", symbol: "getRefspec", commit: null}
      - {file: "lib/src/remote.dart", symbol: "Remote.getRefspec", commit: null}
  reproduction_tests: ["test/remote_test.dart:242-250"]
  regression_tests: ["test/remote_test.dart:214-250"]
spec_verdict: null
change_set:
  - {id: CHG-001, kind: test, artifact: "test/remote_test.dart", purpose: "Cover valid and invalid refspec index boundaries.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/remote.dart", purpose: "Reject null native refspec results before public wrapping.", diff: "fix/CHG-002.diff"}
closure: {policy: package, satisfied: false}
resolution_kind: null
change_risk:
  classification: low
  reasons:
    - "The correction adds one null guard at the Dart FFI boundary."
    - "The valid lookup path, public signature, ownership, and native ABI are unchanged."
---

# Remote getRefspec wraps a null native pointer for invalid indexes

## Summary

An invalid refspec index produces a wrapper around a null pointer instead of the documented error.

## Expected Behavior

FR-RR-05 and the public `getRefspec` contract require invalid lookup to fail explicitly.

## Actual Behavior

The native nullable pointer is returned without validation and immediately wrapped. Later property access dereferences it.

## Steps to Reproduce

Call `getRefspec(refspecCount)` and access a `Refspec` property.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Borrowed refspec lookup and null-result translation.

## Acceptance Criteria

- Invalid indexes fail at lookup with the documented Dart/native error.
- No public wrapper can contain a null refspec pointer.
- Boundary indexes have positive and negative tests.

## Traceability

FR-RR-05, refspec edge cases, and remote/refspec wrappers.

## Resolution

### Reproduction and root cause

The boundary test failed before the correction because `getRefspec(-1)` returned
a `Refspec` wrapper. The test framework then triggered a later native
dereference while formatting that unexpected return value. The root cause is
confirmed: `bindings.getRefspec` forwarded `nullptr` from
`git_remote_get_refspec` instead of translating it at the FFI boundary.

### Applied change set

| ID | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/remote_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/remote.dart` | `fix/CHG-002.diff` |

The existing index-zero test remains the positive case. The added boundary test
proves that both `-1` and `refspecCount` fail immediately with `Git2DartError`.

### Validation

- `flutter test -j 1 test/remote_test.dart` — red before CHG-002, green after it.
- `flutter analyze` — passed with no issues.
- `git diff --check` — passed.

### Pending human decisions and delivery

Recommended specification verdict: `spec-correta`. FR-RR-05 and the public
contract require invalid lookup to fail explicitly; the implementation diverged.
Package closure still requires a human-recorded verdict, merge, and publication.

## Agent Notes

The positive tests cover only index zero.
