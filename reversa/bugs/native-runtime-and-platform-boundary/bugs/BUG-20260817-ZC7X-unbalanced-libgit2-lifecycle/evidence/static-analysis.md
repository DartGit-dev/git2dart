# Static Evidence

- `rg` found 66 calls to `git_libgit2_init()` under `lib/`.
- No call to `git_libgit2_shutdown()` exists under `lib/` or `test/`.
- `lib/src/libgit2.dart:20-28` initializes the runtime from the `version` getter without a balancing release.
- Git blame traces the unbalanced version getter to the initial repository commit, with later arena refactoring leaving the lifecycle unchanged.
