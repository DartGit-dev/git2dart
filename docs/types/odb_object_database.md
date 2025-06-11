# ODB (Object Database)

Direct access to Git object database:

```dart
// Get ODB from repository
final odb = repo.odb; // => Odb

// Check if object exists
odb.contains(oid); // => true/false

// Read object
final obj = odb.read(oid); // => OdbObject
obj.type; // => GitObject.blob
obj.data; // => 'content'
obj.size; // => 7

// Write object
final oid = odb.write(
  type: GitObject.blob,
  data: 'new content',
); // => Oid

// Get all objects
final objects = odb.objects; // => [Oid, Oid, ...]

// Add alternate ODB
odb.addDiskAlternate('path/to/alternate/objects');
```

---

