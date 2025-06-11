# Note

Add, remove and read notes attached to objects:

```dart
// Get list of all notes
final notes = Note.list(repo); // => [Note, Note, ...]

// Lookup note for object
final note = Note.lookup(
  repo: repo,
  annotatedOid: repo.head.target,
); // => Note
note.message; // => 'Note content\n'
note.oid; // => Oid

// Create note
final noteOid = Note.create(
  repo: repo,
  author: signature,
  committer: signature,
  annotatedOid: repo.head.target,
  note: 'New note content',
  force: true, // overwrite existing note
); // => Oid

// Delete note
Note.delete(
  repo: repo,
  annotatedOid: repo.head.target,
  author: signature,
  committer: signature,
);
```

---


For more examples see [test/note_test.dart](../../test/note_test.dart).
