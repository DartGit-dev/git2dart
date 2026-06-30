# Repository

`Repository` is the entry point for opening, creating, cloning, discovering,
and inspecting Git repositories.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Opening Repositories

```dart
final repo = Repository.open('path/to/workdir-or-gitdir');
final bare = Repository.openBare('path/to/bare.git');

final initialized = Repository.init(path: 'path/to/new-repo');
final cloned = Repository.clone(
  url: 'https://example.com/repo.git',
  localPath: 'path/to/clone',
);

final gitDir = Repository.discover(startPath: 'path/to/repo/lib');
```

### Inspecting State

```dart
repo.path;
repo.commonDir;
repo.workdir;
repo.isBare;
repo.isEmpty;
repo.isHeadDetached;
repo.isBranchUnborn;
repo.isWorktree;
repo.isShallow;
repo.oidType;

final head = repo.head;
final oid = repo['821ed6e80627b8769d170a293862f9fc60825226'];
final commit = Commit.lookup(repo: repo, oid: oid);
```

### Updating HEAD

```dart
repo.setHead('refs/heads/feature');
repo.setHead(repo['821ed6e']);
repo.detachHead();
```

### Working with Repository Data

```dart
final config = repo.config;
final index = repo.index;
final status = repo.status;

final fileOid = repo.hashFile(path: '${repo.workdir}/file.txt');
final identity = repo.identity;
repo.setIdentity(name: 'A User', email: 'a@example.com');
```

Native repository handles are owned by `Repository` and released by `free()` or
the finalizer.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [repository_test.dart](../../test/repository_test.dart)
