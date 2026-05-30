# iOS Platform Setup

git2dart supports iOS through the `git2dart_binaries` Flutter plugin. The
native package vendors static `xcframework` artifacts for libgit2, libssh2, and
OpenSSL, and links them through CocoaPods.

## Requirements

- Flutter app initialization before using git2dart
- CocoaPods integration enabled for the iOS app
- iOS 12.0 or newer, matching the `git2dart_binaries` podspec
- App-private storage for repositories

## Initialization

Call `PlatformSpecific.initialize()` before any repository, remote, or
credential operation. This initializes the current platform; on iOS it eagerly
loads libgit2 symbols from the linked native binary.

```dart
import 'package:flutter/material.dart';
import 'package:git2dart/git2dart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformSpecific.initialize();

  runApp(const MyApp());
}
```

If you want an iOS-only call, use `PlatformSpecific.iosInitialize()`.

## Storage

Use app-private directories for repositories.

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

## CocoaPods

Run `pod install` through Flutter tooling after adding git2dart to your app.
`git2dart_binaries` contributes the native iOS pod automatically.

```shell
flutter pub get
flutter build ios
```

## Troubleshooting

### Linker Errors

If Xcode cannot find libgit2 or related symbols:

- Run `flutter clean` and `flutter pub get`.
- Reinstall pods from the iOS app directory.
- Ensure the app target deployment version is iOS 12.0 or newer.

### Filesystem Errors

Prefer `getApplicationDocumentsDirectory()` or another app-private location.
Avoid shared locations unless the app explicitly manages iOS file access.

## See Also

- [Main documentation](README.md)
- [Repository](types/repository.md)
- [Remote](types/remote.md)
- [Credentials](types/credentials.md)
