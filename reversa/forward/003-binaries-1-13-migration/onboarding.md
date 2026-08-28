# Onboarding: Validate Companion Binaries 1.13 Migration

## Prerequisites

1. Work in `F:\git2dart`; do not regenerate declarations, publish, commit, or push.
2. On Windows, make the `libgit2.dll` directory available on `PATH`.
3. Treat 1.13.0 resolution/baseline as adopted input, not fresh comparison proof.

## First verification

1. Inspect the affected adapters: removed package-level `bindings` and `options`
   access has been replaced by the delivered runtime object's members; mmap
   size/mapped/file and pack objects use `Size`, both cached-memory outputs use
   `IntPtr`, and temporary allocations are released for success and error paths.
2. Inspect `error_helper.dart`, `bindings/commit.dart`, `bindings/diff.dart`,
   and both affected `bindings/remote_callbacks.dart` paths: no obsolete direct
   native-error construction remains.
3. Run:

   ```powershell
   flutter test -j 1 test/libgit2_test.dart test/libgit2_option_error_test.dart test/platform_specific_test.dart
   ```

4. Confirm tests reset any modified process-global option. Where a native option
   accepts it on a 64-bit target, confirm `4_294_967_296` round-trips unchanged.
   Do not infer concurrent process-global option safety from this validation.
5. Run a scoped documentation search over public Dart comments, `doc/types/`,
   `README.md`, and the API reference. Update only matches promising the
   obsolete constructor, then run `dart doc`.

## Completion verification

```powershell
dart format . --set-exit-if-changed
flutter analyze
flutter test
```

Require green Linux, macOS, Windows, Android, and iOS CI. Local success is not
release proof; do not claim an unavailable 1.12.2-to-1.13.0 comparison.
