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
  final oid = entry.oid;
  try {
    entry.path;
    oid.sha;
    entry.filemode;
    entry.stage;
  } finally {
    oid.free();
    entry.free();
  }
}

first.free();
byPath.free();
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

### Native ownership

`Index` owns a native handle. Each returned `IndexEntry` owns an independent
copy of its native entry and path, so it remains valid if the index changes or
is released. Call `free()` on both types when deterministic cleanup is needed:

```dart
final index = repo.index;
final entry = index['lib/git2dart.dart'];
final oid = entry.oid;

try {
  print('${entry.path}: ${oid.sha}');
} finally {
  oid.free();
  entry.free();
  index.free();
}
```

Repeated `IndexEntry.free()` calls are safe. Do not read or mutate an entry
after its first release.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

`Index` and `IndexEntry` use finalizers as a fallback. In long-running code,
release them explicitly when no longer needed. libgit2 failures surface as
`LibGit2Error`.

## See Also

- [index_test.dart](../../test/index_test.dart)
