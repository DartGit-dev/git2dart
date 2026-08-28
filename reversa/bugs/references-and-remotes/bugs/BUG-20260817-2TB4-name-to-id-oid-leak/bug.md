---
schema_version: 1
id: BUG-20260817-2TB4
display_number: 12
title: Reference nameToId leaks its native OID allocation
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: native-integration
module: references-and-remotes
feature: references-and-remotes
labels: [reference, oid, native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [reference name to OID lookup]
blocking: []
relationships:
  - bug: BUG-20260817-3FWN
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#functional-requirements"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/reference.dart:297", "lib/src/bindings/reference.dart:844", "lib/src/oid.dart"]
  root_cause:
    state: confirmed
    hypothesis: "Reference name lookup allocated a native OID while the historical wrapper had no explicit owner or finalizer path."
    causal_path: ["binding allocates output OID", "successful lookup returns pointer", "wrapper stores pointer without release", "allocation remains live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original binding/wrapper pair had no release path."}
      - {ref: "evidence/current-head-audit.md", observation: "Current binding cleans failure output and current Oid owns the successful output with explicit release and finalizer."}
    code_refs:
      - {file: "lib/src/bindings/reference.dart", symbol: "nameToId", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
      - {file: "lib/src/reference.dart", symbol: "Reference.nameToId", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
      - {file: "lib/src/oid.dart", symbol: "Oid ownership", commit: "aba8aa73dc94d9d11615809699616b8e9e644e84"}
  reproduction_tests: ["test/reference_test.dart#Reference rejects invalid names before every native reference operation"]
  regression_tests: ["test/reference_test.dart#get oid by name", "test/oid_test.dart#manually releases owned native memory"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/reference_test.dart; test/oid_test.dart", purpose: "Exercise local name lookup and owned OID release.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/{reference,oid}.dart; lib/src/bindings/reference.dart", purpose: "Transfer exactly one OID owner on success and clean up on failure.", evidence: "evidence/current-head-audit.md"}
closure: {policy: package, satisfied: false}
resolution_kind: fixed
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
---

# Reference nameToId leaks its native OID allocation

## Summary

Reference name lookup returns a heap-allocated OID through a wrapper that has no ownership or release path.

## Expected Behavior

FR-RR-01, FR-RR-12, and ADR-003 require returned native allocations to have explicit ownership and release.

## Actual Behavior

The binding allocates `git_oid` with `calloc` and returns it. `Oid` stores the pointer but has no finalizer or free method for this allocation.

## Steps to Reproduce

Trace `Reference.nameToId` through the binding and `Oid` constructor.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Reference-to-OID conversion ownership.

## Acceptance Criteria

- The returned OID is copied into managed storage or receives one explicit native owner.
- Success and error paths release temporary allocations.
- Repeated name lookup shows no growth under instrumentation.

## Traceability

FR-RR-01, FR-RR-12, ADR-003, reference binding, and OID wrapper.

## Resolution

The confirmed root cause was native OID allocation without an ownership-aware
high-level wrapper. Current name lookup returns the successful OID to an owning
`Oid`; the wrapper provides explicit release and a finalizer safety net, while
the binding cleans its preallocated output on native failure. The required plan
is recorded in `fix/plan.html`.

Focused local reference and OID suites pass with focused analysis clean. No
current source or test gap was demonstrated, so this audit applied no code or
test diff. The authorized evidence-based verdict is `spec-correta`: the
reference requirements and ADR-003 already require explicit ownership and
release for returned native storage.

The correction is contained by local and origin `0.5.5`; package publication
remains pending, so the record is `active` / `delivering`.

## Agent Notes

The positive test proves value correctness but not allocation ownership.
