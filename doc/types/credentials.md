# Credentials

Credentials are used by remote callbacks during fetch, push, clone, and
submodule operations.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Supported Credential Types

```dart
final userPass = UserPass(
  username: 'user',
  password: 'password',
);

final keypair = Keypair(
  username: 'git',
  pubKey: 'path/to/id_rsa.pub',
  privateKey: 'path/to/id_rsa',
  passPhrase: 'optional',
);

final keypairFromMemory = KeypairFromMemory(
  username: 'git',
  pubKey: publicKey,
  privateKey: privateKey,
  passPhrase: 'optional',
);
```

### Usage

```dart
Repository.clone(
  url: 'git@example.com:owner/repo.git',
  localPath: 'repo',
  callbacks: Callbacks(credentials: keypair),
);
```

Network-dependent credential tests are skipped unless explicitly enabled.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Credential objects are Dart value objects. Authentication failures from libgit2 surface as `LibGit2Error` from the operation using the credentials.

## See Also

- [credentials_test.dart](../../test/credentials_test.dart)
