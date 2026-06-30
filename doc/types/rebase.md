# Rebase

`Rebase` represents an in-progress rebase operation.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Starting and Opening

```dart
final rebase = Rebase.init(
  repo: repo,
  branch: branch,
  upstream: upstream,
  onto: onto,
);

final existing = Rebase.open(repo);
```

### Iterating

```dart
final operation = rebase.next();
rebase.commit(committer: repo.defaultSignature, message: 'Apply change\n');
rebase.finish();
```

Use `abort()` to stop an in-progress rebase.

```dart
rebase.abort();
```

`Rebase` owns a native handle. Call `free()` when deterministic cleanup is
needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [rebase_test.dart](../../test/rebase_test.dart)
