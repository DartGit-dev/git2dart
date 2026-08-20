# History and Integration Operations — Test Specification

> 🟢 **CONFIRMED** — Stateful tests must assert repository state and index/workdir outcomes, not only method return values.

## Coverage Matrix

| Area | Positive | Negative/recovery | Confidence |
| --- | --- | --- | --- |
| RevParse/RevWalk | single/range/root/hide/sort/limit/reset | invalid expression, unsupported kind, no root | 🟢 CONFIRMED |
| Merge | bases, all analysis classes, clean commit | no base, conflict, cleanup failure, partial state | 🟢 CONFIRMED / 🔴 GAP interruption |
| Rebase | init/open/next/commit/finish/abort | conflict, invalid order, reopen, interruption | 🟢 CONFIRMED / 🔴 GAP crash |
| Blame | file/buffer/options/hunks | invalid path/range, rename/copy edges | 🟢 CONFIRMED |
| Note/Mailmap/Message | lifecycle/mapping/prettify/trailers | duplicate/missing/malformed | 🟢 CONFIRMED |
| PackBuilder | insert/walk/write/callback/progress | callback/write failure and partial output | 🟢 CONFIRMED / 🔴 GAP residue |
| Submodule | add/list/status/open/init/sync/update | missing locations, auth/trust, partial add/update | 🟢 CONFIRMED / 🔴 GAP live/recovery |

## Acceptance Scenarios

🟢 **CONFIRMED**

```gherkin
Dado merge heads whose relation is fast-forward
Quando merge analysis is executed
Então fast-forward is reported without performing a normal merge commit
```

🟢 **CONFIRMED**

```gherkin
Dado an in-progress rebase with a conflicting operation
Quando next applies the operation and commit is attempted
Então commit fails until conflict entries are resolved
```

🔴 **GAP**

```gherkin
Dado a submodule add interrupted after setup but before finalize
Quando the parent and nested repositories are reopened
Então residual state and the supported recovery procedure are recorded
```

## Additional Required Tests

- 🔴 **GAP** — Fault injection at every merge/rebase transition with reopen and cleanup verification.
- 🔴 **GAP** — Concurrent integration-operation characterization on one repository.
- 🔴 **GAP** — Submodule setup/clone/finalize/update live matrix on all platforms.
- 🔴 **GAP** — Pack callback/write failure partial-output cleanup.
- 🔴 **GAP** — Native ownership instrumentation for all stateful wrappers.

## Gate

- 🟢 **CONFIRMED** — Existing revparse/revwalk/merge/rebase/blame/note/mailmap/message/packbuilder/submodule tests are the legacy baseline.
- 🟢 **CONFIRMED** — Format, zero-warning analysis, and isolated full tests are required.
- 🔴 **GAP** — No fresh tests, interruption tests, or live submodule tests ran during Writer generation.

