# Branches

`Branch` provides helpers for local and remote branch references.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Listing and Lookup

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

### Creating and Updating

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

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [branch_test.dart](../../test/branch_test.dart)
