# AnnotatedCommit

Annotated commits carry additional information for merge/rebase operations:

```dart
// Create from oid
final annotated = AnnotatedCommit.lookup(repo: repo, oid: commitOid);

// Create from reference
final annotated = AnnotatedCommit.fromReference(
  repo: repo,
  reference: branchRef,
);

// Create from revision spec
final annotated = AnnotatedCommit.fromRevSpec(
  repo: repo,
  spec: '@{-1}', // previous branch
);

// Create from fetch head
final annotated = AnnotatedCommit.fromFetchHead(
  repo: repo,
  branchName: 'master',
  remoteUrl: 'https://github.com/user/repo.git',
  oid: commitOid,
);

// Access properties
annotated.oid; // => Oid
annotated.refName; // => 'refs/heads/master'
```

---

## Contributing

Fork git2dart, improve git2dart, send a pull request.

---

## Development

