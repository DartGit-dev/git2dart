# Signature

`Signature` stores a Git identity and timestamp for commits, tags, reflogs, and
stash operations.

## Creating Signatures

```dart
final signature = Signature.create(
  name: 'A User',
  email: 'a@example.com',
  time: 1710000000,
  offset: 0,
);

final now = Signature.create(name: 'A User', email: 'a@example.com');
final defaultSignature = repo.defaultSignature;
```

## Reading

```dart
signature.name;
signature.email;
signature.time;
signature.offset;
```

`Signature` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/signature_test.dart](../../test/signature_test.dart).
