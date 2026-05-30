# Diff

`Diff` represents changes between trees, indexes, workdirs, or patch text.

## Creating Diffs

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

## Inspecting Diffs

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

See [test/diff_test.dart](../../test/diff_test.dart).
