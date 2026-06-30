# Checkout

`Checkout` updates the workdir or index from HEAD, an index, or a commit.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Operations

```dart
Checkout.head(repo: repo);
Checkout.index(repo: repo, index: repo.index);
Checkout.reference(repo: repo, name: 'refs/heads/feature');
Checkout.commit(repo: repo, commit: commit);
```

Use checkout options to control strategy, paths, target directory, and conflict
handling.

```dart
Checkout.head(
  repo: repo,
  strategy: {GitCheckout.force},
  paths: ['lib/git2dart.dart'],
);
```

Checkout operations mutate the workdir and/or index.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [checkout_test.dart](../../test/checkout_test.dart)
