# CommitGraph

`CommitGraph` opens file-backed Git commit graph data. `CommitGraphWriter`
creates commit graph contents from revwalks or pack index files.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Writing

```dart
final writer = CommitGraphWriter('${repo.path}/objects/info');
final walk = RevWalk(repo)..pushHead();

writer.addRevWalk(walk);
writer.commit();
```

### Opening

```dart
final graph = CommitGraph.open('${repo.path}/objects');
```

`CommitGraph` and `CommitGraphWriter` own native memory. They have finalizers,
but call `free()` in long-running code once the objects are no longer needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [commit_graph_test.dart](../../test/commit_graph_test.dart)
