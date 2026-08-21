---
schema_version: 1
id: BUG-20260817-T8MW
display_number: 20
title: Root commit creation writes through a zero-length parent array
status: active
phase: delivering
severity: critical
priority: P0
created: 2026-08-17
updated: 2026-08-20
origin: {type: inspection, external_ref: null}
area: native-integration
module: history-and-integration-operations
feature: history-and-integration-operations
labels: [commit, ffi, memory-corruption, root-commit]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "3/3 static FFI paths; 2/2 public root-commit paths reached", suspected_triggers: [creating a root commit]}
blocking: []
relationships: []
traceability:
  specs: ["reversa/sdd/history-and-integration-operations/requirements.md", "reversa/sdd/history-and-integration-operations/edge-cases.md", "reversa/sdd/addenda/bug-BUG-20260817-T8MW-v001.md#normative-addition"]
  affected_code: ["lib/src/bindings/commit.dart:71", "lib/src/bindings/commit.dart:120", "lib/src/bindings/commit.dart:168"]
  root_cause:
    state: confirmed
    hypothesis: "Empty parent lists are marshalled by allocating zero pointer elements and then writing a null sentinel to element zero."
    causal_path:
      - "The high-level root-commit API passes an empty parent list and parentCount 0."
      - "Each binding allocates arena<Pointer<T>>(0)."
      - "The empty-list branch writes parentsC[0] = nullptr outside the declared allocation."
      - "The resulting pointer is passed to the libgit2 commit serializer."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "All three serializers contain the same zero-count write."}
      - {ref: "evidence/reproduction.md", observation: "Three static paths reproduced; both public root-commit paths are reachable."}
    code_refs:
      - {file: "lib/src/bindings/commit.dart", symbol: "create", commit: "be47e9be"}
      - {file: "lib/src/bindings/commit.dart", symbol: "createBuffer", commit: "be47e9be"}
      - {file: "lib/src/bindings/commit.dart", symbol: "createFromIds", commit: "b3307a2b"}
  reproduction_tests:
    - "test/commit_test.dart#does not write through zero-length parent pointer arrays"
  regression_tests:
    - "test/commit_test.dart#writes commit without parents into the buffer"
    - "test/commit_test.dart#creates commit without parents"
    - "test/commit_test.dart#creates commit from ids without parents"
spec_verdict: spec-gap
change_risk:
  classification: medium
  reasons:
    - "The patch crosses the Dart FFI/native-memory boundary in three serializers."
    - "The intended null-pointer contract is narrow and reversible, with no data migration."
    - "Two public paths have existing functional tests; createFromIds currently has no high-level caller."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/commit_test.dart"
    purpose: "Prove the unsafe zero-length write is absent and cover all three zero-parent commit routes."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: code
    artifact: "lib/src/bindings/commit.dart"
    purpose: "Pass nullptr for empty parent arrays and allocate/copy only non-empty arrays."
    diff: "fix/CHG-002.diff"
  - id: CHG-003
    kind: specification
    artifact: "reversa/sdd/addenda/bug-BUG-20260817-T8MW-v001.md"
    purpose: "Specify zero-parent commit marshalling for the first time."
    diff: "fix/CHG-003.diff"
delivery:
  branch: "0.5.5"
  commit: "88bbed52ae15fd113ceb15af10e609591488943c"
  pull_request: null
  merge: pending
  publication: pending
versions:
  fixed_in: null
backports: []
closure: {policy: package, satisfied: false}
resolution_kind: fixed
---

# Root commit creation writes through a zero-length parent array

## Summary

Three commit serializers allocate an array of `parentCount` pointers and write element zero when the parent list is empty.

## Expected Behavior

Root commits must pass a null parent pointer with count zero without dereferencing unallocated storage.

## Actual Behavior

With `parentCount == 0`, the arena allocation has zero elements, but `parentsC[0] = nullptr` still executes, producing an out-of-bounds native write.

## Evidence

- `evidence/static-analysis.md`
- `evidence/reproduction.md`

## Acceptance Criteria

- Zero-parent calls pass `nullptr` without indexing a zero-length allocation.
- Root commit tests cover create, create-buffer, and create-from-IDs paths under memory instrumentation.

## Resolution

The confirmed defect was corrected in all three commit serializers. Empty
parent lists now pass `nullptr`; native pointer arrays are allocated and copied
only for non-empty lists.

The human-approved specification verdict is `spec-gap`. Addendum
`reversa/sdd/addenda/bug-BUG-20260817-T8MW-v001.md` records the new normative
contract without modifying the original specifications.

### Change Set

- `CHG-001`: regression and source-invariant tests in `test/commit_test.dart`.
- `CHG-002`: FFI marshalling correction in `lib/src/bindings/commit.dart`.
- `CHG-003`: immutable specification addendum v001.

### Verification

- Red: the source invariant detected three zero-length parent-array writes.
- Green: all 36 tests in `test/commit_test.dart` passed.
- Static analysis: no issues found.
- Data impact: none; no migration or repair is required.

### Delivery

The local fix is ready for delivery. Package closure is not satisfied because
the change has not been committed, merged, published in a version, or assessed
for backports. The bug therefore remains `active` in the `delivering` phase.
