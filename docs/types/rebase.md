# Rebase

Reapply commits on top of another base commit:

```dart
// Initialize rebase
final rebase = Rebase.init(
  repo: repo,
  branch: AnnotatedCommit.fromReference(repo: repo, reference: branchRef),
  onto: AnnotatedCommit.fromReference(repo: repo, reference: ontoRef),
);

// Get operations to be performed
final operations = rebase.operations; // => [RebaseOperation, ...]

// Perform rebase operations
for (final operation in operations) {
  // Apply next operation
  rebase.next();
  
  // Commit the changes
  rebase.commit(
    committer: signature,
    message: 'Rebased commit',
  );
}

// Finish rebase
rebase.finish();

// Or abort rebase
rebase.abort();

// Open existing rebase
final rebase = Rebase.open(repo);
```

---


For more examples see [test/rebase_test.dart](../../test/rebase_test.dart).
