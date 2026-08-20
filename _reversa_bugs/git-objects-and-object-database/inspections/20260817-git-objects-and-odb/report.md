# Git Objects and Object Database Depth Inspection

## Feature Map and Dedupe

The inspection traced OID, blob, commit, tree, tree-builder, tag, ODB, and write-stream ownership against the seven feature specs and ADR-003. Static walk/tag/filter callback state was deduplicated into BUG-20260817-CIKD. Commit signature buffers were merged into BUG-20260817-X4AE. Unchecked blob/filter options remain BUG-20260817-QWMA. Four distinct defects were registered as BUG-20260817-A6QS, BUG-20260817-E3LU, BUG-20260817-H7NP, and BUG-20260817-K2RY.

## Highest-Value Findings

- P0: borrowed `TreeEntry` instances expose a deterministic invalid-free path.
- P1: the central `Oid` wrapper has no ownership release despite pervasive native allocations.
- P1: streamed string blobs corrupt non-ASCII data by treating UTF-16 code units as bytes.
- P2: blob filter buffers leak libgit2-owned storage.

## Confidence and Limits

Static confidence increased substantially for memory and data-integrity contracts. No allocator instrumentation or runtime suite was executed because the external Dart/Flutter lock persists.
