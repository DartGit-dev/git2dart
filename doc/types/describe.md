# Describe

`Repository.describe` produces human-readable names for commits or workdir
state, similar to `git describe`.

## Commit and Workdir

```dart
final workdirDescription = repo.describe();
final commitDescription = repo.describe(commit: commit);
```

## Formatting

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

See [test/describe_test.dart](../../test/describe_test.dart).
