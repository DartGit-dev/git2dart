# Static Analysis Evidence

- `lib/src/bindings/commit.dart:71-79`, `:120-128`, and `:168-176` allocate `parentCount` elements and index element zero when the list is empty.
- The high-level commit API permits an empty parent list for initial commits.
- The defect is a complete static native-memory path; no runtime probe was attempted in read-only mode.
