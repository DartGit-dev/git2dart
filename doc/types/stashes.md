# Stashes

`Stash` saves, lists, applies, pops, and drops repository stash entries.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Saving and Listing

```dart
final oid = Stash.create(
  repo: repo,
  stasher: repo.defaultSignature,
  message: 'WIP',
);

final stashes = Stash.list(repo);
```

### Applying and Removing

```dart
Stash.apply(repo: repo, index: 0);
Stash.pop(repo: repo, index: 0);
Stash.drop(repo: repo, index: 0);
```

Stash operations mutate the workdir and index.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [stash_test.dart](../../test/stash_test.dart)
