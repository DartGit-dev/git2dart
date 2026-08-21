# History and Integration Operations — Operational Flows

> 🟢 **CONFIRMED** — These flows emphasize graph selection, conflict-mediated state, and cleanup.

## FL-HI-01 — Parse and Walk Revisions

```mermaid
flowchart TD
    A["Revision expression / roots"] --> B["RevParse resolves typed object or range"]
    B --> C["Configure RevWalk sorting"]
    C --> D["Push roots/refs/globs/HEAD"]
    D --> E["Hide exclusions/range-left ancestry"]
    E --> F{"Next Oid?"}
    F -- Yes --> G["Lookup Commit and append"]
    G --> F
    F -- No --> H["Reset walker and return commits"]
```

- 🟢 **CONFIRMED** — No pushed root is invalid for walking.
- 🟢 **CONFIRMED** — `A..B` hides A ancestry and pushes B.

## FL-HI-02 — Analyze and Execute Merge

```mermaid
flowchart TD
    A["Our ref + their head"] --> B["Merge analysis"]
    B --> C{"Analysis"}
    C -- Up-to-date --> D["No action"]
    C -- Fast-forward --> E["Advance reference/checkout by caller policy"]
    C -- Unborn --> F["Establish initial target"]
    C -- Normal --> G["Merge into index/workdir"]
    G --> H{"Conflicts?"}
    H -- Yes --> I["Resolve index/workdir"]
    H -- No --> J["Create merge commit"]
    I --> J
    J --> K["stateCleanup"]
```

## FL-HI-03 — Rebase

```mermaid
flowchart TD
    A["init or open rebase"] --> B{"next operation?"}
    B -- No --> C["finish and advance final state"]
    B -- Yes --> D["apply operation"]
    D --> E{"conflicts?"}
    E -- Yes --> F["caller resolves index/workdir"]
    E -- No --> G["commit operation"]
    F --> G
    G --> B
    A --> H["abort option"]
    H --> I["restore pre-rebase state"]
```

## FL-HI-04 — Blame a File

1. 🟢 **CONFIRMED** — Marshal path, revision range, line bounds, and blame flags.
2. 🟢 **CONFIRMED** — Acquire native blame and enumerate hunks.
3. 🟢 **CONFIRMED** — Project final/origin commit OIDs, signatures, paths, and line positions.
4. 🟢 **CONFIRMED** — Optionally apply an in-memory buffer update.
5. 🟢 **CONFIRMED** — Release owned blame resource.

## FL-HI-05 — Add a Submodule

```mermaid
sequenceDiagram
    participant C as Caller
    participant S as Submodule API
    participant L as libgit2
    participant P as Parent repository
    participant N as Nested remote/repository
    C->>S: URL, path, callbacks/options
    S->>L: add setup
    L->>P: update preliminary config/index state
    S->>L: clone nested repository
    L->>N: authenticate/validate/transfer
    S->>L: add finalize
    L->>P: finalize parent metadata
    S-->>C: owned Submodule
```

- 🟢 **CONFIRMED** — Update/init uses the same remote trust and credential boundary as remotes.
- 🔴 **GAP** — Partial parent/nested state after setup/clone/finalize failure needs characterization.

## FL-HI-06 — Build a Pack

1. 🟢 **CONFIRMED** — Create owned `PackBuilder` for a repository.
2. 🟢 **CONFIRMED** — Insert OIDs/trees/commits recursively or insert a revision walk.
3. 🟢 **CONFIRMED** — Configure threads/progress.
4. 🟢 **CONFIRMED** — Write to file or emit bytes through callback.
5. 🟢 **CONFIRMED** — Expose count/written length/name and release builder.

## Gaps

- 🔴 **GAP** — Power-loss/crash recovery across merge/rebase/submodule steps.
- 🔴 **GAP** — Idempotency of retry after partial native mutation.
- 🔴 **GAP** — Live submodule transport and callback overlap.
- 🔴 **GAP** — Complete stateful native resource cleanup proof.

