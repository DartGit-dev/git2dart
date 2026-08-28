# Onboarding: Test Strict Git Validation

## Prerequisites

1. Work in `F:\git2dart` with the repository dependencies already restored.
2. On Windows, make `libgit2.dll` available on `PATH` as required by this
   repository's normal Flutter tests.
3. Do not modify `git2dart_binaries`, native dependencies, secrets, worktrees,
   or Reversa extraction artifacts while testing.

## First verification

1. Inspect `lib/src/odb.dart` and confirm the writable/hashable type decision
   accepts exactly `commit`, `tree`, `blob`, and `tag`.
2. Inspect `lib/src/reference.dart` and confirm one private validator is called
   before each planned public ref-name position, including symbolic targets.
3. Run the focused tests:

   ```powershell
   flutter test -j 1 test/odb_test.dart
   flutter test -j 1 test/reference_test.dart
   ```

4. Confirm the tests cover valid `HEAD` and `refs/...` examples; invalid syntax
   must throw `ArgumentError`, not `LibGit2Error`.
5. Confirm invalid-input tests exercise a path that would otherwise be invalid
   at the native layer, so the exception order demonstrates local rejection.

## Completion verification

```powershell
dart format --output=none --set-exit-if-changed lib/src/odb.dart lib/src/reference.dart test/odb_test.dart test/reference_test.dart
flutter analyze
flutter test -j 1 test/odb_test.dart test/reference_test.dart
```

The feature is ready for the next forward stages only when all commands succeed,
no unintended files changed, and no scope expanded to FFI/binaries/platform
setup. This onboarding does not claim live-network or cross-platform runtime
proof.
