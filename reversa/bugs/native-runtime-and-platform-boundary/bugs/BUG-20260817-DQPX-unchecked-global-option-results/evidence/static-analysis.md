# Static Evidence

- `lib/src/libgit2.dart:95-568` contains global option calls whose return values are normally discarded.
- `lib/src/libgit2.dart:462-475` demonstrates the expected checked pattern for pack maximum object size.
- `test/libgit2_test.dart` covers successful option round trips and one local range rejection, but no native negative result.
