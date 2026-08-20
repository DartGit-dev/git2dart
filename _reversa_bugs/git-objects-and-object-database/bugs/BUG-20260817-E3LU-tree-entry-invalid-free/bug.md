---
schema_version: 1
id: BUG-20260817-E3LU
display_number: 23
title: Borrowed TreeEntry values expose an invalid native free operation
status: active
phase: delivering
severity: critical
priority: P0
created: 2026-08-17
updated: 2026-08-20
origin: {type: inspection, external_ref: null}
area: native-integration
module: git-objects-and-object-database
feature: git-objects-and-object-database
labels: [tree-entry, borrowed-pointer, invalid-free, memory-safety]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "3/3 isolated Flutter workers terminated with exit code 79", suspected_triggers: [freeing index/name/OID tree lookup result]}
blocking: []
relationships: []
traceability:
  specs: ["_reversa_sdd/git-objects-and-object-database/design.md#ownership-model", "_reversa_sdd/git-objects-and-object-database/edge-cases.md#required-characterization"]
  affected_code: ["lib/src/tree.dart:104", "lib/src/tree.dart:123", "lib/src/tree.dart:143", "lib/src/tree.dart:226"]
  root_cause:
    state: confirmed
    hypothesis: "TreeEntry erases the borrowed-versus-owned distinction and exposes an unconditional native destructor for both ownership modes."
    causal_path:
      - "Index, name, OID, and entries-list lookups return pointers owned by the parent tree."
      - "The high-level Tree wrapper constructs the same TreeEntry type for borrowed and caller-owned path results without retaining ownership state."
      - "TreeEntry.free unconditionally calls git_tree_entry_free for every instance."
      - "Freeing a borrowed entry corrupts parent-owned native storage and later cleanup terminates the Flutter worker."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "Binding ownership contracts and the unconditional high-level destructor conflict."}
      - {ref: "evidence/reproduction.md", observation: "Three of three isolated Flutter workers terminated with exit code 79 after the invalid ownership sequence."}
    code_refs:
      - {file: "lib/src/tree.dart", symbol: "Tree.entries and Tree.operator[]", commit: "d34661a"}
      - {file: "lib/src/tree.dart", symbol: "TreeEntry.free", commit: "d34661a"}
      - {file: "lib/src/tree.dart", symbol: "Tree.entryByOid", commit: "83ca090a"}
  reproduction_tests:
    - "evidence/reproduce_invalid_free_test.dart#freeing a borrowed tree entry corrupts native ownership"
    - "test/tree_test.dart#rejects manual release of borrowed entry from entries list"
  regression_tests:
    - "test/tree_test.dart#rejects manual release of borrowed entry from entries list"
    - "test/tree_test.dart#rejects manual release of borrowed entry from index lookup"
    - "test/tree_test.dart#rejects manual release of borrowed entry from filename lookup"
    - "test/tree_test.dart#rejects manual release of borrowed entry from OID lookup"
    - "test/tree_test.dart#manually releases allocated memory for tree entry looked up by path"
spec_verdict: spec-correta
change_risk:
  classification: medium
  reasons:
    - "The correction changes the public failure mode of TreeEntry.free for borrowed entries from native heap corruption to a Dart StateError."
    - "Four borrowed construction paths and the owned path lookup must preserve distinct ownership behavior."
    - "The change is confined to TreeEntry, requires no data repair, and is reversible."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/tree_test.dart"
    purpose: "Cover borrowed release rejection for all lookup routes and preserve owned path release."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: code
    artifact: "lib/src/tree.dart"
    purpose: "Retain TreeEntry ownership state and reject borrowed native release."
    diff: "fix/CHG-002.diff"
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

# Borrowed TreeEntry values expose an invalid native free operation

## Summary

All `TreeEntry` instances expose `free`, including entries explicitly documented as owned by their parent tree and forbidden to free.

## Expected Behavior

Only path lookups that return caller-owned duplicates may expose native release.

## Actual Behavior

Index, name, and OID lookups return the same public type as owned path lookups. Calling `free` on a borrowed instance invokes `git_tree_entry_free` on parent-owned memory.

## Evidence

- `evidence/static-analysis.md`
- `evidence/reproduction.md`

## Acceptance Criteria

- Ownership is encoded so borrowed entries cannot be freed.
- Owned path entries remain released exactly once.
- Negative ownership tests cover parent disposal and attempted manual release.

## Resolution

### Root Cause

**Confirmed.** `TreeEntry` erased the native borrowed-versus-owned distinction
while exposing one unconditional `free()` implementation. Borrowed entries from
list, index, filename, and OID lookups therefore reached
`git_tree_entry_free`, corrupting storage owned by the parent tree.

### Specification Verdict

The user approved `spec-correta` on `2026-08-20`. The existing ownership model
already classifies tree entries as borrowed or copied according to the wrapper
and ties borrowed lifetime to the native owner. The code diverged from that
contract; no specification addendum is required.

### Change Set

| Change | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/tree_test.dart` | [`fix/CHG-001.diff`](fix/CHG-001.diff) |
| CHG-002 | code | `lib/src/tree.dart` | [`fix/CHG-002.diff`](fix/CHG-002.diff) |

CHG-002 retains ownership state in each `TreeEntry`. Borrowed instances now
throw `StateError` before the native destructor; caller-owned path entries keep
their explicit native release and finalizer detachment.

### Verification

- Red: borrowed release returned normally instead of throwing `StateError`;
  the targeted test exited 1.
- Green: all 25 tests in `test/tree_test.dart` passed.
- Static analysis: no issues found.
- Data impact: none; the defect corrupts process memory, not persisted data.

### Control and Delivery

The user explicitly removed the separate Gate 1 and Gate 2 approval pauses for
this E3LU correction after approving `fix/plan.html`. The local change is ready
for delivery. Package closure remains unsatisfied until the change is committed,
merged, published in a version, and assessed for backports. The bug therefore
remains `active` in the `delivering` phase; no `DONE.md` is created.
