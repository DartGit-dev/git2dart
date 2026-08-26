# Reproduction capsule

- Base commit: `654fb24db34d783060f4d3cd497271a0f794d877`
- Branch: `0.5.5`
- Environment: Windows host; Flutter 3.38.2 stable; Dart 3.10.0.
- Command: `flutter test -j 1 test/blob_test.dart`
- Before correction: exit code 1, 1 failing test out of 20.
- After correction: exit code 0, 20 passing tests.
- Classification: deterministic; 1/1 failing attempt before the correction.

## Failing observation before CHG-002

The test streamed `ASCII Привет 😀 é` through `writeString`, committed the
blob, and expected the blob content to equal the source string. It failed with:

```text
Expected: 'ASCII Привет 😀 é'
  Actual: 'ASCII \x1F@825B ='
```

This demonstrates that the source string does not round-trip through the
stream before UTF-8 encoding is applied.

## Passing observation after CHG-002

The same focused test passed after `writeString` used `utf8.encode(text)`. It
also asserts `blob.contentBytes == utf8.encode(content)`.
