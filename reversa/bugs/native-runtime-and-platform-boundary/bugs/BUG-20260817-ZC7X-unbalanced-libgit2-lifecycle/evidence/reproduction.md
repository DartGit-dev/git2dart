# Reproduction Capsule

- Bug: `BUG-20260817-ZC7X`
- Commit: `0933dbf4af4e3fcf5cab067f757a365c24ad510a`
- Branch: `0.5.5`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0, libgit2 1.9.6
- Command: `flutter test -j 1 reversa/bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-ZC7X-unbalanced-libgit2-lifecycle/evidence/reproduction_test.dart`
- Exit code: `0`
- Attempts/failures: `1/1 defect reproduced; test itself passed because it asserts the observed growth`
- Classification: deterministic

## Observed output

```text
version1=1.9.6
version2=1.9.6
before=2
afterFirst=3
afterSecond=4
00:00 +1: All tests passed!
```

The probe adds one temporary initialization and immediately balances it with a
shutdown, so it observes the existing count without changing it. Each public
`Libgit2.version` call permanently adds one initialization in the tested
process. Two explicit shutdown calls at the end restore the count that existed
before the public calls.

The previous Flutter-lock blocker is no longer active: focused and full Flutter
commands execute successfully in the current environment.
