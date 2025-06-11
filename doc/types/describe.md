# Describe

Generate human-readable name for any commit:

```dart
// Describe current working tree state
repo.describe(); // => 'v0.2-10-g821ed6e'

// Describe specific commit
repo.describe(
  commit: Commit.lookup(repo: repo, oid: repo['821ed6e']),
); // => 'v0.1-1-g821ed6e'

// Describe with options
repo.describe(
  describeStrategy: GitDescribeStrategy.tags, // only consider tags
  abbreviatedSize: 7, // length of abbreviated commit id
  alwaysUseLongFormat: true,
  dirtySuffix: '-dirty',
); // => 'v0.1-1-g821ed6e-dirty'
```

---


For more examples see [test/describe_test.dart](../../test/describe_test.dart).
