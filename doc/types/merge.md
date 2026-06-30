# Merge

`Merge` exposes merge analysis, merge base lookup, tree merges, and cherry-pick
helpers.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Analysis and Bases

```dart
final analysis = Merge.analysis(repo: repo, theirHead: theirCommitOid);
final base = Merge.base(repo, ourCommitOid, theirCommitOid);
```

### Operations

```dart
Merge.commit(repo: repo, commit: theirCommit);
Merge.trees(repo: repo, ancestorTree: ancestor, ourTree: ours, theirTree: theirs);
Merge.cherryPick(repo: repo, commit: commit);
```

Merge operations can leave repository state in progress. Use
`repo.stateCleanup()` after resolving or aborting stateful operations.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [merge_test.dart](../../test/merge_test.dart)
