# Attributes

Attributes expose Git attribute lookup for paths in a repository.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Repository Helpers

```dart
final value = repo.getAttribute(path: 'file.txt', name: 'text');
final values = repo.getAttributesMany(
  path: 'file.txt',
  names: ['text', 'diff'],
);

final options = AttrOptions();
final extended = repo.getAttributesManyExt(
  options: options,
  path: 'file.txt',
  names: ['text', 'diff'],
);
```

### Options

Use `AttrOptions` when an API needs explicit attribute lookup flags or a commit
to load attributes from.

```dart
final options = AttrOptions(flags: {GitAttributeCheck.fileThenIndex});
options.free();
```

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [attr_options_test.dart](../../test/attr_options_test.dart)
- [repository_test.dart](../../test/repository_test.dart)
