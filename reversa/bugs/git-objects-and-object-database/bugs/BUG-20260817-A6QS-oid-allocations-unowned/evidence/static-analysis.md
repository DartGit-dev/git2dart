# Static Analysis Evidence

- `lib/src/bindings/oid.dart` uses `calloc<git_oid>` in parsing, raw-copy, and copy helpers.
- Blob, commit, tree, tag, merge, index, stash, reference, and ODB producers also return allocated OIDs.
- `lib/src/oid.dart:115-190` stores the pointer but defines neither a finalizer nor a release method.
- Borrowed getters also use the same constructor, so adding unconditional cleanup without ownership separation would create invalid frees.
