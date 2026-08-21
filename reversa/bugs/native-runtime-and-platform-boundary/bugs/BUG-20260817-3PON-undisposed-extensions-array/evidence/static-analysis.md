# Static Evidence

- `lib/src/libgit2.dart:524-532` allocates and frees the outer `git_strarray` only.
- `lib/src/bindings/reference.dart`, `remote.dart`, `tag.dart`, and `worktree.dart` call `git_strarray_dispose` for comparable native output arrays.
- Git blame traces the missing disposer pattern to the initial implementation.
