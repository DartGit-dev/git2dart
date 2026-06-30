# Patch

`Patch` represents the textual patch for one file delta or for buffer/blob
comparisons.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Creating Patches

```dart
final patch = Patch.fromDiff(diff: diff, index: 0);
final fromBuffers = Patch.fromBuffers(
  oldBuffer: 'old\n',
  newBuffer: 'new\n',
);
final fromBlobs = Patch.fromBlobs(oldBlob: oldBlob, newBlob: newBlob);
```

### Inspecting

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

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [patch_test.dart](../../test/patch_test.dart)
