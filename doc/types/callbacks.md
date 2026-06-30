# Callbacks

`Callbacks` groups optional hooks used by clone, fetch, push, and other remote
operations.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Credentials

Pass one of the concrete `Credentials` implementations when an operation needs
authentication:

```dart
final repo = Repository.clone(
  url: 'https://github.com/user/private-repo.git',
  localPath: 'private-repo',
  callbacks: const Callbacks(
    credentials: UserPass(username: 'user', password: 'token'),
  ),
);
```

For SSH, use `Keypair`, `KeypairFromAgent`, or `KeypairFromMemory`.

### Certificate checks

Use `certificateCheck` when an operation needs a custom trust decision for the
remote certificate:

```dart
final callbacks = Callbacks(
  certificateCheck: (certificate, host, {required valid}) {
    if (valid) {
      return true;
    }

    final hostkey = certificate.hostkey;
    return host == 'github.com' && hostkey?.hasSha256 == true;
  },
);
```

Return `true` to accept the certificate or `false` to reject it. Leave the
callback unset to use libgit2's default certificate validation behavior.

### Progress and reference updates

```dart
final remote = Remote.lookup(repo: repo, name: 'origin');

remote.fetch(
  callbacks: Callbacks(
    transferProgress: (progress) {
      print('${progress.receivedObjects}/${progress.totalObjects}');
    },
    sidebandProgress: (message, length, payload) {
      print(message);
    },
    updateTips: (refname, oldOid, newOid) {
      print('$refname: ${oldOid.sha} -> ${newOid.sha}');
    },
  ),
);
```

For push status updates:

```dart
remote.push(
  refspecs: ['refs/heads/main'],
  callbacks: Callbacks(
    pushUpdateReference: (refname, message) {
      print('$refname: $message');
    },
  ),
);
```

### Notes

Every callback is optional. Use `const Callbacks()` when no hooks are needed.
Callback failures propagate through the libgit2 operation that invoked them.

## Important Options

Use `credentials`, `certificateCheck`, `transferProgress`, `sidebandProgress`, `updateTips`, and `pushUpdateReference` only for operations that need those hooks.

## Lifecycle and Errors

`Callbacks` itself does not own native resources. Callback failures surface through the clone, fetch, push, or remote operation that invoked them.

## See Also

- [callbacks_test.dart](../../test/callbacks_test.dart)
- [remote_test.dart](../../test/remote_test.dart)
- [credentials_test.dart](../../test/credentials_test.dart)
