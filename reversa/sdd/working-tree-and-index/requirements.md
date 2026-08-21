# Working Tree and Index Requirements

> 🟢 **CONFIRMED** — This unit specifies mutable repository projections: index entries/conflicts, checkout, status-adjacent diff/patch, stash, ignore, attributes, filters, and pathspec matching.

## Responsibilities

- 🟢 **CONFIRMED** — Stage, update, remove, read, persist, and serialize index entries.
- 🟢 **CONFIRMED** — Represent three-way conflicts and resolve-undo metadata.
- 🟢 **CONFIRMED** — Calculate, inspect, transform, check, and apply diffs/patches.
- 🟢 **CONFIRMED** — Materialize repository content through checkout and stash flows.
- 🟢 **CONFIRMED** — Match paths through pathspec, ignore, attributes, and filters.

## Business Rules

| ID | Rule | Confidence |
| --- | --- | --- |
| BR-WI-01 | `Index.add` accepts an `IndexEntry` or path string. | 🟢 CONFIRMED |
| BR-WI-02 | `addFromBuffer` bypasses ignore rules and moves prior conflict data to REUC. | 🟢 CONFIRMED |
| BR-WI-03 | An index with unresolved conflicts cannot be written as a tree. | 🟢 CONFIRMED |
| BR-WI-04 | Conflict sides are nullable ancestor/ours/theirs entries with stage semantics. | 🟢 CONFIRMED |
| BR-WI-05 | Tree-to-tree diff rejects both trees null. | 🟢 CONFIRMED |
| BR-WI-06 | `Diff.applies` uses native check-only mode and must not mutate. | 🟢 CONFIRMED |
| BR-WI-07 | Diff application targets workdir, index, or both according to `GitApplyLocation`. | 🟢 CONFIRMED |
| BR-WI-08 | Similarity defaults are rename/copy/rewrite 50, break-rewrite 60, limit 200. | 🟢 CONFIRMED |
| BR-WI-09 | Bulk path arrays are temporary arena-scoped native strings. | 🟢 CONFIRMED |
| BR-WI-10 | Working-directory mutation is invalid for bare repositories. | 🟢 CONFIRMED |

## Functional Requirements

| ID | Requirement | Priority | Acceptance summary | Confidence |
| --- | --- | --- | --- | --- |
| FR-WI-01 | Open/read an index and expose path, entries, capabilities, checksum, and conflict state. | Must | Typed values match native index state. | 🟢 CONFIRMED |
| FR-WI-02 | Add/update/remove one or many entries by entry, path, pathspec, or buffer. | Must | Index reflects selected inputs and callback/pathspec policy. | 🟢 CONFIRMED |
| FR-WI-03 | Read/write/reload/clear the index and write it as a tree in its owner or supplied repository. | Must | Conflict-free index persists/serializes; conflicts fail tree write. | 🟢 CONFIRMED |
| FR-WI-04 | Enumerate/add/remove/clean conflict entries and expose NAME/REUC metadata. | Must | Ancestor/ours/theirs and resolve-undo data are preserved. | 🟢 CONFIRMED |
| FR-WI-05 | Checkout HEAD, index, tree, reference, or commit with typed strategies/path restrictions. | Must | Selected content is materialized or native safety failure is thrown. | 🟢 CONFIRMED |
| FR-WI-06 | Build diffs between supported tree/index/workdir/buffer/blob endpoints. | Must | Deltas represent the selected before/after projections. | 🟢 CONFIRMED |
| FR-WI-07 | Inspect diff stats, deltas, files, patches, hunks, and lines. | Must | Coordinates, origin, headers, and content are projected safely. | 🟢 CONFIRMED |
| FR-WI-08 | Merge diffs and run similarity detection with typed thresholds/flags. | Should | Rename/copy classification follows options. | 🟢 CONFIRMED |
| FR-WI-09 | Check/apply a full diff or selected hunk to workdir/index/both or a tree. | Must | Check-only is non-mutating; apply changes only the selected target. | 🟢 CONFIRMED |
| FR-WI-10 | Create/list/apply/pop/drop stashes with checkout/index/path options. | Should | Stash identity/order and requested restoration/drop semantics are preserved. | 🟢 CONFIRMED |
| FR-WI-11 | Evaluate ignore and attributes and apply filters where exposed. | Should | Results match repository configuration and supplied direction/options. | 🟢 CONFIRMED |
| FR-WI-12 | Compile and match pathspecs against workdir/index/tree/diff/path, optionally retaining failures. | Should | Entries/failures reflect typed match flags. | 🟢 CONFIRMED |
| FR-WI-13 | Release owned native index/diff/patch/pathspec/filter resources. | Must | Explicit/finalizer cleanup follows ownership. | 🟢 CONFIRMED |

## Non-Functional Requirements

| Type | Requirement | Confidence |
| --- | --- | --- |
| Data safety | Forceful checkout/reset/apply choices remain explicit caller options. | 🟢 CONFIRMED |
| Memory safety | Native lists, patches, options, callbacks, and path arrays are released within their ownership scope. | 🟢 CONFIRMED |
| Binary/path fidelity | Diff/patch content and repository-relative paths preserve native data. | 🟢 CONFIRMED |
| Error consistency | Conflict, bare, invalid pathspec, invalid target, and filesystem failures are explicit. | 🟢 CONFIRMED |
| Atomicity | No general transaction/rollback guarantee is inferred across multi-step filesystem/index mutations. | 🔴 GAP |

## Acceptance Criteria

🟢 **CONFIRMED**

```gherkin
Dado a conflict-free index containing staged entries
Quando writeTree is invoked
Então a root Tree Oid is returned in the selected repository
```

🟢 **CONFIRMED**

```gherkin
Dado an index with unresolved conflict stages
Quando writeTree is invoked
Então a translated native error is thrown and no successful tree result is returned
```

🟢 **CONFIRMED**

```gherkin
Dado a diff and a target repository projection
Quando applies is checked and then apply is invoked
Então the check is non-mutating and the apply changes only the selected location
```

🟢 **CONFIRMED**

```gherkin
Dado two null tree inputs
Quando treeToTree diff is requested
Então ArgumentError is thrown before native diff creation
```

## MoSCoW and Traceability

| Capability | Priority | Confidence |
| --- | --- | --- |
| Index integrity/conflicts/tree serialization | Must | 🟢 CONFIRMED |
| Checkout/diff/apply safety | Must | 🟢 CONFIRMED |
| Patch inspection | Must | 🟢 CONFIRMED |
| Stash/pathspec/ignore/filter | Should | 🟡 INFERRED |
| Specialized similarity tuning | Could | 🟡 INFERRED |

| Legacy area | Coverage | Confidence |
| --- | --- | --- |
| `lib/src/index.dart`, index tests | entries, persistence, conflicts, tree write | 🟢 CONFIRMED |
| `checkout.dart`, `diff.dart`, `patch.dart` and tests | materialization, diff, apply, inspection | 🟢 CONFIRMED |
| `stash.dart`, `pathspec.dart`, `ignore.dart`, `filter.dart`, `attr_options.dart` | supporting mutable projection features | 🟢 CONFIRMED |
| corresponding `lib/src/bindings/` files | native boundary and cleanup | 🟢 CONFIRMED |

