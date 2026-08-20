# Static Evidence

- `lib/src/bindings/reference.dart:849` allocates `git_oid` with `calloc`.
- The pointer is returned at line 855 after a successful lookup.
- `lib/src/reference.dart:297-300` wraps the pointer in `Oid`.
- `lib/src/oid.dart` stores the pointer but has no matching free path for this allocation.
