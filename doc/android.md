# Android Platform Setup

git2dart supports Android API 21+ on the architectures provided by
`git2dart_binaries`.

## Requirements

- Android API 21 or newer
- Flutter app initialization before using git2dart
- App-private storage for repositories

## Initialization

Call `PlatformSpecific.initialize()` before any repository, remote, or
credential operation. If you want an Android-only call, use
`PlatformSpecific.androidInitialize()`.

```dart
import 'package:flutter/material.dart';
import 'package:git2dart/git2dart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformSpecific.initialize();

  runApp(const MyApp());
}
```

Android does not expose system CA certificates through the same filesystem
paths as desktop platforms. git2dart extracts bundled trusted root certificates
to the app cache directory during initialization.

## Storage

Use app-private directories for repositories. This avoids Android scoped storage
and permission issues.

```dart
import 'package:git2dart/git2dart.dart';
import 'package:path_provider/path_provider.dart';

Future<Repository> cloneRepo() async {
  final appDir = await getApplicationDocumentsDirectory();
  final repoPath = '${appDir.path}/my-repo';

  return Repository.clone(
    url: 'https://github.com/user/repo.git',
    localPath: repoPath,
  );
}
```

## Authentication

Pass a concrete `Credentials` object through `Callbacks`.

```dart
final repo = Repository.clone(
  url: 'https://github.com/user/private-repo.git',
  localPath: repoPath,
  callbacks: const Callbacks(
    credentials: UserPass(
      username: 'user',
      password: 'personal-access-token',
    ),
  ),
);
```

For SSH remotes, use `Keypair`, `KeypairFromMemory`, or `KeypairFromAgent`
depending on where the key material is stored.

## Troubleshooting

### SSL Errors

If you see SSL errors such as `SSL error: unknown` or `no TLS stream available`:

- Ensure `WidgetsFlutterBinding.ensureInitialized()` runs first.
- Ensure `await PlatformSpecific.initialize()` runs before git2dart APIs.
- Ensure repository operations use app-private storage.

### Permission Errors

Prefer `getApplicationDocumentsDirectory()` or another app-private location.
Avoid shared external storage unless the app explicitly manages Android storage
permissions.

## See Also

- [Main documentation](README.md)
- [Repository](types/repository.md)
- [Remote](types/remote.md)
- [Credentials](types/credentials.md)
