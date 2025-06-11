# Commit Walker

There's two ways to traverse a set of commits. Through Repository object alias or by using RevWalk class for finer control:

```dart
// Traverse a set of commits starting at provided oid
final commits = repo.log(oid: repo['821ed6e']); // => [Commit, Commit, ...]

// Use RevWalk object to fine tune traversal
final walker = RevWalk(repo); // => RevWalk

// Set desired sorting (optional)
walker.sorting({GitSort.topological, GitSort.time});

// Push Oid for the starting point
walker.push(repo['821ed6e']);

// Hide commits if you are not interested in anything beneath them
walker.hide(repo['c68ff54']);

// Perform traversal
final commits = walker.walk(); // => [Commit, Commit, ...]
```

---

