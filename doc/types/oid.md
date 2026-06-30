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

## Important Options

Use full hashes for durable storage and `OidShortener` only for display-friendly unique prefixes.

## Lifecycle and Errors

`Oid` values are lightweight object identifiers. `OidShortener` owns a native shortener and should be released with `free()` when no longer needed.

## See Also

- [oid_test.dart](../../test/oid_test.dart)
