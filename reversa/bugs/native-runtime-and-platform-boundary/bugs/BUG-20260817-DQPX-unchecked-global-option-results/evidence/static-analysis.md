# Static Evidence

- A fresh scan of `lib/src/libgit2.dart` found 42 typed global-option calls: 40 discard their integer status and two check it.
- The `packMaxObjectSize` getter and setter demonstrate the expected `checkErrorAndThrow` pattern.
- `test/libgit2_test.dart` covers successful option round trips and one local range rejection, but no native negative result.
