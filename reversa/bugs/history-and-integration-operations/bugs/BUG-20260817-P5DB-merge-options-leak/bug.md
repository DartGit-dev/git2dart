---
schema_version: 1
id: BUG-20260817-P5DB
display_number: 19
title: Merge operations leak native merge options
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: native-integration
module: history-and-integration-operations
feature: history-and-integration-operations
labels: [merge, native-memory, options, leak]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "3/3 static call families", suspected_triggers: [merge, merge commits, merge trees]}
blocking: []
relationships:
  - {bug: BUG-20260817-8HNA, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/history-and-integration-operations/design.md", "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"]
  affected_code: ["lib/src/bindings/merge.dart:197", "lib/src/bindings/merge.dart:366", "lib/src/bindings/merge.dart:404", "lib/src/bindings/merge.dart:478"]
  root_cause:
    state: confirmed
    hypothesis: "The merge-options helper accepted an arena but historically allocated options outside it, leaving callers with no owner."
    causal_path: ["merge family enters arena", "helper allocates global options", "caller discards allocation handle", "temporary native options remain live"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The original helper used a global allocation despite receiving the caller arena."}
      - {ref: "evidence/current-head-audit.md", observation: "Current helper allocates options through the caller arena for all three call families."}
    code_refs:
      - {file: "lib/src/bindings/merge.dart", symbol: "_initMergeOptions", commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"}
  reproduction_tests: ["test/merge_test.dart#merge commits throws when error occurs", "test/merge_test.dart#merge trees throws when error occurs"]
  regression_tests: ["test/merge_test.dart#merge commits merges with provided merge and file flags", "test/merge_test.dart#merge trees merges with provided favor"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/merge_test.dart", purpose: "Exercise local merge call families and error behavior.", evidence: "evidence/current-head-audit.md"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/merge.dart", purpose: "Allocate merge options through the supplied arena.", evidence: "evidence/current-head-audit.md"}
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

# Merge operations leak native merge options

## Summary

The shared merge-options helper accepts an arena but allocates with `calloc`; none of its three call families frees the returned allocation.

## Expected Behavior

Temporary merge options must be arena-owned or explicitly released on all paths.

## Actual Behavior

Each merge, merge-commits, or merge-trees invocation leaks one options structure.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- One explicit owner releases options on success and error.
- Repeated merge instrumentation shows no per-call growth.

## Resolution

The confirmed root cause was merge-option allocation outside the arena supplied
by all three merge call families. Current `_initMergeOptions` allocates options
through its caller arena, releasing them on both normal and throwing exits. The
required plan is recorded in `fix/plan.html`.

Focused local merge success and error tests pass with focused analysis clean.
No current source or test gap was demonstrated, so this audit applied no code
or test diff. The authorized evidence-based verdict is `spec-correta`: the
existing design and ADR-003 already require deterministic temporary ownership.

Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
