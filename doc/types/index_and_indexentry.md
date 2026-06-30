# Index and IndexEntry

`Index` represents the Git staging area. `IndexEntry` represents a staged file
record.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Reading

```dart
final index = repo.index;

index.length;
index.isEmpty;
index.hasConflicts;
index.conflicts;

final first = index[0];
final byPath = index['lib/git2dart.dart'];

for (final entry in index) {
  entry.path;
  entry.oid;
  entry.filemode;
  entry.stage;
}
```

### Updating

```dart
index.add('lib/git2dart.dart');
index.addAll(['lib/**']);
index.updateAll(['lib/**']);
index.remove('old.dart');
index.removeAll(['generated/**']);
index.write();
```

### Trees and Conflicts

```dart
final treeOid = index.writeTree();
index.readTree(tree);

index.addConflict(
  ancestorEntry: ancestor,
  ourEntry: ours,
  theirEntry: theirs,
);
index.cleanupConflict();
```

`Index` owns a native handle. Call `free()` when deterministic cleanup is
needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [index_test.dart](../../test/index_test.dart)
