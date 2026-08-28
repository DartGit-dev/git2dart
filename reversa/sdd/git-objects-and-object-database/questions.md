# Git Objects and Object Database — Open Questions

> 🟢 **CONFIRMED** — These unresolved contracts do not block documentation but must remain explicit during reimplementation or migration.

| ID | Question | Impact | Interim rule | Confidence |
| --- | --- | --- | --- | --- |
| Q-OBJ-01 | Which SHA-256 operations are officially supported? | Defines OID length, prefix, lookup, storage, graph, and remote compatibility. | Do not infer completeness from syntax validation. | 🔴 GAP |
| Q-OBJ-02 | Are repeated `free()` calls required to be safe? | Determines wrapper guard/state design. | Release once and stop using the wrapper. | 🔴 GAP |
| Q-OBJ-03 | May `TreeEntry` or similar borrowed views outlive their parent? | Determines copy/retention behavior and crash risk. | Keep parent alive or copy values. | 🔴 GAP |
| Q-OBJ-04 | What is the supported behavior after a blob stream is committed? | Determines double-commit/write/free protection. | Treat commit as terminal ownership transfer. | 🔴 GAP |
| Q-OBJ-05 | Are duplicate `TreeUpdate` paths intentionally order-sensitive? | Affects deterministic reconstruction. | Preserve caller order and native semantics. | 🟡 INFERRED |
| Q-OBJ-06 | Must text getters preserve malformed UTF-8 byte-for-byte? | Affects binary/text compatibility. | Use byte getters for fidelity; text is convenience only. | 🟢 CONFIRMED principle; 🔴 GAP exact decoding |
| Q-OBJ-07 | What object-size limits are required for local and remote writes? | Affects memory/resource safety. | Preserve configured libgit2 pack limit; add no invented local limit. | 🔴 GAP |
| Q-OBJ-08 | Are object wrappers safe for shared concurrent reads? | Affects isolates/thread use and native lifetime. | Do not claim thread safety without tests. | 🔴 GAP |

## Evidence Needed

- 🔴 **GAP** — Hash-format fixture matrix covering every public lookup/create/write path.
- 🔴 **GAP** — Native ownership instrumentation with injected failure after each allocation.
- 🔴 **GAP** — Dedicated borrowed-view lifetime tests after parent release.
- 🔴 **GAP** — Blob-stream state-machine tests for commit, abort, finalizer, and repeated operations.
- 🔴 **GAP** — Cross-platform large-object and binary-content characterization.

## Resolved by Current Evidence

- 🟢 **CONFIRMED** — Root commits have zero parents and parent order is preserved.
- 🟢 **CONFIRMED** — Null `TreeUpdate.oid` means removal.
- 🟢 **CONFIRMED** — ODB pseudo/delta types are not writable.
- 🟢 **CONFIRMED** — Supported polymorphic targets are commit, tree, blob, and tag.
- 🟢 **CONFIRMED** — Raw bytes are available for binary-safe access.

