# CHG-002 Source Audit

## Audited correction

Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` changes
`lib/src/remote.dart` from sequential `lsRemotes` then `disconnect` calls to:

```dart
late final List<Map<String, Object?>> refs;
try {
  refs = remote_bindings.lsRemotes(_remotePointer);
} finally {
  remote_bindings.disconnect(_remotePointer);
}
```

## Result

`connect` remains before the protected region. Every normal or exceptional
exit after a successful connection reaches `disconnect`. The binding wrapper
at `lib/src/bindings/remote.dart` calls the native disconnect directly and
does not translate a disconnect status into a Dart exception, so a listing
exception remains the primary observable error.

## Scope

The correction is localized to `Remote.ls`; no production code was modified
in this Gate 1 completion turn.
