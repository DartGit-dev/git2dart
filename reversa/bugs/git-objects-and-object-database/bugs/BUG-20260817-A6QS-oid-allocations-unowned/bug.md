---
schema_version: 1
id: BUG-20260817-A6QS
display_number: 22
title: Oid wrappers never release owned native allocations
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-21
origin: {type: inspection, external_ref: null}
area: native-integration
module: git-objects-and-object-database
feature: git-objects-and-object-database
labels: [oid, native-memory, ownership, pervasive-leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 isolated baseline plus static confirmation of all owned Oid routes", suspected_triggers: [OID parsing, object creation, ODB write, merge base]}
blocking: []
relationships:
  - {bug: BUG-20260817-2TB4, type: related-to, state: proposed, evidence: []}
  - {bug: BUG-20260817-Y7GX, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/git-objects-and-object-database/design.md", "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/oid.dart:15", "lib/src/bindings/oid.dart", "lib/src/bindings/odb.dart", "lib/src/bindings/blob.dart", "lib/src/bindings/commit.dart", "lib/src/bindings/tree.dart", "lib/src/bindings/tag.dart"]
  root_cause:
    state: confirmed
    hypothesis: "Oid erased native pointer ownership: owned calloc allocations and borrowed parent-owned pointers shared a wrapper with no release mechanism."
    causal_path:
      - "Binding adapters allocate git_oid output storage with calloc and return the pointer to high-level wrappers."
      - "The baseline Oid wrapper stores the pointer without an ownership marker, finalizer, or manual release API."
      - "Borrowed pointers use the same constructor, so unconditional release cannot be added safely without separating ownership."
      - "Owned allocations therefore remain live for the process lifetime."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The allocation and missing-release path is present across OID-producing bindings."}
      - {ref: "evidence/reproduction.md", observation: "The isolated baseline fails the release/copy contract while candidate commit aba8aa7 passes 16 focused tests."}
    code_refs:
      - {file: "lib/src/oid.dart", symbol: "Oid", commit: "3b719861df20912456ef7764d101eb02997e1f82"}
      - {file: "lib/src/bindings/oid.dart", symbol: "OID allocation helpers", commit: "3b719861df20912456ef7764d101eb02997e1f82"}
  reproduction_tests:
    - "test/oid_test.dart#manually releases owned native memory"
    - "test/commit_test.dart#creates commit from ids without parents"
  regression_tests:
    - "test/oid_test.dart#copies borrowed OID pointers before taking ownership"
    - "test/oid_test.dart#keeps a copied borrowed OID alive after parent release"
spec_verdict: spec-correta
change_risk:
  classification: medium
  reasons:
    - "The candidate changes ownership behavior across many public OID-producing routes."
    - "Borrowed pointers are copied, adding native allocations while preventing parent-lifetime use-after-free."
    - "Finalizer and manual release paths must remain exactly-once and are reversible without data repair."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/oid_test.dart; test/commit_test.dart"
    purpose: "Prove owned release and borrowed-pointer lifetime independence across OID routes."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: code
    artifact: "lib/src/oid.dart; lib/src/bindings/oid.dart; audited OID-producing wrappers"
    purpose: "Own and finalize OID allocations while copying borrowed native values."
    diff: "fix/CHG-002.diff"
closure: {policy: package, satisfied: false}
resolution_kind: fixed
delivery:
  branch: "0.5.5"
  commit: "aba8aa73dc94d9d11615809699616b8e9e644e84"
  pull_request: null
  merge: pending
  publication: pending
versions: {fixed_in: null}
backports: []
---

# Oid wrappers never release owned native allocations

## Summary

`Oid` has no finalizer or `free` method although its public constructors and many object-producing bindings allocate `git_oid` with `calloc`.

## Expected Behavior

Owned OIDs must be copied into managed storage or released exactly once; borrowed OIDs must remain non-owning.

## Actual Behavior

Owned and borrowed pointers share one wrapper with no ownership marker. Every owned allocation survives for process lifetime.

## Evidence

- `evidence/static-analysis.md`
- `evidence/reproduction.md`
- `evidence/root-cause.md`
- `evidence/gate-1-red.md`
- `evidence/gate-2-green.md`

## Acceptance Criteria

- Ownership is explicit for all OID constructors and getters.
- Owned pointers are released; borrowed pointers are never freed.
- Cross-feature allocation tests cover success and failure paths.

## Resolution

### Root cause

Confirmed. Owned `calloc<git_oid>()` outputs and borrowed parent-owned pointers
entered the same high-level wrapper without an ownership marker, finalizer, or
release operation. The accepted correction copies borrowed values and makes all
high-level `Oid` instances own exactly one native allocation.

### Specification verdict

`spec-correta`, selected by the user on 2026-08-21. The effective specification
already requires wrapper-owned or copied OID storage with explicit release and a
finalizer safety net:

- `reversa/sdd/git-objects-and-object-database/design.md#ownership-model`
- `reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision`

No specification addendum is required.

### Correction change set

| Change | Kind | Artifact | Purpose | Diff |
|---|---|---|---|---|
| CHG-001 | test | `test/oid_test.dart`; `test/commit_test.dart` | Prove owned release and borrowed-pointer lifetime independence. | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/oid.dart`; `lib/src/bindings/oid.dart`; audited OID-producing wrappers | Finalize owned OIDs and copy borrowed native values. | `fix/CHG-002.diff` |

### Red-to-green proof

- Red: isolated baseline `3b71986` failed to compile both focused test files,
  `+0 -2`, because `Oid.free()` did not exist. See `evidence/gate-1-red.md`.
- Green focused: 52 tests passed.
- Green scoped analysis: `flutter analyze lib test` reported no issues.
- Green full suite: 944 tests passed and 24 were skipped.
- Repository-wide `flutter analyze` remains blocked by four unrelated import
  errors in pre-existing E3LU reproduction artifacts. See
  `evidence/gate-2-green.md` for the proof boundary.

### Data and delivery

No persistent data is changed and no data repair is required. Candidate commit
`aba8aa73dc94d9d11615809699616b8e9e644e84` is present on branch `0.5.5`.
Merge and package publication are pending, so package closure is not satisfied
and no `DONE.md` lock may be created yet.
