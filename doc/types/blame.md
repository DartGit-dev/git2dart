# Blame

`Blame` maps file lines to the commits that last changed them.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### File Blame

```dart
final blame = Blame.file(repo: repo, path: 'lib/git2dart.dart');

blame.length;
final hunk = blame[0];
hunk.finalCommitOid;
hunk.finalSignature;
hunk.linesInHunk;
```

### Buffer Blame

```dart
final updated = Blame.buffer(reference: blame, buffer: 'updated content');
```

`Blame` owns a native handle. Call `free()` when deterministic cleanup is
needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [blame_test.dart](../../test/blame_test.dart)
