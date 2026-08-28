# Specification verdict

- Date: 2026-08-27
- Verdict: `spec-correta`
- Authorization: the user explicitly authorized evidence-based default specification verdicts while directing automatic remediation of all registered bugs.

## Evidence

`reversa/sdd/working-tree-and-index/design.md#ownership-and-errors` states that owned native pointers use matching destructors and finalizers. `reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision` requires explicit native destructors for owned objects and finalizers as a safety net, with manual `free()` detaching the finalizer.

The pre-correction wrapper instead wrote every mutable `IndexEntry` setter through a borrowed libgit2 pointer and placed the replacement path in an unmanaged allocation. Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` restores the already-specified ownership contract through an owned complete copy, matched release, replacement-before-free, and idempotent explicit/finalizer disposal. The focused regression suite and targeted analysis are recorded in `current-head-audit.md`.

No specification original or addendum is required. Package publication remains the sole outstanding closure requirement.
