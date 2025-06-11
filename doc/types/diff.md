# Diff

There is multiple ways to get the diff:

```dart
// Diff between index (staging area) and current working directory
final diff = Diff.indexToWorkdir(repo: repo, index: repo.index); // => Diff

// Diff between tree and index (staging area)
final diff = Diff.treeToIndex(repo: repo, tree: tree, index: repo.index); // => Diff

// Diff between tree and current working directory
final diff = Diff.treeToWorkdir(repo: repo, tree: tree); // => Diff

// Diff between tree and current working directory with index
final diff = Diff.treeToWorkdirWithIndex(repo: repo, tree: tree); // => Diff

// Diff between two tree objects
final diff = Diff.treeToTree(repo: repo, oldTree: tree1, newTree: tree2); // => Diff

// Diff between two index objects
final diff = Diff.indexToIndex(repo: repo, oldIndex: repo.index, newIndex: index); // => Diff

// Read the contents of a git patch file
final diff = Diff.parse(patch.text); // => Diff
```

Some methods for inspecting Diff object:

```dart
// Get the number of diff records
diff.length; // => 3

// Get the patch
diff.patch; // => 'diff --git a/modified_file b/modified_file ...'

// Get the DiffStats object of the diff
final stats = diff.stats; // => DiffStats
stats.insertions; // => 69
stats.deletions; // => 420
stats.filesChanged; // => 1

// Get the list of DiffDelta's containing file pairs with and old and new revisions
final deltas = diff.deltas; // => [DiffDelta, DiffDelta, ...]
final delta = deltas.first; // => DiffDelta
delta.status; // => GitDelta.modified
delta.oldFile; // => DiffFile
delta.newFile; // => DiffFile
```

---


For more examples see [test/diff_test.dart](../../test/diff_test.dart).
