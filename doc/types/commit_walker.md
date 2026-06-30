# Commit Walker

`RevWalk` traverses commit history.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Walking

```dart
final walker = RevWalk(repo);

walker.sorting({GitSort.time});
walker.pushHead();

final commits = walker.walk(limit: 10);
```

### Inputs

```dart
walker.push(commit.oid);
walker.pushGlob('heads/*');
walker.pushReference('refs/heads/main');
walker.pushRange('main..feature');

walker.hide(oldCommit.oid);
walker.hideHead();
walker.reset();
```

`RevWalk` owns a native handle. Call `free()` when deterministic cleanup is
needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [revwalk_test.dart](../../test/revwalk_test.dart)
