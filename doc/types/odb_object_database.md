# ODB (Object Database)

`Odb` provides direct access to the Git object database.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Opening and Reading

```dart
final odb = repo.odb;
final object = odb.read(oid);

object.oid;
object.type;
object.data;
object.size;
```

### Writing and Listing

```dart
final oid = odb.write(type: GitObject.blob, data: 'content');
final allObjects = odb.objects;
odb.addDiskAlternate('path/to/objects');
```

`Odb` and `OdbObject` own native handles. Call `free()` when deterministic
cleanup is needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [odb_test.dart](../../test/odb_test.dart)
