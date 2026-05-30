# AnnotatedCommit

`AnnotatedCommit` carries commit identity plus the reference context that led to
that commit. Merge and rebase APIs use it when reference context matters.

## Creating

```dart
final annotated = AnnotatedCommit.lookup(repo: repo, oid: commit.oid);
final fromRef = AnnotatedCommit.fromReference(repo: repo, reference: repo.head);
final fromRevSpec = AnnotatedCommit.fromRevSpec(repo: repo, spec: 'HEAD');
final fromFetchHead = AnnotatedCommit.fromFetchHead(
  repo: repo,
  branchName: 'main',
  remoteUrl: 'https://example.com/repo.git',
  oid: commit.oid,
);
```

## Reading

```dart
annotated.oid;
```

`AnnotatedCommit` owns a native handle. Call `free()` when deterministic cleanup
is needed.

See [test/annotated_test.dart](../../test/annotated_test.dart).
