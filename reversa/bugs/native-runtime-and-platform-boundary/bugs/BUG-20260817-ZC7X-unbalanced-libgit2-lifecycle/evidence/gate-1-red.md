# Gate 1 red baseline

- Approval: `APPROVE GATE 1`
- Date: 2026-08-22
- Branch: `0.5.5`
- Base commit: `0933dbf4af4e3fcf5cab067f757a365c24ad510a`
- Applied test: `test/libgit2_lifecycle_test.dart`
- Applied diff: `fix/CHG-001.diff`

## Format verification

Command:

```text
dart format --output=none --set-exit-if-changed test/libgit2_lifecycle_test.dart
```

Result: exit code 0; one file checked and zero files changed.

## Focused red run

Command:

```text
flutter test -j 1 test/libgit2_lifecycle_test.dart
```

Result: exit code 1; zero tests executed because compilation stopped at the
missing correction contract.

Expected compile failures:

- `lib/src/bindings/runtime.dart` does not exist.
- `Libgit2Runtime` is not defined.
- `Libgit2.shutdown()` is not defined.

Classification: **RED (expected)**. The failures demonstrate that the approved
lifecycle tests require the Gate 2 runtime implementation and public shutdown
API. No production source file was changed by Gate 1.

## Working-tree disposition

The active RED test was removed before the git2dart commit because the missing
native lifecycle contract belongs in `git2dart_binaries`. Keeping the test in
`test/` would make git2dart CI fail before the dependency exposes that API. The
approved test patch remains preserved as `fix/CHG-001.diff` and must be adapted
after the companion Reversa feature completes its gated implementation.
