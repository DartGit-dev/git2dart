# git2dart

[![Pub Version](https://img.shields.io/pub/v/git2dart)](https://pub.dev/packages/git2dart)
[![Pub Downloads](https://img.shields.io/pub/dm/git2dart)](https://pub.dev/packages/git2dart/score)
[![Publish](https://github.com/DartGit-dev/git2dart/actions/workflows/publish.yml/badge.svg)](https://github.com/DartGit-dev/git2dart/actions/workflows/publish.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Idiomatic Dart and Flutter bindings for
[libgit2](https://github.com/libgit2/libgit2).

git2dart provides a null-safe Dart API for working with Git repositories while
delegating Git operations to libgit2 through FFI. It is intended for Dart CLIs,
desktop Flutter apps, and mobile Flutter apps that need repository access
without shelling out to the `git` executable.

## Start Here

| Goal | Next step |
| --- | --- |
| Add git2dart to an app | [Install the package](#installation) |
| Verify the API quickly | [Run the quick start](#quick-start) or open the [complete example](example/example.dart) |
| Build a mobile Flutter app | Read [mobile initialization](#mobile-initialization), then the [Android](doc/android.md) or [iOS](doc/ios.md) guide |
| Find a specific API | Use the [documentation index](doc/README.md) |
| Contribute to the package | Read [development](#development) and [contributing](#contributing) |

## Installation

Add git2dart to your `pubspec.yaml`:

```yaml
dependencies:
  git2dart: ^0.5.2
```

Install dependencies:

```shell
flutter pub get
```

For local development against this repository, use a path dependency:

```yaml
dependencies:
  git2dart:
    path: ../git2dart
```

## Quick Start

```dart
import 'dart:io';

import 'package:git2dart/git2dart.dart';

Future<void> main() async {
  print('libgit2 ${Libgit2.version}');

  final directory = await Directory.systemTemp.createTemp('git2dart-example');
  final repo = Repository.init(path: directory.path);

  final oid = Blob.create(repo: repo, content: 'Hello from git2dart\n');
  final blob = Blob.lookup(repo: repo, oid: oid);

  print('Repository: ${repo.path}');
  print('Blob: ${blob.oid.sha}');
  print(blob.content);

  blob.free();
  repo.free();
  await directory.delete(recursive: true);
}
```

The [example application](example/example.dart) shows a longer runnable flow.

Most wrapper objects are backed by native libgit2 resources. Finalizers provide
a safety net, but long-running tools and apps should call `free()` when they are
done with repositories, objects, streams, iterators, and other native-backed
values.

## Mobile Initialization

Flutter apps on Android and iOS should initialize platform support before using
repository, remote, credential, or certificate APIs:

```dart
import 'package:flutter/widgets.dart';
import 'package:git2dart/git2dart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformSpecific.initialize();
  runApp(const MyApp());
}
```

Platform-specific setup:

- [Android setup](doc/android.md)
- [iOS setup](doc/ios.md)

Use app-private storage for repositories on mobile platforms.

## Documentation

Start with the [documentation index](doc/README.md), or jump directly to common
API areas:

- [Repository](doc/types/repository.md)
- [Git objects and Oid](doc/types/git_objects.md)
- [Working tree and index](doc/types/index_and_indexentry.md)
- [Remotes and callbacks](doc/types/remote.md)
- [Certificates](doc/types/certificate.md)
- [Shared enums and options](doc/types/git_types.md)
- [Error handling](doc/types/errors.md)

The tests in `test/` are the source of truth for additional usage scenarios and
edge cases.

## Platform Support

| Platform | Support | Notes |
| --- | --- | --- |
| Windows | Supported | 64-bit desktop. |
| Linux | Supported | 64-bit desktop. |
| macOS | Supported | 64-bit desktop. |
| Android | Supported | Flutter apps with `arm64-v8a` and `x86_64`. |
| iOS | Supported | Flutter apps through CocoaPods integration. |

Minimum SDK versions:

- Dart SDK `>=3.7.2 <4.0.0`
- Flutter `>=3.29.3`

Version `0.5.2` depends on `git2dart_binaries >=1.11.4 <1.12.0`. The companion
package provides prebuilt libgit2 artifacts and generated FFI bindings, so
normal git2dart development does not regenerate bindings in this repository.

## Features

- Repository lifecycle APIs: init, open, clone, discover, bare repositories,
  worktrees, and repository state checks.
- Git object APIs for blobs, commits, trees, tags, object databases, object IDs,
  and streaming blob writes.
- Working tree and index APIs for checkout, status, diff, patch, stash,
  ignore rules, pathspec matching, and index conflict handling.
- Reference and remote APIs for branches, tags, reflogs, remotes, fetch, prune,
  refspec matching, callbacks, credentials, and certificates.
- Higher-level Git operations including merge, rebase, reset, revert, blame,
  describe, notes, pack building, and submodules.
- Prebuilt libgit2 binaries and generated FFI bindings through
  `git2dart_binaries`.

## Native Dependencies

git2dart uses prebuilt libgit2 binaries, but some platforms still require native
TLS or runtime libraries to be present.

### Linux

```shell
sudo apt-get install libssl-dev libpcre3
```

On non-Debian distributions, the bundled native libraries may look for
Debian-style PCRE library names. If loading fails with `libpcre.so.3` or
`libpcreposix.so.3`, create distribution-appropriate compatibility symlinks.

### macOS

```shell
brew install openssl
```

### Windows

```powershell
choco install openssl -y
```

When running tests on Windows, ensure the `git2dart_binaries` directory that
contains `libgit2.dll` is on `PATH`.

## Development

Install project dependencies:

```shell
flutter pub get
```

Run the standard checks:

```shell
dart format . --set-exit-if-changed
flutter analyze
flutter test
```

If Flutter is not installed on the machine, use `scripts/install_flutter.sh`.

## Contributing

Issues and pull requests are welcome at
[DartGit-dev/git2dart](https://github.com/DartGit-dev/git2dart).

Before opening a pull request:

- Add or update documentation for public API changes.
- Add positive and negative tests for new public API behavior.
- Run `dart format . --set-exit-if-changed`, `flutter analyze`, and
  `flutter test`.
- Keep code, comments, documentation, issue titles, pull request titles,
  branch names, and commit messages in English.

## License

git2dart is released under the MIT License. See [LICENSE](LICENSE) for details.
