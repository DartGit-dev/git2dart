# Note

`Note` reads and writes Git notes for objects.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Listing and Lookup

```dart
final notes = Note.list(repo);
final note = Note.lookup(repo: repo, annotatedOid: commit.oid);

note.message;
note.oid;
note.annotatedOid;
```

### Creating and Deleting

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

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [note_test.dart](../../test/note_test.dart)
