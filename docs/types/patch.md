# Patch

Some API methods to generate patch:

```dart
// Patch from difference between two blobs
final patch = Patch.fromBlobs(
  oldBlob: null, // empty blob
  newBlob: blob,
  newBlobPath: 'file.txt',
); // => Patch

// Patch from entry in the diff list at provided index position
final patch = Patch.fromDiff(diff: diff, index: 0); // => Patch
```

Some methods for inspecting Patch object:

```dart
// Get the content of a patch as a single diff text
patch.text; // => 'diff --git a/modified_file b/modified_file ...'

// Get the size of a patch diff data in bytes
patch.size(); // => 1337

// Get the list of hunks in a patch
patch.hunks; // => [DiffHunk, DiffHunk, ...]
```

---


For more examples see [test/patch_test.dart](../../test/patch_test.dart).
