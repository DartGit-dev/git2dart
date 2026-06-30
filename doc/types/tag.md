# Tag

`Tag` represents annotated Git tags. Lightweight tags are represented by
references.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Lookup and Listing

```dart
final tag = Tag.lookup(repo: repo, oid: oid);
final names = Tag.list(repo);
```

### Creation

```dart
final tagOid = Tag.createAnnotated(
  repo: repo,
  tagName: 'v1.0.0',
  target: commit.oid,
  targetType: GitObject.commit,
  tagger: repo.defaultSignature,
  message: 'Release v1.0.0\n',
);

Tag.createLightweight(
  repo: repo,
  tagName: 'latest',
  target: commit.oid,
  targetType: GitObject.commit,
  force: true,
);
```

`Tag` owns a native handle. Call `free()` when deterministic cleanup is needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [tag_test.dart](../../test/tag_test.dart)
