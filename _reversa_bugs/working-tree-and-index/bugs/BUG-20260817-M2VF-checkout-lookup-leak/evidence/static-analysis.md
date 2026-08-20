# Static Analysis Evidence

- `lib/src/checkout.dart:112` creates an owning `Reference` and never calls `free`.
- `lib/src/checkout.dart:113-127` frees `treeish` only after `bindings.tree` returns successfully.
- `lib/src/checkout.dart:157-171` repeats the unguarded treeish cleanup in commit checkout.
- Existing negative checkout tests prove the fallible path is reachable but do not instrument native ownership.
