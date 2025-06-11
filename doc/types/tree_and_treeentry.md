# Tree and TreeEntry

Tree and TreeEntry lookup and some of their getters and methods:

```dart
final tree = Tree.lookup(repo: repo, oid: repo['a8ae3dd']); // => Tree

tree.entries; // => [TreeEntry, TreeEntry, ...]
tree.length; // => 3
tree.oid; // => Oid

// You can lookup single tree entry in the tree with index
final entry = tree[0]; // => TreeEntry

// You can lookup single tree entry in the tree with path to file
final entry = tree['some/file.txt']; // => TreeEntry

// Or you can lookup single tree entry in the tree with filename
final entry = tree['file.txt']; // => TreeEntry

entry.oid; // => Oid
entry.name // => 'file.txt'
entry.filemode // => GitFilemode.blob
```

You can also write trees with TreeBuilder:

```dart
final builder = TreeBuilder(repo: repo); // => TreeBuilder
builder.add(
  filename: 'file.txt',
  oid: index['file.txt'].oid,
  filemode: GitFilemode.blob,
);
final treeOid = builder.write(); // => Oid

// Perform commit using that tree in arguments
...
```

