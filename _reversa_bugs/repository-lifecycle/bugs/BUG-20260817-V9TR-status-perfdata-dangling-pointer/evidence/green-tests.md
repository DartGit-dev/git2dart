# Gate 2 Green Test Evidence

## Formatting

The Flutter wrapper invocation of `dart format` stalled without output and was
terminated. The SDK executable was then invoked directly:

```powershell
F:\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\src\bindings\status.dart test\repository_test.dart
```

- Exit code: 0
- Result: 2 files formatted

## Focused Regression Tests

```powershell
flutter test -j 1 test\repository_test.dart --plain-name "status performance"
```

- Exit code: 0
- Result: 2 tests passed

## Repository Suite

```powershell
flutter test -j 1 test\repository_test.dart
```

- Exit code: 0
- Result: 46 tests passed

## Static Analysis

```powershell
flutter analyze
```

- Exit code: 0
- Result: no issues found

## Full Suite

```powershell
flutter test -j 1
```

- Exit code: 0
- Result: 931 passed, 24 skipped, all tests passed

## Result

The binding initializes `git_diff_perfdata.version`, copies both counters into
`StatusPerfData`, and returns no Arena-owned pointer. Gate 2 is green.
