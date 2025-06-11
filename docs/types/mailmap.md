# Mailmap

Map author/committer names and emails:

```dart
// Create empty mailmap
final mailmap = Mailmap.empty();

// Create from buffer
final mailmap = Mailmap.fromBuffer('''
Joe Developer <joe@example.com> <joe@old.com>
Jane Doe <jane@example.com> <jane.doe@old.com>
''');

// Create from repository
final mailmap = Mailmap.fromRepository(repo);

// Add entry
mailmap.addEntry(
  realName: 'Joe Developer',
  realEmail: 'joe@example.com',
  replaceName: 'joe',
  replaceEmail: 'joe@old.com',
);

// Resolve name and email
final resolved = mailmap.resolve(
  name: 'joe',
  email: 'joe@old.com',
); // => ['Joe Developer', 'joe@example.com']

// Resolve signature
final resolvedSig = mailmap.resolveSignature(signature);
```

---


For more examples see [test/mailmap_test.dart](../../test/mailmap_test.dart).
