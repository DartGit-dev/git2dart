# Commit Walker

`RevWalk` traverses commit history.

## Walking

```dart
final walker = RevWalk(repo);

walker.sorting({GitSort.time});
walker.pushHead();

final commits = walker.walk(limit: 10);
```

## Inputs

```dart
walker.push(commit.oid);
walker.pushGlob('heads/*');
walker.pushReference('refs/heads/main');
walker.pushRange('main..feature');

walker.hide(oldCommit.oid);
walker.hideHead();
walker.reset();
```

`RevWalk` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/revwalk_test.dart](../../test/revwalk_test.dart).
