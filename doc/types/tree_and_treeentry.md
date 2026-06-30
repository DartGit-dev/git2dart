# Tree and TreeEntry

`Tree` represents a Git directory snapshot. `TreeEntry` represents a single
entry in a tree.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Lookup

```dart
final tree = Commit.lookup(repo: repo, oid: repo.head.target).tree;
final sameTree = Tree.lookup(repo: repo, oid: tree.oid);

tree.length;
tree.entries;
tree[0];
tree['README.md'];
tree['lib/src/file.dart'];
tree.entryByOid(repo['1377554ebea6f98a2c748183bc5a96852af12ac2']);
```

### Tree Entries

```dart
final entry = tree['README.md'];

entry.name;
entry.oid;
entry.filemode;
entry.filemodeRaw;
entry.type;
```

Use `TreeBuilder` to create new trees.

```dart
final builder = TreeBuilder(repo: repo);
builder.add(filename: 'file.txt', oid: blobOid, filemode: GitFilemode.blob);
final treeOid = builder.write();
```

`Tree` and path-looked-up `TreeEntry` instances own native memory. Call `free()`
when deterministic cleanup is needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [tree_test.dart](../../test/tree_test.dart)
