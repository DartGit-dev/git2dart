# Static Analysis Evidence

- `lib/src/bindings/blob.dart:235-253` copies `git_buf.ptr` and returns without `git_buf_dispose`.
- The arena releases only the outer structure, not libgit2-owned internal storage.
