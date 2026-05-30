# Patch

`Patch` represents the textual patch for one file delta or for buffer/blob
comparisons.

## Creating Patches

```dart
final patch = Patch.fromDiff(diff: diff, index: 0);
final fromBuffers = Patch.fromBuffers(
  oldBuffer: 'old\n',
  newBuffer: 'new\n',
);
final fromBlobs = Patch.fromBlobs(oldBlob: oldBlob, newBlob: newBlob);
```

## Inspecting

```dart
patch.text;
patch.size();
patch.delta;
patch.hunks;

for (final hunk in patch.hunks) {
  hunk.header;
  hunk.lines;
}
```

`Patch` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/patch_test.dart](../../test/patch_test.dart).
