# Branches

`Branch` provides helpers for local and remote branch references.

## Listing and Lookup

```dart
final branches = Branch.list(repo: repo);
final branch = Branch.lookup(
  repo: repo,
  name: 'master',
  type: GitBranch.local,
);

branch.name;
branch.target;
branch.upstream;
branch.upstreamName;
```

## Creating and Updating

```dart
final branch = Branch.create(
  repo: repo,
  name: 'feature',
  target: commit,
);

Branch.rename(repo: repo, oldName: 'feature', newName: 'feature-renamed');
Branch.delete(repo: repo, name: 'feature-renamed');
```

`Branch` owns a reference handle. Call `free()` when deterministic cleanup is
needed.

See [test/branch_test.dart](../../test/branch_test.dart).
