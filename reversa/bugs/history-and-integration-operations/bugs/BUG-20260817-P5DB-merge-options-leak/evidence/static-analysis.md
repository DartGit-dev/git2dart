# Static Analysis Evidence

- `lib/src/bindings/merge.dart:484` allocates `git_merge_options` with `calloc` even though `_initMergeOptions` receives an arena.
- Callers at the merge, merge-commits, and merge-trees paths do not free the pointer.
- The leak occurs on success and error.
