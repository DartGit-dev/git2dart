# AnnotatedCommit

`AnnotatedCommit` carries commit identity plus the reference context that led to
that commit. Merge and rebase APIs use it when reference context matters.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Creating

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

### Reading

```dart
annotated.oid;
```

`AnnotatedCommit` owns a native handle. Call `free()` when deterministic cleanup
is needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [annotated_test.dart](../../test/annotated_test.dart)
