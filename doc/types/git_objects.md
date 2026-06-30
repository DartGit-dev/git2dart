# Git Objects and Oid

Git objects are addressed by `Oid`. High-level object classes include `Commit`,
`Tree`, `TreeEntry`, `Blob`, and `Tag`.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Oid

```dart
final oid = repo['78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e8'];
final sameOid = Oid.fromSHA(repo, '78b8bf1');

oid.sha;
oid.toStr(41);
oid.toStrS();
oid.equalsHex('78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e8');
oid.compareToHex('ffffffffffffffffffffffffffffffffffffffff');
```

Use `OidShortener` to compute unique hexadecimal prefixes.

```dart
final shortener = OidShortener(minLength: 7);
final length = shortener.add(oid);
shortener.free();
```

### Lookup

```dart
final commit = Commit.lookup(repo: repo, oid: oid);
final tree = commit.tree;
final blob = Blob.lookup(repo: repo, oid: tree['README.md'].oid);
```

Objects that wrap native handles provide `free()` and finalizers.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [oid_test.dart](../../test/oid_test.dart)
