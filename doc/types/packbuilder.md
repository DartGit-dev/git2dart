# Packbuilder

`PackBuilder` creates Git packfiles from selected objects.

## Building Packs

```dart
final packbuilder = PackBuilder(repo);

packbuilder.add(commit.oid);
packbuilder.addRecursively(tree.oid);
packbuilder.addCommit(commit.oid);
packbuilder.addTree(tree.oid);

packbuilder.write('path/to/pack');
```

## Status

```dart
packbuilder.length;
packbuilder.writtenLength;
packbuilder.name;
packbuilder.setThreads(0);
```

`PackBuilder` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/packbuilder_test.dart](../../test/packbuilder_test.dart).
