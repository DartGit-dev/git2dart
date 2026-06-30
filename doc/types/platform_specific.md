# PlatformSpecific

`PlatformSpecific` contains platform setup helpers for Flutter targets that need
native runtime initialization before normal repository APIs are used.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Current platform initialization

```dart
await PlatformSpecific.initialize();
```

Call this once during Flutter startup before clone, fetch, push, credential, or
repository APIs.

On Android, it extracts bundled Mozilla CA certificates through
`git2dart_binaries` and configures `Libgit2.setSSLCertLocations`.

On iOS, it eagerly loads libgit2 symbols from the linked native binary.

### Platform-specific helpers

```dart
await PlatformSpecific.androidInitialize();
await PlatformSpecific.iosInitialize();
```

These helpers are no-ops when called on other platforms.

See the [Android setup guide](../android.md) and [iOS setup guide](../ios.md).

## Important Options

Use `initialize()` for app startup. Use `androidInitialize()` or `iosInitialize()` only when platform-specific control is needed.

## Lifecycle and Errors

`PlatformSpecific` does not own resources directly. Initialization failures propagate from the platform helper or libgit2 setup call.

## See Also

- [platform_specific_test.dart](../../test/platform_specific_test.dart)
