# Static Analysis Evidence

- `lib/src/bindings/index.dart:129-134` and `:149-154` leak `out` when libgit2 reports failure.
- `lib/src/bindings/stash.dart:33-45` and `:62-69` have the same failure ordering.
- `lib/src/bindings/diff.dart:304-309` repeats it for patch IDs.
- Existing negative tests confirm several error paths but do not observe native allocations.
