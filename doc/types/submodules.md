# Submodules

`Submodule` manages Git submodules configured in a repository.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Lookup and Listing

```dart
final submodules = Submodule.list(repo);
final submodule = Submodule.lookup(repo: repo, name: 'vendor/lib');

submodule.name;
submodule.path;
submodule.url;
submodule.branch;
submodule.status;
```

### Updating

```dart
Submodule.init(repo: repo, name: 'vendor/lib');
Submodule.update(repo: repo, name: 'vendor/lib', init: true);
submodule.sync();
submodule.reload();
```

Submodule network tests are skipped unless network access is explicitly
enabled.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [submodule_test.dart](../../test/submodule_test.dart)
