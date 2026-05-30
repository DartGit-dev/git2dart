# Credentials

Credentials are used by remote callbacks during fetch, push, clone, and
submodule operations.

## Supported Credential Types

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

## Usage

```dart
Repository.clone(
  url: 'git@example.com:owner/repo.git',
  localPath: 'repo',
  callbacks: Callbacks(credentials: keypair),
);
```

Network-dependent credential tests are skipped unless explicitly enabled.

See [test/credentials_test.dart](../../test/credentials_test.dart).
