# Static Evidence

- `lib/src/bindings/reflog.dart:132-135` forwards the nullable entry result.
- `lib/src/reflog.dart:84-87` wraps it without validation.
- Entry property access dereferences the stored pointer.
- No out-of-range operator test exists in `test/reflog_test.dart`.
