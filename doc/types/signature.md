# Signature

`Signature` stores a Git identity and timestamp for commits, tags, reflogs, and
stash operations.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Creating Signatures

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

### Reading

```dart
signature.name;
signature.email;
signature.time;
signature.offset;
```

`Signature` owns a native handle. Call `free()` when deterministic cleanup is
needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [signature_test.dart](../../test/signature_test.dart)
