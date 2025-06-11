# Packbuilder

Build pack files:

```dart
// Create packbuilder
final packbuilder = PackBuilder(repo);

// Add objects
packbuilder.add(oid);
packbuilder.addRecursively(commitOid);
packbuilder.addCommit(commitOid);
packbuilder.addTree(treeOid);

// Add objects from revwalk
final walker = RevWalk(repo);
walker.push(repo.head.target);
packbuilder.addWalk(walker);

// Write pack file
packbuilder.write('path/to/pack');

// Pack all objects in repository
final written = repo.pack(); // => number of objects written

// Pack with options
repo.pack(
  path: 'path/to/packdir',
  threads: 4,
  packDelegate: (builder) {
    // custom logic to add objects
    builder.addCommit(someOid);
  },
);
```

---


For more examples see [test/packbuilder_test.dart](../../test/packbuilder_test.dart).
