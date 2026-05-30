# Worktrees

`Worktree` represents a linked Git worktree.

## Creating and Lookup

```dart
final worktree = Worktree.create(
  repo: repo,
  name: 'feature-worktree',
  path: 'path/to/worktree',
);

final existing = Worktree.lookup(repo: repo, name: 'feature-worktree');
final list = Worktree.list(repo);
```

## Operations

```dart
worktree.lock();
worktree.unlock();
worktree.validate();
worktree.prune();

final worktreeRepo = worktree.repositoryFromWorktree();
```

`Worktree` owns a native handle. Call `free()` when deterministic cleanup is
needed.

See [test/worktree_test.dart](../../test/worktree_test.dart).
