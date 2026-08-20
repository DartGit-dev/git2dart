# Working Tree and Index Depth Inspection

## Feature Map

- Specs: seven feature artifacts plus ADR-003 and ADR-004.
- Code: index, diff, patch, checkout, stash, and pathspec high-level wrappers and bindings.
- Tests: focused index, diff, patch, checkout, stash, and pathspec suites.
- State boundaries: on-disk index, workdir mutation, stash refs, borrowed index entries, native callbacks, and temporary options/OID allocations.
- Existing bugs: all 12 canonical records were searched before promotion.

## Dedupe Decisions

- Unchecked diff, checkout, and stash option initialization was added to BUG-20260817-QWMA.
- Process-static diff, checkout, and stash callback state was added to BUG-20260817-CIKD.
- Five distinct defects were registered as BUG-20260817-6KRT, BUG-20260817-8HNA, BUG-20260817-M2VF, BUG-20260817-R4PL, and BUG-20260817-Y7GX.

## Findings by Lens

| Lens | Promoted findings | Observations not promoted |
| --- | --- | --- |
| Specification conformity | Silent index I/O failure; borrowed-entry mutation | Partial-mutation recovery remains incompletely specified |
| Data flow and ownership | Stash options, checkout lookups, and failed OID buffers leak | Parent-lifetime misuse still needs dynamic instrumentation |
| Contracts and integrations | Public index methods can report false success | Cross-platform filesystem semantics were not executed |
| Error states | Checkout cleanup is bypassed on native failure | Exact workdir state after interrupted mutations remains environment-dependent |
| Test coverage | Five missing negative/ownership groups | Existing focused suites could not run because of external tool locks |
| Concurrency | Existing static-state bug reconfirmed and deduplicated | No overlap harness was added in read-only mode |

## Confidence

Formal extraction confidence remains 75.8 percent. Static diagnostic confidence increased through five new canonical records and two cross-context evidence updates. Runtime confidence did not increase because Dart and Flutter remained blocked by external cache locks.

## Not Covered

- No source or test file was modified.
- No destructive checkout, stash, or index experiment was run against the repository.
- No five-platform filesystem, interruption, callback-overlap, or allocation-instrumentation matrix was executed.
