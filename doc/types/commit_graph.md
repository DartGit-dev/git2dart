# CommitGraph

`CommitGraph` opens file-backed Git commit graph data. `CommitGraphWriter`
creates commit graph contents from revwalks or pack index files.

## Writing

```dart
final writer = CommitGraphWriter('${repo.path}/objects/info');
final walk = RevWalk(repo)..pushHead();

writer.addRevWalk(walk);
writer.commit();
```

## Opening

```dart
final graph = CommitGraph.open('${repo.path}/objects');
```

`CommitGraph` and `CommitGraphWriter` own native memory. They have finalizers,
but call `free()` in long-running code once the objects are no longer needed.

See [test/commit_graph_test.dart](../../test/commit_graph_test.dart).
