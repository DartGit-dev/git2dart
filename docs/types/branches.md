# Branches

```dart
// Get all the branches that can be found in repository
final branches = repo.branches; // => [Branch, Branch, ...]

// Get only local/remote branches
final local = repo.branchesLocal; // => [Branch, Branch, ...]
final remote = repo.branchesRemote; // => [Branch, Branch, ...]

// Lookup branch (lookups in local branches if no value for argument `type`
// is provided)
final branch = Branch.lookup(repo: repo, name: 'master'); // => Branch

branch.target; // => Oid
branch.isHead; // => true
branch.name; // => 'master'

// Create branch
Branch.create(repo: repo, name: 'feature', target: commit); // => Branch

// Rename branch
Branch.rename(repo: repo, oldName: 'feature', newName: 'feature2');

// Delete branch
Branch.delete(repo: repo, name: 'feature2');
```

---

