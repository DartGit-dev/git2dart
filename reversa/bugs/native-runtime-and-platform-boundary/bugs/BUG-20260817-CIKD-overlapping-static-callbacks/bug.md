---
schema_version: 1
id: BUG-20260817-CIKD
display_number: 7
title: Overlapping remote operations overwrite process-static callbacks
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
labels: [concurrency, callbacks, cross-operation-state]
visibility: normal
security_suspected: false
reproduction:
  classification: intermittent
  rate: "0/0"
  suspected_triggers: [overlapping remote operations with distinct callbacks]
blocking:
  - kind: external
    reason: "A controlled overlap harness was not added because source and test files are read-only in this inspection."
    since: 2026-08-17
relationships: []
traceability:
  specs:
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#non-functional-requirements"
    - "reversa/sdd/native-runtime-and-platform-boundary/edge-cases.md#edge-case-catalog"
    - "reversa/sdd/questions.md#question-1-concurrency-contract"
    - "reversa/sdd/questions.md#question-8-callback-exceptions-and-cancellation"
    - "reversa/sdd/references-and-remotes/requirements.md#non-functional-requirements"
    - "reversa/sdd/references-and-remotes/questions.md#references-and-remotes-open-questions"
    - "reversa/sdd/working-tree-and-index/requirements.md#non-functional-requirements"
    - "reversa/sdd/working-tree-and-index/questions.md#evidence-needed"
    - "reversa/sdd/git-objects-and-object-database/questions.md"
    - "reversa/sdd/repository-lifecycle/questions.md"
  affected_code:
    - "lib/src/bindings/remote_callbacks.dart"
    - "lib/src/bindings/remote.dart"
    - "lib/src/bindings/repository.dart"
    - "lib/src/bindings/submodule.dart"
    - "lib/src/bindings/diff.dart"
    - "lib/src/bindings/checkout.dart"
    - "lib/src/bindings/stash.dart"
    - "lib/src/bindings/tree.dart"
    - "lib/src/bindings/treebuilder.dart"
    - "lib/src/bindings/tag.dart"
    - "lib/src/bindings/status.dart"
  root_cause:
    state: confirmed
    hypothesis: "Process-static callback closures cannot safely represent two active callback-bearing remote operations; nested or overlapping setup must be rejected until operation-local isolation is proven."
    causal_path: ["first callback-bearing operation installs process-static closures", "second operation attempts callback setup", "reentrancy guard rejects before plug", "first operation keeps its callback state", "finally reset clears state"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The initial inspection identified process-static callback state and cross-operation overwrite risk."}
      - {ref: "evidence/current-head-audit.md", observation: "All seven callback-bearing paths use withCallbackState; e2d8bb4 rejects reentrancy before plug and clears state in finally."}
    code_refs:
      - {file: "lib/src/bindings/remote_callbacks.dart", symbol: "RemoteCallbacks.withCallbackState", commit: "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"}
  reproduction_tests:
    - "test/remote_test.dart#rejects overlapping callback operations before state is replaced"
  regression_tests:
    - "test/remote_test.dart#clears callback state after repeated loopback fetch failures"
    - "test/remote_test.dart#rejects overlapping callback operations before state is replaced"
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: code, artifact: "lib/src/bindings/remote_callbacks.dart", purpose: "Serialize callback-bearing operations with reentrancy rejection and finally cleanup.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/{remote.dart,bindings/remote.dart,bindings/repository.dart,bindings/submodule.dart}", purpose: "Route every callback-bearing operation through the serialization boundary.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-003, kind: test, artifact: "test/remote_test.dart", purpose: "Prove overlap rejection occurs before state replacement and failure cleanup resets the bridge.", evidence: "evidence/current-head-audit.md"}
delivery:
  branch: "0.5.5"
  commit: "e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
  concurrent_native_matrix: pending
versions:
  fixed_in: null
backports: []
closure:
  policy: package
  satisfied: false
resolution_kind: fixed
---

# Overlapping remote operations overwrite process-static callbacks

## Summary

Operation-specific remote callbacks are stored in process-static fields, allowing a later overlapping operation to replace the callbacks used by an earlier operation.

## Expected Behavior

FR-NP-08 requires each native operation to observe the caller decisions and data supplied for that operation. The interim concurrency rule requires serialization unless isolation is proven.

## Actual Behavior

`RemoteCallbacks.plug` writes caller closures into shared static fields. Native callback functions read those fields rather than operation-local payload data. A second plug therefore changes the callback target of an already running operation.

## Steps to Reproduce

1. Trace two conceptual overlapping calls to `RemoteCallbacks.plug` with distinct callback sets.
2. Observe the second call overwrite the shared static field.
3. Trace a later native callback from the first operation to the overwritten field.

## Evidence

- `evidence/static-analysis.md`
- `evidence/references-and-remotes-occurrence.md`
- `evidence/working-tree-and-index-occurrence.md`
- `evidence/later-depth-inspection-occurrences.md`

## Suspected Area

Remote callback bridge concurrency and operation isolation.

## Acceptance Criteria

- Callback dispatch is operation-local, or the public contract enforces serialization before overlap can occur.
- Controlled overlap tests prove no cross-delivery between distinct callback sets.
- Cleanup and exception paths preserve the same isolation guarantee.

## Traceability

- Specs: native concurrency NFR, EC-NP-16, Q1, and Q8.
- Code: remote callback bridge and all plug call sites.

## Resolution

The confirmed root cause is process-static callback state without safe overlap
isolation. Commit `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` makes the
existing interim serialized-use rule executable: a second callback-bearing
operation is rejected before it can replace the first operation's state, and
the outer operation clears state in `finally`. Current-head audit confirms all
seven callback-bearing paths use that boundary and focused structural/failure
tests pass.

The evidence-backed default verdict is `spec-correta`: the effective interim
rule already requires serialization until isolation is proven; see
`evidence/spec-verdict.md`. No code was changed in this audit, so no new
independent review was required. A real concurrent native-operation matrix and
package publication remain pending; the bug is therefore `active` /
`delivering`.

## Agent Notes

No overlap harness was added because this inspection is source read-only.
