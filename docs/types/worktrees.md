# Worktrees

```dart
// Get list of names of linked worktrees
repo.worktrees; // => ['worktree1', 'worktree2'];

// Lookup existing worktree
Worktree.lookup(repo: repo, name: 'worktree1'); // => Worktree

// Create new worktree
final worktree = Worktree.create(
  repo: repo,
  name: 'worktree3',
  path: '/worktree3/path/',
); // => Worktree

// Get name of worktree
worktree.name; // => 'worktree3'

// Get path for the worktree
worktree.path; // => '/worktree3/path/';

// Lock and unlock worktree
worktree.lock();
worktree.unlock();

// Prune the worktree (remove the git data structures on disk)
worktree.prune();
```

---

