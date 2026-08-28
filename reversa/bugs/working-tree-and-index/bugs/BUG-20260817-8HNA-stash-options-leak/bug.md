---
schema_version: 1
id: BUG-20260817-8HNA
display_number: 14
title: Stash apply and pop leak checkout option allocations
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: native-integration
module: working-tree-and-index
feature: working-tree-and-index
labels: [stash, checkout, native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "2/2 static paths"
  suspected_triggers: [stash apply, stash pop]
blocking: []
relationships:
  - {bug: BUG-20260817-47ZS, type: related-to, state: proposed, evidence: []}
traceability:
  specs:
    - "reversa/sdd/working-tree-and-index/flows.md#fl-wi-07-stash-lifecycle"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/bindings/checkout.dart:178", "lib/src/bindings/stash.dart:87", "lib/src/bindings/stash.dart:146"]
  root_cause:
    state: confirmed
    hypothesis: "checkout.initOptions used calloc although both stash callers discarded its ownership handles inside an arena."
    causal_path: ["stash apply or pop", "calloc allocations", "ownership discarded", "per-call native leak"]
    evidence: [{ref: "evidence/static-analysis.md", observation: "Options and path arrays were outside the caller arena and never freed."}]
    code_refs: [{file: "lib/src/bindings/checkout.dart", symbol: "initOptions", commit: null}]
  reproduction_tests: []
  regression_tests: ["test/stash_test.dart"]
spec_verdict: spec-correta
change_set: [{id: CHG-001, kind: test, artifact: "test/stash_test.dart", purpose: "Exercise paths on apply/pop errors.", diff: null}, {id: CHG-002, kind: code, artifact: "lib/src/bindings/checkout.dart", purpose: "Use caller arena for checkout options and path array.", diff: null}]
closure: {policy: package, satisfied: false}
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
resolution_kind: fixed
---

# Stash apply and pop leak checkout option allocations

## Summary

Every stash apply or pop allocates checkout options, and optionally a pointer array, outside the surrounding arena without freeing either allocation.

## Expected Behavior

ADR-003 requires temporary native allocations to be arena-scoped or explicitly released on all paths.

## Actual Behavior

`checkout.initOptions` uses `calloc`; its callers copy the structure into stash options and discard all returned ownership handles.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Options and path arrays have one explicit owner and are released on success and error.
- Repeated apply/pop instrumentation shows no per-call growth.

## Resolution

The confirmed root cause was caller ownership being discarded when checkout
options and an optional path array were allocated outside the stash arena.
Current `checkout.initOptions` accepts the caller arena and allocates both
containers through it; apply and pop pass their enclosing arena to the helper.

The required plan is recorded in `fix/plan.html`. The existing local stash
suite covers successful apply/pop and the corresponding invalid-index error
paths, and focused analysis is clean. No current source or test gap was
demonstrated, so this audit applied no code or test diff.

The authorized evidence-based verdict is `spec-correta`: ADR-003 already
requires deterministic ownership of temporary native allocations. Commit
`1914a9053af88c6295fb58e6ed4e357dd8c27134` is contained by local and origin
`0.5.5`; package publication remains pending, so the record stays `active` /
`delivering`.
