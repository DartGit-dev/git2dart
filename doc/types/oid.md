# Oid

`Oid` represents a Git object id. git2dart supports SHA-1 and SHA-256 object id
strings where libgit2 and the repository support them.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Resolving object ids

Use `Repository.operator []` or `Oid.fromSHA` to resolve a full hash or an
unambiguous prefix through the repository object database:

```dart
final oid = repo['78b8bf1'];
final sameOid = Oid.fromSHA(repo, '78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e8');

print(oid.sha);
print(oid.toStrS());
print(oid.toStrN(7));
print(oid.equalsHex('78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e8'));

oid.free();
sameOid.free();
```

Valid input must be hexadecimal and 4 to 64 characters long. Invalid format
throws `ArgumentError`; missing or ambiguous object ids throw `LibGit2Error`.

### Shortening

Use `OidShortener` to compute unique object id prefixes across a set of object
ids:

```dart
final shortener = OidShortener(minLength: 7);
final firstLength = shortener.add(repo['78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e8']);
final nextLength = shortener.addHex('78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e9');

shortener.free();
```

`OidShortener` wraps a native libgit2 shortener. It has a finalizer, but call
`free()` when you are done with it in long-running code.

### Comparison

`Oid` supports equality and ordering:

```dart
if (oldOid < newOid) {
  print('oldOid sorts before newOid');
}
```

`toString()` includes the SHA value for diagnostics.

### Native ownership

Each `Oid` owns an independent native copy, including values obtained from
repositories, references, commits, trees, and other parent objects. Releasing
the parent does not invalidate the `Oid`:

```dart
final reference = repo.head;
final target = reference.target;
reference.free();

print(target.sha);
target.free();
```

A finalizer provides a fallback, but long-running applications should call
`free()` exactly once when an `Oid` is no longer needed. Do not read or compare
the value after it has been released.

## Important Options

Use full hashes for durable storage and `OidShortener` only for display-friendly unique prefixes.

## Lifecycle and Errors

`Oid` and `OidShortener` own native allocations. Release each instance with
`free()` when it is no longer needed; do not use an instance after release.

## See Also

- [oid_test.dart](../../test/oid_test.dart)
