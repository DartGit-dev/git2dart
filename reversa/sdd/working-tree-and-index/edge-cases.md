# Working Tree and Index — Edge Cases

> 🟢 **CONFIRMED** — Boundary behavior is explicit where proven and marked as a gap where native partial-state semantics remain unknown.

| ID | Edge case | Expected behavior | Confidence |
| --- | --- | --- | --- |
| EC-WI-01 | `Index.add` receives neither entry nor string | Reject at Dart type/cast boundary. | 🟢 CONFIRMED |
| EC-WI-02 | `addFromBuffer` targets an ignored path | Add content anyway and update REUC if resolving conflict. | 🟢 CONFIRMED |
| EC-WI-03 | Bulk pathspec is empty | Forward native semantics; no invented match is returned. | 🟡 INFERRED |
| EC-WI-04 | Index has unresolved conflicts | `writeTree` throws. | 🟢 CONFIRMED |
| EC-WI-05 | Explicit write-tree repository differs from index owner | Use `writeTreeTo`; object compatibility remains native-validated. | 🟢 CONFIRMED |
| EC-WI-06 | Conflict lacks ancestor, ours, or theirs | Preserve each missing side as null. | 🟢 CONFIRMED |
| EC-WI-07 | Conflict resolution replaces one path | Unresolved other paths remain conflicted. | 🟢 CONFIRMED |
| EC-WI-08 | REUC/NAME entry is absent | Return documented absence/error rather than fabricated values. | 🟢 CONFIRMED |
| EC-WI-09 | Checkout runs on a bare repository | Throw native workdir error. | 🟢 CONFIRMED |
| EC-WI-10 | Force checkout overwrites local changes | Perform caller-selected destructive strategy; no hidden preservation guarantee. | 🟢 CONFIRMED |
| EC-WI-11 | Checkout callback aborts midway | Throw; partial filesystem state is not transactionally normalized. | 🔴 GAP |
| EC-WI-12 | Tree-to-tree receives two null trees | Throw `ArgumentError` locally. | 🟢 CONFIRMED |
| EC-WI-13 | One tree endpoint is null | Represent empty-tree comparison under native semantics. | 🟢 CONFIRMED |
| EC-WI-14 | Diff contains binary files | Preserve binary flags/metadata; text lines may be unavailable. | 🟢 CONFIRMED |
| EC-WI-15 | Similarity threshold is unusual/out of expected range | Forward or fail under native option validation; no silent clamp is documented. | 🟡 INFERRED |
| EC-WI-16 | `Diff.applies` returns false | Do not mutate target. | 🟢 CONFIRMED |
| EC-WI-17 | Full or hunk apply conflicts | Throw/return failure according to native engine; do not claim atomic rollback. | 🟢 CONFIRMED / 🔴 GAP rollback |
| EC-WI-18 | Hunk index is out of range | Reject/fail without applying another hunk. | 🟢 CONFIRMED |
| EC-WI-19 | Patch line has no newline/binary origin | Preserve native origin/content representation. | 🟢 CONFIRMED |
| EC-WI-20 | Patch/hunk/line view survives parent free | Unsupported until copied/lifetime-guarded. | 🔴 GAP |
| EC-WI-21 | Stash index is invalid | Throw native validation error. | 🟢 CONFIRMED |
| EC-WI-22 | Stash apply succeeds | Entry remains; pop additionally drops only after apply semantics succeed. | 🟢 CONFIRMED |
| EC-WI-23 | Stash pop apply fails | Whether the entry remains follows native pop semantics and must be verified. | 🟡 INFERRED |
| EC-WI-24 | Pathspec pattern matches nothing | Entries are empty; failed patterns appear only when requested by flags. | 🟢 CONFIRMED |
| EC-WI-25 | Ignore/attribute/filter receives invalid path or context | Translate native error. | 🟢 CONFIRMED |
| EC-WI-26 | Filter processes binary/non-UTF8 content | Byte-preserving API is required; text-only assumptions are unsafe. | 🟢 CONFIRMED |
| EC-WI-27 | Owned diff/index/patch is freed twice | Safe idempotency is not established. | 🔴 GAP |
| EC-WI-28 | Native error occurs after callbacks/options allocation | Temporary cleanup is required; exhaustive proof is absent. | 🔴 GAP |
| EC-WI-29 | Concurrent operations mutate one index/workdir | Ordering and safety are not established. | 🔴 GAP |
| EC-WI-30 | Path separators/case differ by platform | Preserve OS/libgit2 semantics; portable normalization contract is absent. | 🔴 GAP |

## Required Characterization

- 🔴 **GAP** — Fault-injected checkout/apply/stash partial-state matrix.
- 🔴 **GAP** — Concurrent index/workdir and callback isolation tests.
- 🔴 **GAP** — Borrowed patch/hunk/line lifetime after parent release.
- 🔴 **GAP** — Cross-platform path, symlink, executable-bit, and case behavior.

