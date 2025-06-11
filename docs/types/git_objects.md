# Git Objects

There are four kinds of base object types in Git: **commits**, **trees**, **tags**, and **blobs**. git2dart have a corresponding class for each of these object types.

Lookups of these objects requires Oid object, which can be instantiated from provided SHA-1 string in two ways:

```dart
// Using alias on repository object with SHA-1 string that can be any length
// between 4 and 40 characters
final oid = repo['821ed6e'];

// Using named constructor from Oid class (rules for SHA-1 string length is
// the same)
final oid = Oid.fromSHA(repo, '821ed6e');
```

