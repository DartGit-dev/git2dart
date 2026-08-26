---
schema_version: 1
id: BUG-20260817-R4PL
display_number: 16
title: IndexEntry path mutation overwrites borrowed native storage
status: active
phase: awaiting-human
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-26
origin: {type: inspection, external_ref: null}
area: native-integration
module: working-tree-and-index
feature: working-tree-and-index
labels: [index-entry, borrowed-pointer, native-memory, mutation]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "2/2 focused tests before repair"
  suspected_triggers: [setting IndexEntry.path, setting IndexEntry.oid, setting IndexEntry.mode]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/working-tree-and-index/design.md#ownership-and-errors"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/index.dart:485", "lib/src/index.dart:507", "lib/src/bindings/index.dart:160"]
  root_cause:
    state: confirmed
    hypothesis: "Every IndexEntry constructor receives a borrowed libgit2 entry pointer, but the path setter replaces its path field with an unowned Dart allocation; oid and mode setters also mutate the same borrowed structure."
    causal_path: ["index lookup or iterator", "borrowed git_index_entry pointer", "IndexEntry wrapper", "path.toCharAlloc", "borrowed path field overwritten", "unowned allocation and invalid native ownership"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The documented non-modifiable lookup pointer is wrapped by IndexEntry and its path field is overwritten with an unmanaged allocation."}
      - {ref: "evidence/ownership-trace.md", observation: "All IndexEntry construction paths are borrowed; no safe owned-copy lifecycle exists, and oid/mode setters share the borrowed mutation problem."}
    code_refs:
      - {file: "lib/src/index.dart", symbol: "IndexEntry", commit: null}
      - {file: "lib/src/bindings/index.dart", symbol: "getByIndex", commit: null}
  reproduction_tests:
    - "test/index_test.dart#does not mutate borrowed index entries before add"
  regression_tests:
    - "test/index_test.dart#replaces and disposes owned index entry storage"
change_risk:
  classification: medium
  reasons:
    - "The repair changes the native ownership behind every IndexEntry projection."
    - "The public getters and setters remain source-compatible, and downstream native calls continue to receive a complete git_index_entry."
    - "The change is localized to index entry copying, disposal, and focused index tests."
spec_verdict: null
change_set:
  - {id: CHG-001, kind: test, artifact: "test/index_test.dart", purpose: "Prove borrowed-entry isolation and balanced replacement/disposal behavior.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/index.dart", purpose: "Copy complete index entries into one matched owned allocation.", diff: "fix/CHG-002.diff"}
  - {id: CHG-003, kind: code, artifact: "lib/src/index.dart", purpose: "Manage mutable owned entry copies with idempotent explicit/finalizer disposal.", diff: "fix/CHG-003.diff"}
closure: {policy: package, satisfied: false}
resolution_kind: null
---

# IndexEntry path mutation overwrites borrowed native storage

## Summary

The public path setter replaces a pointer inside a libgit2-owned, documented non-modifiable index entry with an unmanaged allocation.

## Expected Behavior

Borrowed entries must remain immutable, or mutation must occur on an independently owned copy with explicit path ownership.

## Actual Behavior

`IndexEntry.path` calls `toCharAlloc` and overwrites the borrowed structure field. The original pointer becomes unreachable and the replacement has no Dart owner.

## Evidence

- `evidence/static-analysis.md`
- `evidence/ownership-trace.md`
- `evidence/reproduction.md`

## Acceptance Criteria

- Borrowed libgit2 entries are not mutated directly.
- A mutable entry uses copied storage and releases replaced paths exactly once.
- Repeated path changes and index disposal pass ownership instrumentation.

## Resolution

The confirmed root cause is direct mutation of libgit2-owned entry structures by all three public setters. The applied correction preserves the mutable API while changing each projection to a complete independently owned native copy. The entry and UTF-8 path share one allocation; path replacement allocates the successor before releasing the predecessor, and explicit disposal plus the finalizer use the same idempotent owner.

| Change | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/index_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/index.dart` | `fix/CHG-002.diff` |
| CHG-003 | code | `lib/src/index.dart` | `fix/CHG-003.diff` |

Red-to-green evidence is recorded in `evidence/reproduction.md`. The focused index suite passed 58 tests, static analysis reported no issues, and the full suite passed 965 tests with 24 skips.

The effective specification requires matching cleanup for owned native resources, so `spec-correta` is recommended. A human specification verdict is still required. Under the package closure policy, merge and publication evidence are also required; therefore the bug remains active and unlocked.
