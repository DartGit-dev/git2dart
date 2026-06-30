# Reset

`Reset` moves repository state to a target commit.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Operations

```dart
repo.reset(
  oid: commit.oid,
  resetType: GitReset.hard,
);

repo.resetDefault(
  oid: commit.oid,
  pathspec: ['lib/git2dart.dart'],
);
```

`GitReset.soft`, `GitReset.mixed`, and `GitReset.hard` mirror Git reset modes.
Hard resets update the index and workdir.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [reset_test.dart](../../test/reset_test.dart)
