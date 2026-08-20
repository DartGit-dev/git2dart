---
schema_version: 1
id: BUG-20260817-CIKD
display_number: 7
title: Overlapping remote operations overwrite process-static callbacks
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
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
    - "_reversa_sdd/native-runtime-and-platform-boundary/requirements.md#non-functional-requirements"
    - "_reversa_sdd/native-runtime-and-platform-boundary/edge-cases.md#edge-case-catalog"
    - "_reversa_sdd/questions.md#question-1-concurrency-contract"
    - "_reversa_sdd/questions.md#question-8-callback-exceptions-and-cancellation"
    - "_reversa_sdd/references-and-remotes/requirements.md#non-functional-requirements"
    - "_reversa_sdd/references-and-remotes/questions.md#references-and-remotes-open-questions"
    - "_reversa_sdd/working-tree-and-index/requirements.md#non-functional-requirements"
    - "_reversa_sdd/working-tree-and-index/questions.md#evidence-needed"
    - "_reversa_sdd/git-objects-and-object-database/questions.md"
    - "_reversa_sdd/repository-lifecycle/questions.md"
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
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure:
  policy: package
  satisfied: false
resolution_kind: null
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

Pending `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

No overlap harness was added because this inspection is source read-only.
