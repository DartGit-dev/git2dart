# Static Analysis Evidence

- `lib/src/writestream.dart:42-44` claims UTF-8 but passes `text.codeUnits` to `Uint8List.fromList`.
- Dart `codeUnits` are UTF-16 code units; `Uint8List` retains only the low eight bits.
- `test/blob_test.dart:165-173` covers only ASCII stream content.
