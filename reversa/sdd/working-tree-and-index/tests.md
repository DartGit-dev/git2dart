# Working Tree and Index — Test Specification

> 🟢 **CONFIRMED** — Tests must use isolated repositories because this unit intentionally mutates index and filesystem state.

## Coverage Matrix

| Area | Positive | Negative/boundary | Confidence |
| --- | --- | --- | --- |
| Index | entry/path/buffer/bulk add, update/remove, read/write/clear/tree | invalid type/path, conflict writeTree, owner mismatch | 🟢 CONFIRMED |
| Conflicts | ancestor/ours/theirs, iteration, add/remove/cleanup, NAME/REUC | missing sides/entries, partial resolution | 🟢 CONFIRMED |
| Checkout | every source, strategies, paths, callbacks | bare, safety conflict, callback abort, invalid target | 🟢 CONFIRMED / 🔴 GAP partial state |
| Diff | every endpoint, stats, merge, similarity | two null trees, invalid thresholds/endpoints | 🟢 CONFIRMED |
| Apply | check-only, full/hunk, three locations/tree | non-applicable, conflict, invalid hunk | 🟢 CONFIRMED |
| Patch | text/binary, hunks/lines/coordinates/stats | invalid index and parent lifetime | 🟢 CONFIRMED / 🔴 GAP lifetime |
| Stash | save/list/apply/pop/drop/options | invalid index, apply failure | 🟢 CONFIRMED / 🔴 GAP failure residue |
| Match/filter | pathspec endpoints/failures, ignore/attr/filter | empty/invalid pattern/path, binary data | 🟢 CONFIRMED |

## Acceptance Scenarios

🟢 **CONFIRMED**

```gherkin
Dado a conflict-free index with staged paths
Quando the index is written and serialized as a tree
Então the returned Oid resolves to the staged tree content
```

🟢 **CONFIRMED**

```gherkin
Dado an index containing unresolved conflict stages
Quando writeTree is requested
Então a translated error is thrown until every conflict is resolved
```

🟢 **CONFIRMED**

```gherkin
Dado a diff that is applicable to the workdir
Quando applies is called before apply
Então applies reports true without mutation and apply then changes the selected projection
```

🔴 **GAP**

```gherkin
Dado a multi-file checkout with an injected mid-operation failure
Quando native checkout aborts
Então the residual filesystem state is captured without assuming rollback
```

## Additional Tests

| ID | Test | Done condition | Confidence |
| --- | --- | --- | --- |
| TT-WI-A1 | Mutation fault injection | Residual index/workdir/stash state is documented at every failure point. | 🔴 GAP |
| TT-WI-A2 | Borrowed patch lifetime | Supported parent/view lifetime is enforced or documented. | 🔴 GAP |
| TT-WI-A3 | Callback overlap/abort | Distinct operations cannot corrupt callback state. | 🔴 GAP |
| TT-WI-A4 | Platform filesystem matrix | Case, separator, symlink, executable mode, permissions pass with recorded differences. | 🔴 GAP |
| TT-WI-A5 | Resource instrumentation | No leak/double release across constructors, apply, patch, stash, and pathspec failures. | 🔴 GAP |

## Gate

- 🟢 **CONFIRMED** — Existing index/diff/patch/checkout/stash/pathspec/ignore/filter tests are the legacy baseline.
- 🟢 **CONFIRMED** — Format, zero-warning analysis, and full Flutter tests are required.
- 🔴 **GAP** — No fresh suite or mutation fault-injection run occurred during Writer generation.

