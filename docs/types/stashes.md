# Stashes

```dart
// Get the list of all stashed states (first being the most recent)
repo.stashes; // => [Stash, Stash, ...]

// Save local modifications to a new stash
Stash.create(repo: repo, stasher: signature, message: 'WIP'); // => Oid

// Apply stash (defaults to last saved if index is not provided)
Stash.apply(repo: repo);

// Apply only specific paths from stash
Stash.apply(repo: repo, paths: ['file.txt']);

// Drop stash (defaults to last saved if index is not provided)
Stash.drop(repo: repo);

// Pop stash (apply and drop if successful, defaults to last saved
// if index is not provided)
Stash.pop(repo: repo);
```

---

