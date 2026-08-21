# Static Evidence

- Unchecked initializer calls occur in checkout, status, reset, blob, submodule, stash, repository, remote, describe, diff, merge, worktree, commit, and blame bindings.
- Checked initializer patterns already exist in `lib/src/bindings/patch.dart`, `rebase.dart`, and selected `diff.dart` paths.
- An initializer failure does not branch away before the affected structure is used.
