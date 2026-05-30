# Pathspec

`Pathspec` compiles Git pathspec patterns and matches them against paths,
workdirs, indexes, trees, and diffs.

## Matching

```dart
final pathspec = Pathspec(['lib/**/*.dart', 'test/**/*.dart']);

pathspec.matchesPath('lib/git2dart.dart');

final workdirMatches = pathspec.matchWorkdir(
  repo: repo,
  flags: {GitPathspec.findFailures},
);
final indexMatches = pathspec.matchIndex(index: repo.index);
final treeMatches = pathspec.matchTree(tree: tree);
final diffMatches = pathspec.matchDiff(diff: diff);
```

## Results

```dart
workdirMatches.entries;
workdirMatches.failedEntries;
```

`Pathspec` and `PathspecMatchList` own native memory. They have finalizers, but
call `free()` in long-running code once the objects are no longer needed.

See [test/pathspec_test.dart](../../test/pathspec_test.dart).
