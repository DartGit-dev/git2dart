# Merge

`Merge` exposes merge analysis, merge base lookup, tree merges, and cherry-pick
helpers.

## Analysis and Bases

```dart
final analysis = Merge.analysis(repo: repo, theirHead: theirCommitOid);
final base = Merge.base(repo, ourCommitOid, theirCommitOid);
```

## Operations

```dart
Merge.commit(repo: repo, commit: theirCommit);
Merge.trees(repo: repo, ancestorTree: ancestor, ourTree: ours, theirTree: theirs);
Merge.cherryPick(repo: repo, commit: commit);
```

Merge operations can leave repository state in progress. Use
`repo.stateCleanup()` after resolving or aborting stateful operations.

See [test/merge_test.dart](../../test/merge_test.dart).
