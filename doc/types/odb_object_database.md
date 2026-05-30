# ODB (Object Database)

`Odb` provides direct access to the Git object database.

## Opening and Reading

```dart
final odb = repo.odb;
final object = odb.read(oid);

object.oid;
object.type;
object.data;
object.size;
```

## Writing and Listing

```dart
final oid = odb.write(type: GitObject.blob, data: 'content');
final allObjects = odb.objects;
odb.addDiskAlternate('path/to/objects');
```

`Odb` and `OdbObject` own native handles. Call `free()` when deterministic
cleanup is needed.

See [test/odb_test.dart](../../test/odb_test.dart).
