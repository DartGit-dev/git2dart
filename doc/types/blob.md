# Blob

`Blob` represents file content stored in the Git object database.

## Lookup and Creation

```dart
final blob = Blob.lookup(repo: repo, oid: oid);
final oidFromContent = Blob.create(repo: repo, content: 'content');
final oidFromFile = Blob.createFromWorkdir(repo: repo, relativePath: 'file.txt');
```

## Reading

```dart
blob.oid;
blob.content;
blob.size;
blob.isBinary;
```

`Blob` owns a native handle. Call `free()` when deterministic cleanup is needed.

See [test/blob_test.dart](../../test/blob_test.dart).
