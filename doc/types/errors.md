# Error Handling

git2dart throws Dart exceptions for invalid Dart-side input and libgit2
failures.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Common error types

- `LibGit2Error` is thrown when libgit2 returns an error code. The type is
  defined by the `git2dart_binaries` package that provides the native bindings.
- `Git2DartError` is thrown by Dart-side wrappers for package-level validation,
  such as out-of-bounds access in iterable wrappers.
- `ArgumentError` is thrown for invalid Dart arguments before libgit2 is called.

### Usage

```dart
try {
  final oid = Oid.fromSHA(repo, '0000000');
  final blob = Blob.lookup(repo: repo, oid: oid);
  print(blob.content);
} on ArgumentError catch (error) {
  print('Invalid input: $error');
} on Git2DartError catch (error) {
  print('git2dart failed: $error');
} catch (error) {
  print('Git operation failed: $error');
}
```

`Git2DartError.toString()` returns the message, and `stackTrace` is available
for diagnostics.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Error types do not own native resources. Catch `ArgumentError` for invalid Dart input and catch broader Git operation failures around libgit2 calls.

## See Also

- [error_test.dart](../../test/error_test.dart)
