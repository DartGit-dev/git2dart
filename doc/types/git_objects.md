# Git Objects and Oid

Git objects are addressed by `Oid`. High-level object classes include `Commit`,
`Tree`, `TreeEntry`, `Blob`, and `Tag`.

## Oid

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

## Lookup

```dart
final commit = Commit.lookup(repo: repo, oid: oid);
final tree = commit.tree;
final blob = Blob.lookup(repo: repo, oid: tree['README.md'].oid);
```

Objects that wrap native handles provide `free()` and finalizers.

See [test/oid_test.dart](../../test/oid_test.dart).
