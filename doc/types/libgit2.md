# Libgit2

`Libgit2` exposes global libgit2 version information and process-wide options.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Version and features

```dart
print(Libgit2.version);
print(Libgit2.prerelease);
print(Libgit2.features);
print(Libgit2.featureBackend(GitFeature.https));
```

Accessing most git2dart APIs initializes libgit2 automatically. Reading
`Libgit2.version` also initializes the library and returns the bundled libgit2
version.

`features` reports compile-time support such as `GitFeature.threads`,
`GitFeature.https`, `GitFeature.ssh`, and `GitFeature.nsec`.
`featureBackend` returns backend details for a supported feature, when libgit2
provides that information.

### Object and path helpers

```dart
final loose = Libgit2.objectTypeIsLoose(GitObject.blob);
final protected = Libgit2.isGitFile(
  path: '.gitignore',
  gitfile: GitPathGitFile.gitignore,
  filesystem: GitPathFilesystem.generic,
);
```

Use `isGitFile` to check names protected by libgit2 on a specific filesystem
mode, such as `.gitignore`, `.gitmodules`, or `.gitattributes`.

### Global options

`Libgit2` options affect global libgit2 behavior in the current process:

```dart
final oldUserAgent = Libgit2.userAgent;
Libgit2.userAgent = 'my-app/1.0';

final cache = Libgit2.cachedMemory;
Libgit2.setCacheMaxSize(128 * 1024 * 1024);

Libgit2.ownerValidation = false;
Libgit2.userAgent = oldUserAgent;
```

Common option groups:

- mmap limits: `mmapWindowSize`, `mmapWindowMappedLimit`,
  `mmapWindowFileLimit`
- cache limits: `setCacheObjectLimit`, `setCacheMaxSize`, `cachedMemory`,
  `enableCaching`, `disableCaching`
- config paths: `getConfigSearchPath`, `setConfigSearchPath`
- TLS and HTTP: `setSSLCertLocations`, `userAgent`,
  `enableHttpExpectContinue`, `disableHttpExpectContinue`
- repository safety: strict object creation, strict symbolic ref creation,
  strict hash verification, unsaved index safety, owner validation
- pack behavior: offset deltas, fsync gitdir, pack object limits, pack keep
  file checks
- repository extensions: `extensions`

### Errors and lifecycle

`setSSLCertLocations` throws `ArgumentError` when both `file` and `path` are
`null`. libgit2 option failures throw `LibGit2Error`.

These options are process-wide. Change them deliberately and restore previous
values in tests or shared runtimes.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

`Libgit2` exposes process-wide state. Restore changed global options in tests and shared runtimes to avoid surprising later operations.

## See Also

- [libgit2_test.dart](../../test/libgit2_test.dart)
