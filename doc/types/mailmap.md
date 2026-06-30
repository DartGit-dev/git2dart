# Mailmap

`Mailmap` resolves author and committer names and emails using Git mailmap
rules.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Loading

```dart
final empty = Mailmap.empty();
final fromBuffer = Mailmap.fromBuffer('Correct Name <correct@example.com> <old@example.com>');
final fromRepo = Mailmap.fromRepository(repo);
```

### Resolving

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

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [mailmap_test.dart](../../test/mailmap_test.dart)
