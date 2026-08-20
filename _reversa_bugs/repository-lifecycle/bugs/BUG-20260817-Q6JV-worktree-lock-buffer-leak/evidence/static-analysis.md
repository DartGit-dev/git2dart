# Static Analysis Evidence

- `lib/src/bindings/worktree.dart:194-198` allocates a `git_buf`, passes it to `git_worktree_is_locked`, and returns without `git_buf_dispose`.
- `test/worktree_test.dart:133-139` reaches the locked path but does not instrument allocation ownership.
