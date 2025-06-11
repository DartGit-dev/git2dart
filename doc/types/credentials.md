# Credentials

Handle authentication for remote operations:

```dart
// Username/password credentials
const credentials = UserPass(
  username: 'user',
  password: 'password',
);

// SSH key from files
const credentials = Keypair(
  username: 'git',
  pubKey: 'path/to/id_rsa.pub',
  privateKey: 'path/to/id_rsa',
  passPhrase: 'key passphrase',
);

// SSH key from memory
final credentials = KeypairFromMemory(
  username: 'git',
  pubKey: publicKeyContent,
  privateKey: privateKeyContent,
  passPhrase: 'key passphrase',
);

// SSH key from agent
const credentials = KeypairFromAgent('git');

// Use credentials with clone/fetch/push
final repo = Repository.clone(
  url: 'ssh://git@github.com/user/repo.git',
  localPath: 'path/to/clone',
  callbacks: Callbacks(credentials: credentials),
);
```

---


For more examples see [test/credentials_test.dart](../../test/credentials_test.dart).
