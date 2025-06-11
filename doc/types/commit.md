# Commit

Commit lookup and some of the getters of the object:

```dart
final commit = Commit.lookup(repo: repo, oid: repo['821ed6e']); // => Commit

commit.message; // => 'initial commit\n'
commit.time; // => 1635869993 (seconds since epoch)
commit.author; // => Signature
commit.tree; // => Tree
```

### Creating a commit

```dart
final oid = Commit.create(
  repo: repo,
  updateRef: 'HEAD',
  message: 'Initial commit\n',
  author: author,
  committer: committer,
  tree: tree,
  parents: [],
);
```



For more examples see [test/commit_test.dart](../../test/commit_test.dart).
