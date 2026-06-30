# Remote

`Remote` represents a configured or anonymous remote repository.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Creating and Lookup

```dart
final origin = Remote.lookup(repo: repo, name: 'origin');
final remote = Remote.create(
  repo: repo,
  name: 'upstream',
  url: 'https://example.com/repo.git',
);

Remote.setUrl(repo: repo, remote: 'origin', url: 'https://example.com/repo.git');
```

### Inspecting

```dart
remote.name;
remote.url;
remote.pushUrl;
remote.refspecCount;
remote.fetchRefspecs;
remote.pushRefspecs;
remote.getRefspec(0);
```

### Network Operations

```dart
final refs = remote.ls();

remote.fetch();
remote.push(refspecs: ['refs/heads/main']);
remote.prune();
```

### Certificate Checks

```dart
final callbacks = Callbacks(
  certificateCheck: (certificate, host, {required valid}) {
    return host == 'github.com';
  },
);

remote.fetch(callbacks: callbacks);
```

Network-dependent tests are skipped in CI unless explicitly enabled.

## Important Options

Use `Callbacks` for credentials, certificate checks, transfer progress, and push/fetch status. Use `GitRemoteAutotag` and prune options when configuring remote behavior.

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [remote_test.dart](../../test/remote_test.dart)
