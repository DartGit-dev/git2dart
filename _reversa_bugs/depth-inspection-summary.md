# Git2Dart Depth Inspection Summary

## Completion

The approved read-only depth-inspection order is complete across all six extracted feature units:

| Feature | Canonical bugs | Inspection report |
| --- | ---: | --- |
| native-runtime-and-platform-boundary | 7 | `native-runtime-and-platform-boundary/inspections/20260817-native-runtime-boundary/report.md` |
| references-and-remotes | 5 | `references-and-remotes/inspections/20260817-references-and-remotes/report.md` |
| working-tree-and-index | 5 | `working-tree-and-index/inspections/20260817-working-tree-and-index/report.md` |
| history-and-integration-operations | 4 | `history-and-integration-operations/inspections/20260817-history-and-integration/report.md` |
| git-objects-and-object-database | 4 | `git-objects-and-object-database/inspections/20260817-git-objects-and-odb/report.md` |
| repository-lifecycle | 4 | `repository-lifecycle/inspections/20260817-repository-lifecycle/report.md` |

## Registry Outcome

- 29 unique open canonical bugs: 3 critical/P0, 15 high/P1, and 11 medium/P2.
- 28 normal-visibility records and one restricted record.
- Restricted BUG-20260817-O3B3 is excluded from public graphs, matrices, and specification traceability.
- All relationships point to existing canonical IDs; no resolved-state or duplicate-ID inconsistency exists.

## Highest-Priority Confirmed Defects

1. BUG-20260817-T8MW: root commit creation writes through a zero-length FFI parent array.
2. BUG-20260817-E3LU: borrowed tree entries expose an invalid native free operation.
3. BUG-20260817-V9TR: status performance data returns an arena-freed pointer.

## Confidence Change

Static confidence increased most for native ownership, failure propagation, callback isolation, Unicode data integrity, and partial integration-state transitions. Several extraction uncertainties were converted into traceable canonical bugs or deduplicated evidence. Formal feature confidence percentages were not rewritten because no runtime, allocator, interruption, or five-platform evidence was added.

## Remaining Evidence Gap

The local Dart and Flutter commands remain blocked by stale external cache lock files while no Dart or Flutter process owns them. Those files were not deleted or modified. Consequently, no test, allocator-instrumentation, overlap, interruption, live transport, or cross-platform result is claimed by this inspection.

## Scope Integrity

No source or test file was modified. No files from the companion `git2dart_binaries` repository were read into or written from this inspection state.
