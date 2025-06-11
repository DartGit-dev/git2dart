# Blob

Blob create and lookup methods and some of the object getters:

```dart
// Create a new blob from the file at provided path
final oid = Blob.createFromDisk(repo: repo, path: 'path/to/file.txt'); // => Oid

// Lookup blob
final blob = Blob.lookup(repo: repo, oid: repo['e69de29']); // => Blob

blob.oid; // => Oid
blob.content; // => 'content of the file'
blob.size; // => 19
```

---


For more examples see [test/blob_test.dart](../../test/blob_test.dart).
