# Static Analysis Evidence

- `lib/src/bindings/index.dart:104` calls `git_index_read` and discards its integer result.
- `lib/src/bindings/index.dart:113` returns a fallible `git_index_read_tree` call from a `void` function without checking it.
- `lib/src/bindings/index.dart:347` does the same for `git_index_write`.
- `test/index_test.dart:261-308` covers successful read/write paths but has no negative assertions for these three adapters.

Confidence: confirmed from complete local control flow; runtime regression proof is blocked by the external Dart/Flutter lock.
