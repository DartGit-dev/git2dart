# Static Analysis Evidence

- `lib/src/bindings/worktree.dart:144-166` documents and returns owning handles that require `free`.
- `lib/src/worktree.dart:64-67` maps each handle to a name and drops the pointer without release.
