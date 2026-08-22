# Reproduction Capsule

- Bug: `BUG-20260817-A6QS`
- Baseline commit: `3b719861df20912456ef7764d101eb02997e1f82`
- Candidate commit: `aba8aa73dc94d9d11615809699616b8e9e644e84`
- Branch under review: `0.5.5`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0
- Command: `flutter test -j 1 test/oid_test.dart`
- Attempts/failures on baseline: `1/1`
- Attempts/failures on candidate: `1/0` (16 tests passed)
- Classification: deterministic

## Isolated baseline playback

The current `test/oid_test.dart` contract was applied to an isolated clone at
the baseline commit. Compilation failed because baseline `Oid` has no `free`
method. The borrowed-pointer scenario therefore also cannot express a safe
ownership boundary.

```text
test/oid_test.dart:90:24: Error: The method 'free' isn't defined for the type 'Oid'.
test/oid_test.dart:98:13: Error: The method 'free' isn't defined for the type 'Oid'.
test/oid_test.dart:103:14: Error: The method 'free' isn't defined for the type 'Oid'.
00:00 +0 -1: Some tests failed.
```

## Candidate playback

The focused suite passed on current branch commit
`0933dbf4af4e3fcf5cab067f757a365c24ad510a`, which contains candidate commit
`aba8aa7`:

```text
00:00 +16: All tests passed!
```

This capsule proves the red-to-green release contract. Static allocation
evidence closes the underlying leak path because the baseline wrapper stores
caller-owned `calloc` pointers without any finalizer or explicit release.
