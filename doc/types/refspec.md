# Refspec

`Refspec` describes how references are mapped between a remote and a local
repository.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Reading refspecs

Get refspecs from a configured `Remote`:

```dart
final remote = Remote.lookup(repo: repo, name: 'origin');
final refspec = remote.getRefspec(0);

print(refspec.string);
print(refspec.source);
print(refspec.destination);
print(refspec.force);
print(refspec.direction);
```

`Remote.fetchRefspecs` and `Remote.pushRefspecs` return the configured refspec
strings.

### Matching and transforming references

```dart
final matchesSource = refspec.matchesSource('refs/heads/master');
final matchesDestination = refspec.matchesDestination(
  'refs/remotes/origin/master',
);

final localTracking = refspec.transform('refs/heads/master');
final remoteBranch = refspec.rTransform('refs/remotes/origin/master');
```

Invalid reference names or transformations throw `LibGit2Error`.

### Updating remote configuration

Use `Remote.addFetch` and `Remote.addPush` to add validated refspec strings to a
remote:

```dart
Remote.addFetch(
  repo: repo,
  remote: 'origin',
  refspec: '+refs/heads/*:refs/remotes/origin/*',
);
```

## Important Options

Use `GitDirection.fetch` and `GitDirection.push` to distinguish fetch and push refspecs.

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [remote_test.dart](../../test/remote_test.dart)
