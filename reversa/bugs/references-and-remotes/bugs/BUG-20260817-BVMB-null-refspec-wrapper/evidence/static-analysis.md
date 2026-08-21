# Static Evidence

- `git_remote_get_refspec` is exposed as a nullable pointer result.
- `lib/src/bindings/remote.dart:294-297` returns the result without a null check.
- `lib/src/remote.dart:231-233` constructs `Refspec` immediately.
- `lib/src/refspec.dart` dereferences the stored pointer in every property.
