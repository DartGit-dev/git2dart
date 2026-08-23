# Gate 1 RED Evidence

## Applied test change

`test/libgit2_option_error_test.dart` was applied from `fix/CHG-001.diff`.
The file was formatted with `dart format` before execution.

## Command

```powershell
$env:GIT2DART_BINARIES_PACKAGE_ROOT = 'C:/Users/Viktor/AppData/Local/Pub/Cache/hosted/pub.dev/git2dart_binaries-1.12.1'
flutter test -j 1 test/libgit2_option_error_test.dart
```

## Result

- Exit code: 1
- `reproduction: native option failures are exposed` failed because the public
  wrapper returned `null` instead of throwing `LibGit2Error`.
- `regression: every global option call checks its status` failed and reported
  exactly 40 unchecked `git_libgit2_opts_*` calls.

The result is the expected RED state for the confirmed defect. The initial
test attempt had a missing error-type import and failed to compile; that test
authoring error was corrected before this recorded RED run.
