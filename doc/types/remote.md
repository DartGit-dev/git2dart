# Remote

Some API methods for remote management:

```dart
// Get list of all remotes
Remote.list(repo); // => ['origin', 'upstream', ...]

// Lookup remote
final remote = Remote.lookup(repo: repo, name: 'origin'); // => Remote
remote.name; // => 'origin'
remote.url; // => 'https://github.com/user/repo.git'

// Create remote
final remote = Remote.create(
  repo: repo,
  name: 'upstream',
  url: 'https://github.com/upstream/repo.git',
); // => Remote

// Delete remote
Remote.delete(repo: repo, name: 'upstream');

// Rename remote
Remote.rename(repo: repo, oldName: 'origin', newName: 'github');

// Fetch from remote
final remote = Remote.lookup(repo: repo, name: 'origin');
final stats = remote.fetch(
  callbacks: Callbacks(transferProgress: (stats) {
    print('Progress: ${stats.receivedObjects}/${stats.totalObjects}');
  }),
); // => TransferProgress

// Get remote references
final refs = remote.ls(); // => [RemoteReference, RemoteReference, ...]
```

---


For more examples see [test/remote_test.dart](../../test/remote_test.dart).
