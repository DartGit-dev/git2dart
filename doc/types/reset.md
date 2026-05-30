# Reset

`Reset` moves repository state to a target commit.

## Operations

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

See [test/reset_test.dart](../../test/reset_test.dart).
