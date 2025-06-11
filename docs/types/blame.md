# Blame

Show what revision and author last modified each line of a file:

```dart
// Get blame for file
final blame = Blame.file(
  repo: repo,
  path: 'path/to/file.txt',
); // => Blame

// Get blame hunk for specific line
final hunk = blame.forLine(5); // => BlameHunk
hunk.finalCommitOid; // => Oid
hunk.finalCommitter; // => Signature
hunk.originalPath; // => 'path/to/file.txt'

// Get blame with options
final blame = Blame.file(
  repo: repo,
  path: 'file.txt',
  newestCommit: repo['fc38877'],
  oldestCommit: repo['f17d0d4'],
  minLine: 1,
  maxLine: 10,
);

// Get blame for buffer
final blame = Blame.buffer(
  reference: existingBlame,
  buffer: 'new content',
);
```

---


For more examples see [test/blame_test.dart](../../test/blame_test.dart).
