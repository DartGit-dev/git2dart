# RevParse

Revparse helpers resolve Git revision specifications to objects or ranges.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Single Object

```dart
final object = RevParse.single(repo: repo, spec: 'HEAD^{commit}');
```

### Extended Parse

```dart
final result = RevParse.ext(repo: repo, spec: 'HEAD~1');

result.object;
result.reference;
```

### Ranges

```dart
final range = RevParse.range(repo: repo, spec: 'main..feature');
range.from;
range.to;
```

Revision syntax follows Git revision rules.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [revparse_test.dart](../../test/revparse_test.dart)
