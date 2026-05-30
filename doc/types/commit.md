# Commit

`Commit` represents a Git commit object and exposes commit metadata, parents,
tree information, and creation helpers.

## Lookup

```dart
final commit = Commit.lookup(repo: repo, oid: repo.head.target);

commit.oid;
commit.message;
commit.summary;
commit.body;
commit.author;
commit.committer;
commit.tree;
commit.parents;
commit.headerField('encoding');
```

## Creating Commits

```dart
final oid = Commit.create(
  repo: repo,
  updateRef: 'HEAD',
  message: 'Add file\n',
  author: repo.defaultSignature,
  committer: repo.defaultSignature,
  tree: tree,
  parents: [parent],
);
```

Use `Commit.createBuffer` to build a commit buffer without writing it to the
object database. Use `Commit.createWithSignature` for signed commit content.

`Commit` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/commit_test.dart](../../test/commit_test.dart).
