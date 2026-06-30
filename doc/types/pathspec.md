# Pathspec

`Pathspec` compiles Git pathspec patterns and matches them against paths,
workdirs, indexes, trees, and diffs.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Matching

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

### Results

```dart
workdirMatches.entries;
workdirMatches.failedEntries;
```

`Pathspec` and `PathspecMatchList` own native memory. They have finalizers, but
call `free()` in long-running code once the objects are no longer needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [pathspec_test.dart](../../test/pathspec_test.dart)
