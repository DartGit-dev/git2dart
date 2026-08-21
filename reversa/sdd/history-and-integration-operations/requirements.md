# History and Integration Operations Requirements

> 🟢 **CONFIRMED** — This unit specifies revision parsing/walking, merge/rebase/cherry-pick-related integration, blame, notes, mailmap, messages/trailers, pack building, and submodules.

## Responsibilities and Rules

- 🟢 **CONFIRMED** — Resolve revision expressions and traverse commit graphs with typed sorting/hide/push controls.
- 🟢 **CONFIRMED** — Analyze and execute merge/rebase flows while preserving index conflicts and repository state.
- 🟢 **CONFIRMED** — Project blame, notes, mailmap, message trailers, describe/pack helpers, and submodule metadata/lifecycle.

| ID | Rule | Confidence |
| --- | --- | --- |
| BR-HI-01 | Revision walk requires at least one pushed root and resets after completion. | 🟢 CONFIRMED |
| BR-HI-02 | Range `A..B` hides A and ancestors and pushes B. | 🟢 CONFIRMED |
| BR-HI-03 | Merge analysis distinguishes up-to-date, fast-forward, unborn, and normal merge plus preference. | 🟢 CONFIRMED |
| BR-HI-04 | Normal workdir merge leaves repository in merge state until cleanup. | 🟢 CONFIRMED |
| BR-HI-05 | Rebase applies one operation at a time; conflicts must be resolved before committing it. | 🟢 CONFIRMED |
| BR-HI-06 | Rebase finish advances final state; abort restores pre-rebase state under native semantics. | 🟢 CONFIRMED |
| BR-HI-07 | Submodule add performs setup, clone, then finalize. | 🟢 CONFIRMED |
| BR-HI-08 | Submodule workdir OID alone is not a complete dirty-state indicator. | 🟢 CONFIRMED |

## Functional Requirements

| ID | Requirement | Priority | Acceptance summary | Confidence |
| --- | --- | --- | --- | --- |
| FR-HI-01 | Parse single/range revision expressions into typed commits/objects and flags. | Must | Valid expressions resolve; invalid/unsupported targets throw. | 🟢 CONFIRMED |
| FR-HI-02 | Walk history with push/hide/range/glob/ref/head and sorting controls. | Must | Ordered commits follow selected roots/hides and walker resets. | 🟢 CONFIRMED |
| FR-HI-03 | Analyze merge inputs and preferences before policy selection. | Must | Result bitset distinguishes no-op/fast-forward/unborn/normal. | 🟢 CONFIRMED |
| FR-HI-04 | Execute merge/cherry-pick/revert integration with typed favor/flags/options. | Must | Index/workdir and repository state reflect native result/conflicts. | 🟢 CONFIRMED |
| FR-HI-05 | Initialize/open/iterate/commit/finish/abort rebase. | Must | Operations are sequential and conflicts block current commit. | 🟢 CONFIRMED |
| FR-HI-06 | Compute blame and project hunks, identities, paths, and commit origins. | Should | Line attribution matches selected options/ranges. | 🟢 CONFIRMED |
| FR-HI-07 | Create/read/list/remove notes and manage mailmap identity resolution. | Should | OIDs/messages/signatures and canonical identity mapping persist. | 🟢 CONFIRMED |
| FR-HI-08 | Parse message prettification and trailers. | Could | Parsed fields preserve native message semantics. | 🟢 CONFIRMED |
| FR-HI-09 | Build packs from selected objects/walks with progress/thread controls. | Should | Pack bytes/files and counts match inserted objects. | 🟢 CONFIRMED |
| FR-HI-10 | Add/list/lookup/open/init/sync/reload/update/clone/finalize submodules and expose status/OIDs. | Must | Parent config/index/workdir and nested repository state follow native rules. | 🟢 CONFIRMED |
| FR-HI-11 | Release owned revision, merge/rebase, blame, note, mailmap, pack, and submodule handles. | Must | Ownership and temporary callback state release correctly. | 🟢 CONFIRMED |

## Non-Functional Requirements

| Type | Requirement | Confidence |
| --- | --- | --- |
| State integrity | Integration state transitions and cleanup must remain explicit. | 🟢 CONFIRMED |
| Conflict safety | No merge/rebase success may be claimed while unresolved index conflicts remain. | 🟢 CONFIRMED |
| Graph fidelity | Root/hide/order/parent semantics must preserve native commit graph. | 🟢 CONFIRMED |
| Network trust | Submodule clone/update reuses remote credential/certificate contracts. | 🟢 CONFIRMED |
| Recovery | Crash/interruption recovery beyond libgit2 state is not independently guaranteed. | 🔴 GAP |

## Acceptance Criteria

🟢 **CONFIRMED**

```gherkin
Dado two merge heads with known graph relation
Quando merge analysis is executed
Então the result distinguishes up-to-date, fast-forward, unborn, or normal merge
```

🟢 **CONFIRMED**

```gherkin
Dado an in-progress rebase whose next operation conflicts
Quando commit is attempted before conflict resolution
Então the operation fails until the index/workdir conflict is resolved
```

🟢 **CONFIRMED**

```gherkin
Dado a configured submodule
Quando update runs with init and valid callbacks
Então the nested repository is initialized/fetched/checked out under native submodule rules
```

## MoSCoW and Traceability

| Capability | Priority | Confidence |
| --- | --- | --- |
| Revision/merge/rebase/submodule state integrity | Must | 🟢 CONFIRMED |
| Blame/notes/mailmap/pack | Should | 🟡 INFERRED |
| Message/trailer helpers | Could | 🟡 INFERRED |

| Legacy area | Coverage | Confidence |
| --- | --- | --- |
| `revparse.dart`, `revwalk.dart`, `merge.dart`, `rebase.dart` and tests | graph and integration | 🟢 CONFIRMED |
| `blame.dart`, `note.dart`, `mailmap.dart`, `message.dart` and tests | metadata/attribution | 🟢 CONFIRMED |
| `packbuilder.dart`, `submodule.dart` and tests | packaging/nested repositories | 🟢 CONFIRMED |

