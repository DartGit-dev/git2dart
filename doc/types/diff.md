# Diff

`Diff` represents changes between trees, indexes, workdirs, or patch text.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Creating Diffs

```dart
final workdirDiff = Diff.indexToWorkdir(repo: repo, index: repo.index);
final indexDiff = Diff.treeToIndex(repo: repo, tree: tree, index: repo.index);
final workdirTreeDiff = Diff.treeToWorkdir(repo: repo, tree: tree);
final combined = Diff.treeToWorkdirWithIndex(repo: repo, tree: tree);
final treeDiff = Diff.treeToTree(repo: repo, oldTree: oldTree, newTree: tree);
final indexToIndex = Diff.indexToIndex(
  repo: repo,
  oldIndex: oldIndex,
  newIndex: repo.index,
);
final parsed = Diff.parse(patchText);
```

### Inspecting Diffs

```dart
diff.length;
diff.lengthOfType(GitDelta.modified);
diff.isSortedICase;
diff.patch;

final perf = diff.perfData;
perf.statCalls;
perf.oidCalculations;

final stats = diff.stats;
stats.insertions;
stats.deletions;
stats.filesChanged;

for (final delta in diff.deltas) {
  delta.status;
  delta.oldFile.path;
  delta.newFile.path;
}
```

`Diff` owns a native `git_diff` handle. Use `free()` for deterministic cleanup.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [diff_test.dart](../../test/diff_test.dart)
