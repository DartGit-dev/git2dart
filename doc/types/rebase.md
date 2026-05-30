# Rebase

`Rebase` represents an in-progress rebase operation.

## Starting and Opening

```dart
final rebase = Rebase.init(
  repo: repo,
  branch: branch,
  upstream: upstream,
  onto: onto,
);

final existing = Rebase.open(repo);
```

## Iterating

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

See [test/rebase_test.dart](../../test/rebase_test.dart).
