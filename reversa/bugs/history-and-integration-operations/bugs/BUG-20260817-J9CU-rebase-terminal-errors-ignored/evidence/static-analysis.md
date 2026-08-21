# Static Analysis Evidence

- `lib/src/bindings/rebase.dart:149-155` discards the results of `git_rebase_finish` and `git_rebase_abort`.
- `lib/src/rebase.dart:169-176` documents that these methods throw, but the adapters cannot throw native failures.
- `test/rebase_test.dart` covers successful terminal operations but no native-error terminal path.
