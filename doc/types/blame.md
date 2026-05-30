# Blame

`Blame` maps file lines to the commits that last changed them.

## File Blame

```dart
final blame = Blame.file(repo: repo, path: 'lib/git2dart.dart');

blame.length;
final hunk = blame[0];
hunk.finalCommitOid;
hunk.finalSignature;
hunk.linesInHunk;
```

## Buffer Blame

```dart
final updated = Blame.buffer(reference: blame, buffer: 'updated content');
```

`Blame` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/blame_test.dart](../../test/blame_test.dart).
