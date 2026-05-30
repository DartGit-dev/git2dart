# Stashes

`Stash` saves, lists, applies, pops, and drops repository stash entries.

## Saving and Listing

```dart
final oid = Stash.create(
  repo: repo,
  stasher: repo.defaultSignature,
  message: 'WIP',
);

final stashes = Stash.list(repo);
```

## Applying and Removing

```dart
Stash.apply(repo: repo, index: 0);
Stash.pop(repo: repo, index: 0);
Stash.drop(repo: repo, index: 0);
```

Stash operations mutate the workdir and index.

See [test/stash_test.dart](../../test/stash_test.dart).
