# Describe

`Repository.describe` produces human-readable names for commits or workdir
state, similar to `git describe`.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Commit and Workdir

```dart
final workdirDescription = repo.describe();
final commitDescription = repo.describe(commit: commit);
```

### Formatting

```dart
final text = repo.describe(
  commit: commit,
  abbreviatedSize: 7,
  alwaysUseLongFormat: true,
  dirtySuffix: '-dirty',
);
```

The public API returns a formatted `String`; temporary native describe results
are freed internally.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [describe_test.dart](../../test/describe_test.dart)
