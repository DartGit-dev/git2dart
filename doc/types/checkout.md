# Checkout

`Checkout` updates the workdir or index from HEAD, an index, or a commit.

## Operations

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

See [test/checkout_test.dart](../../test/checkout_test.dart).
