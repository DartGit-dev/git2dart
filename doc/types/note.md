# Note

`Note` reads and writes Git notes for objects.

## Listing and Lookup

```dart
final notes = Note.list(repo);
final note = Note.lookup(repo: repo, annotatedOid: commit.oid);

note.message;
note.oid;
note.annotatedOid;
```

## Creating and Deleting

```dart
final oid = Note.create(
  repo: repo,
  author: repo.defaultSignature,
  committer: repo.defaultSignature,
  annotatedOid: commit.oid,
  note: 'Reviewed',
);

Note.delete(
  repo: repo,
  author: repo.defaultSignature,
  committer: repo.defaultSignature,
  annotatedOid: commit.oid,
);
```

`Note` owns a native handle. Call `free()` when deterministic cleanup is needed.

See [test/note_test.dart](../../test/note_test.dart).
