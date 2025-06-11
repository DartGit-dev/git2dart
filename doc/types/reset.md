# Reset

Some API methods for reset operations:

```dart
// Reset repository to specific commit with different reset types
// Hard reset - updates index and working directory
repo.reset(oid: repo['821ed6e'], resetType: GitReset.hard);

// Soft reset - only moves HEAD
repo.reset(oid: repo['821ed6e'], resetType: GitReset.soft);

// Mixed reset - updates index but not working directory
repo.reset(oid: repo['821ed6e'], resetType: GitReset.mixed);

// Reset specific paths in index to match commit
repo.resetDefault(oid: repo.head.target, pathspec: ['file.txt']);
```

---


For more examples see [test/reset_test.dart](../../test/reset_test.dart).
