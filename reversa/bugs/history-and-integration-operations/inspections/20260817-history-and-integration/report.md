# History and Integration Operations Depth Inspection

## Feature Map

The inspection traced commit creation, merge, rebase, reset, revwalk, and integration-state tests against the seven feature specs and shared native-memory/error ADRs.

## Dedupe Decisions

- Unchecked merge, reset, revert, and cherry-pick option initializers remain canonical BUG-20260817-QWMA.
- Repeated `Merge.file` initialization remains canonical BUG-20260817-ZC7X.
- Merge-analysis temporary ownership aligns with existing checkout cleanup BUG-20260817-M2VF and was not duplicated.
- Returned and failed OID ownership aligns with BUG-20260817-Y7GX and the broader object-lifetime inspection still pending.
- Four distinct defects were registered as BUG-20260817-J9CU, BUG-20260817-P5DB, BUG-20260817-T8MW, and BUG-20260817-X4AE.

## Findings

The highest-impact defect is the deterministic zero-length native write in root commit creation. Rebase terminal operations also have false-success semantics, while merge options and serialized commit buffers have deterministic ownership leaks.

## Confidence and Limits

Static diagnostic confidence increased for integration error and memory paths. No integration mutation or runtime suite was executed because source is read-only and the external Dart/Flutter tool lock persists.
