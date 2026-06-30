# Ignore

`Ignore` exposes repository ignore helpers for in-memory rules and path checks.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Rules

```dart
Ignore.addRule(repo: repo, rules: '*.tmp');

final ignored = Ignore.pathIsIgnored(
  repo: repo,
  path: 'generated.tmp',
);

Ignore.clearInternalRules(repo);
```

Rules added with `addRule` are not written to disk. They affect the repository
instance until `clearInternalRules` is called.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [ignore_test.dart](../../test/ignore_test.dart)
