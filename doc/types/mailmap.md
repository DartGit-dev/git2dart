# Mailmap

`Mailmap` resolves author and committer names and emails using Git mailmap
rules.

## Loading

```dart
final empty = Mailmap.empty();
final fromBuffer = Mailmap.fromBuffer('Correct Name <correct@example.com> <old@example.com>');
final fromRepo = Mailmap.fromRepository(repo);
```

## Resolving

```dart
final resolved = mailmap.resolve(
  name: 'Old Name',
  email: 'old@example.com',
);

mailmap.addEntry(
  realName: 'Correct Name',
  realEmail: 'correct@example.com',
  replaceName: 'Old Name',
  replaceEmail: 'old@example.com',
);
```

`Mailmap` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/mailmap_test.dart](../../test/mailmap_test.dart).
