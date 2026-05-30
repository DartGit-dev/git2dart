# Attributes

Attributes expose Git attribute lookup for paths in a repository.

## Repository Helpers

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

## Options

Use `AttrOptions` when an API needs explicit attribute lookup flags or a commit
to load attributes from.

```dart
final options = AttrOptions(flags: {GitAttributeCheck.fileThenIndex});
options.free();
```

See [test/attr_options_test.dart](../../test/attr_options_test.dart) and
[test/repository_test.dart](../../test/repository_test.dart).
