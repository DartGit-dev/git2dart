# Gate 1 CHG-002 RED Proof

## Checkpoint

- Date: 2026-08-23
- Branch: `0.5.5`
- Commit: `b118faf9c933883cf22f6ac3451c9080c9cc467f`
- Direct Dart package override: `.dart_tool/package_config.json` resolves `git2dart_binaries` to `../../git2dart_binaries`.
- Applied files: `test/libgit2_lifecycle_source_test.dart`, `test/libgit2_lifecycle_test.dart`.
- Formatting: `dart format` reported `Formatted 2 files (0 changed)`.

## Command

```powershell
flutter test -j 1 test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart
```

Exit code: `1`.

## Expected failures

- The source reproduction contract found the removed `libgit2` / `libgit2Opts` consumer globals under production `lib/`.
- The integration contract failed compilation because public `Libgit2.shutdown()` does not exist.
- Compilation also reported production references to the removed `libgit2` / `libgit2Opts` declarations, including `lib/src/libgit2.dart`, `lib/src/config.dart`, `lib/src/diff.dart`, and binding adapters.

This is the required RED boundary. It proves the consumer migration is absent; it does not prove any production correction or native behavior is GREEN.
