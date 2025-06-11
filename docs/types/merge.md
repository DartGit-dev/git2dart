# Merge

Some API methods:

```dart
// Find a merge base between commits
final oid = Merge.base(
  repo: repo,
  commits: [commit1.oid, commit2.oid],
); // => Oid

// Merge commit into HEAD writing the results into the working directory
Merge.commit(repo: repo, commit: annotatedCommit);

// Cherry-pick the provided commit, producing changes in the index and
// working directory.
Merge.cherryPick(repo: repo, commit: commit);
```

---


For more examples see [test/merge_test.dart](../../test/merge_test.dart).
