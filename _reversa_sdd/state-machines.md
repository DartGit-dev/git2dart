# State Machines

> These state machines combine explicit enums and documented operation contracts. Transitions not directly encapsulated by one high-level method are marked inferred.

## Repository Operation State

```mermaid
stateDiagram-v2
    [*] --> None
    None --> Merge: Merge.commit
    None --> Revert: Commit.revert
    None --> CherryPick: Merge.cherryPick
    None --> Rebase: Rebase.init/open
    None --> ApplyMailbox: external/native operation
    None --> Bisect: external/native operation
    Merge --> None: Repository.stateCleanup
    Revert --> None: Repository.stateCleanup
    CherryPick --> None: Repository.stateCleanup
    Rebase --> None: Rebase.finish or Rebase.abort
    ApplyMailbox --> None: Repository.stateCleanup
    Bisect --> None: cleanup/end operation
```

- 🟢 States are defined by `GitRepositoryState`: none, merge, revert, revertSequence, cherrypick, cherrypickSequence, bisect, rebase, rebaseInteractive, rebaseMerge, applyMailbox, applyMailboxOrRebase.
- 🟢 Merge documentation explicitly requires `stateCleanup` after commit/abort.
- 🟡 Some transitions are available through libgit2 state observed by this package but are not all started by dedicated high-level wrappers.

## Rebase Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Initialized: Rebase.init
    [*] --> InProgress: Rebase.open
    Initialized --> Applying: next
    InProgress --> Applying: next
    Applying --> Conflicted: patch creates conflicts
    Applying --> ReadyToCommit: patch clean
    Conflicted --> ReadyToCommit: caller resolves index/workdir
    ReadyToCommit --> InProgress: commit
    InProgress --> Applying: next operation
    InProgress --> Finished: finish after final operation
    Initialized --> Aborted: abort
    InProgress --> Aborted: abort
    Applying --> Aborted: abort
    Conflicted --> Aborted: abort
    Finished --> [*]
    Aborted --> [*]
```

All main transitions are 🟢 confirmed by `lib/src/rebase.dart`; conflict detection is represented through the index rather than an explicit Dart rebase status field.

## Index Conflict Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Clean
    Clean --> Conflicted: merge/rebase or addConflict
    Conflicted --> PartiallyResolved: replace one or more paths
    PartiallyResolved --> Conflicted: unresolved paths remain
    PartiallyResolved --> ResolvedInMemory: all conflict stages removed
    Conflicted --> ResolvedInMemory: cleanupConflict or resolve all entries
    ResolvedInMemory --> Persisted: Index.write
    Persisted --> TreeWritten: Index.writeTree
    Clean --> TreeWritten: Index.writeTree
```

- 🟢 `hasConflicts` and ancestor/ours/theirs entries define conflicted state.
- 🟢 `writeTree` rejects unresolved conflicts.
- 🟢 `addFromBuffer` moves conflict history to REUC when resolving a path.

## Reference Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Direct: create with Oid
    [*] --> Symbolic: create with String
    Direct --> Direct: setTarget Oid or createMatching Oid
    Symbolic --> Symbolic: setTarget String or createMatching String
    Symbolic --> ResolvedDirect: resolve target
    Direct --> Renamed: rename
    Symbolic --> Renamed: rename
    Renamed --> Deleted: delete/remove
    Direct --> Deleted: delete/remove
    Symbolic --> Deleted: delete/remove
```

Representation-changing updates are not exposed through a single matching operation; direct and symbolic compare-and-set paths require matching representations.

## Native Resource Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Allocated: binding returns owned pointer
    Allocated --> Wrapped: high-level object stores pointer
    Wrapped --> ExplicitlyFreed: free
    Wrapped --> Finalized: garbage collection finalizer
    ExplicitlyFreed --> [*]
    Finalized --> [*]
    Wrapped --> Transferred: ownership passed to libgit2/another wrapper
    Transferred --> [*]
```

- 🟢 Explicit `free()` detaches the finalizer.
- 🟢 Borrowed entries and callback views do not enter this owned lifecycle and must not outlive their parent.

## Remote Operation Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Configured
    Configured --> Connecting: ls/fetch/push
    Connecting --> Authenticating: credential callback
    Authenticating --> ValidatingCertificate: certificate callback/default validation
    ValidatingCertificate --> Transferring: accepted
    ValidatingCertificate --> Failed: rejected
    Transferring --> UpdatingRefs: fetch/push update callbacks
    UpdatingRefs --> Completed
    Connecting --> Failed: transport error
    Authenticating --> Failed: credential error
    Completed --> [*]
    Failed --> [*]
```

This is 🟡 inferred from the native callback and high-level operation order; libgit2 owns the internal transport state machine.

