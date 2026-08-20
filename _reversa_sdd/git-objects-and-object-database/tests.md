# Git Objects and Object Database — Test Specification

> 🟢 **CONFIRMED** — Legacy test presence is evidence of intended coverage, not a fresh Writer-phase execution result.

## Coverage Matrix

| Area | Required positive cases | Required negative/boundary cases | Confidence |
| --- | --- | --- | --- |
| OID | full parse, prefix lookup, copy, compare, shorten | invalid hex/length, missing, ambiguous prefix | 🟢 CONFIRMED |
| Commit | root, normal, merge, buffer, amend | wrong OID/type, cross-repository relations, native failure | 🟢 CONFIRMED |
| Tree/Builder | index/name/path, update, insert/remove/filter/write | missing path, invalid index/type/mode, conflicts/duplicates | 🟢 CONFIRMED |
| Blob/Stream | text, bytes, empty, disk/workdir, multi-write commit | missing path, post-commit use, abort/failure cleanup | 🟢 CONFIRMED / 🔴 GAP lifecycle edges |
| Tag | lightweight/annotated, all target kinds, peel/list/delete | duplicate without force, missing tag, unsupported kind | 🟢 CONFIRMED |
| ODB | hash/write/read/header/exists/prefix/foreach/backend | pseudo types, missing/ambiguous OID, invalid backend | 🟢 CONFIRMED |
| Signature/Annotated/Graph | identity/time, constructors, reachability | invalid source/reference/OID and graph failures | 🟢 CONFIRMED |
| Ownership | manual free and finalizer detachment | repeated free, borrowed-after-parent, injected native failures | 🔴 GAP for exhaustive proof |
| Hash format | SHA-1 baseline | SHA-256 full matrix | 🔴 GAP |

## Acceptance Scenarios

🟢 **CONFIRMED**

```gherkin
Dado a root tree and valid signatures
Quando a commit is created with no parents
Então the returned Oid resolves to a root commit preserving the supplied metadata
```

🟢 **CONFIRMED**

```gherkin
Dado a baseline tree containing two entries
Quando one null-Oid removal and one non-null upsert are applied
Então a new tree contains the upsert and omits the removed path
```

🟢 **CONFIRMED**

```gherkin
Dado binary bytes and GitObject.blob
Quando the content is written and read through ODB
Então the returned bytes are identical and the Oid is stable
```

🟢 **CONFIRMED**

```gherkin
Dado binary bytes and a delta pseudo-type
Quando ODB write is requested
Então ArgumentError is thrown before native persistence
```

🔴 **GAP**

```gherkin
Dado a committed BlobWriteStream
Quando write, commit, or free is invoked again
Então the intended terminal-state behavior must be characterized without double release
```

## Legacy Test Sources

- 🟢 **CONFIRMED** — `test/oid_test.dart`, `test/commit_test.dart`, `test/tree_test.dart`, `test/treebuilder_test.dart`.
- 🟢 **CONFIRMED** — Blob, tag, ODB, signature, annotated-commit, and commit-graph test files corresponding to their public wrappers.
- 🟢 **CONFIRMED** — Manual-release tests establish explicit cleanup intent.
- 🔴 **GAP** — The historical `test_run.log` is not current proof for these files.

## Additional Required Tests

| ID | Test | Done condition | Confidence |
| --- | --- | --- | --- |
| TT-OBJ-A1 | SHA-256 matrix | Every public object operation has a platform-tagged verdict. | 🔴 GAP |
| TT-OBJ-A2 | Allocation fault injection | Each native failure point leaves zero leaked/double-freed owned resources. | 🔴 GAP |
| TT-OBJ-A3 | Borrowed lifetime | Parent release cannot leave a falsely documented safe entry view. | 🔴 GAP |
| TT-OBJ-A4 | Stream terminal states | Commit/abort/free/finalizer sequences are deterministic and safe. | 🔴 GAP |
| TT-OBJ-A5 | Large binary objects | Byte fidelity and configured memory limits are verified. | 🔴 GAP |
| TT-OBJ-A6 | Cross-platform focused/full suite | Fresh results exist for all declared platforms. | 🔴 GAP until run |

## Quality Gate

- 🟢 **CONFIRMED** — Format and zero-warning analysis are required.
- 🟢 **CONFIRMED** — Each public API element requires positive and negative tests under project policy.
- 🟢 **CONFIRMED** — Performance-critical object paths should add micro-benchmarks when reimplemented.
- 🔴 **GAP** — No fresh tests or benchmarks were run during specification generation.

