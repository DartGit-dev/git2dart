# Blob

`Blob` represents file content stored in the Git object database.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Lookup and Creation

```dart
final blob = Blob.lookup(repo: repo, oid: oid);
final oidFromContent = Blob.create(repo: repo, content: 'content');
final oidFromFile = Blob.createFromWorkdir(repo: repo, relativePath: 'file.txt');
```

### Reading

```dart
blob.oid;
blob.content;
blob.size;
blob.isBinary;
```

`Blob` owns a native handle. Call `free()` when deterministic cleanup is needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [blob_test.dart](../../test/blob_test.dart)
