# Remote

`Remote` represents a configured or anonymous remote repository.

## Creating and Lookup

```dart
final origin = Remote.lookup(repo: repo, name: 'origin');
final remote = Remote.create(
  repo: repo,
  name: 'upstream',
  url: 'https://example.com/repo.git',
);

Remote.setUrl(repo: repo, remote: 'origin', url: 'https://example.com/repo.git');
```

## Inspecting

```dart
remote.name;
remote.url;
remote.pushUrl;
remote.refspecCount;
remote.fetchRefspecs;
remote.pushRefspecs;
remote.getRefspec(0);
```

## Network Operations

```dart
final refs = remote.ls();

remote.fetch();
remote.push(refspecs: ['refs/heads/main']);
remote.prune();
```

Network-dependent tests are skipped in CI unless explicitly enabled.

See [test/remote_test.dart](../../test/remote_test.dart).
