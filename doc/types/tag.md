# Tag

`Tag` represents annotated Git tags. Lightweight tags are represented by
references.

## Lookup and Listing

```dart
final tag = Tag.lookup(repo: repo, oid: oid);
final names = Tag.list(repo);
```

## Creation

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

See [test/tag_test.dart](../../test/tag_test.dart).
