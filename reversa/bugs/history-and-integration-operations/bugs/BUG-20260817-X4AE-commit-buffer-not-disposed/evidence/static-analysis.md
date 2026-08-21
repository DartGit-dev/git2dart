# Static Analysis Evidence

- `lib/src/bindings/commit.dart:117-144` allocates a `git_buf`, invokes `git_commit_create_buffer`, copies `ptr`, and returns without `git_buf_dispose`.
- `lib/src/bindings/commit.dart:233-253` repeats the pattern for both signature and signed-data buffers.
- Arena cleanup does not release storage allocated internally by libgit2.
