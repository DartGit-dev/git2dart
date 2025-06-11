# References and RefLog

```dart
// Get names of all of the references that can be found in repository
final refs = repo.references; // => ['refs/heads/master', 'refs/tags/v0.1', ...]

// Lookup reference
final ref = Reference.lookup(repo: repo, name: 'refs/heads/master'); // => Reference

ref.type; // => ReferenceType.direct
ref.target; // => Oid
ref.name; // => 'refs/heads/master'

// Create reference
final ref = Reference.create(
  repo: repo,
  name: 'refs/heads/feature',
  target: repo['821ed6e'],
); // => Reference

// Update reference
ref.setTarget(repo['c68ff54']);

// Rename reference
Reference.rename(repo: repo, oldName: 'refs/heads/feature', newName: 'refs/heads/feature2');

// Delete reference
Reference.delete(repo: repo, name: 'refs/heads/feature2');

// Access the reflog
final reflog = ref.log; // => RefLog
final entry = reflog.first; // RefLogEntry

entry.message; // => 'commit (initial): init'
entry.committer; // => Signature
```

---

