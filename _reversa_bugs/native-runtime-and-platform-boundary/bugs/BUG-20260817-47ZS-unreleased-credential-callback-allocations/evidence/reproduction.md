# Reproduction Capsule

- Base commit: `9683aa78b8eba77da50965d3a635005b6030d431`
- Branch: `0.5.5`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0
- Command: `flutter test -j 1 _reversa_bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-47ZS-unreleased-credential-callback-allocations/evidence/reproduction-test.dart`
- Exit code: `0`
- Rate: `3/3` probes observed the registered unmanaged-allocation pattern
- Classification: `deterministic`

The reproduction test characterizes the defect as it exists before the repair:
credential callback setup allocates a native attempt payload without a matching
release, and the SSH-key credential path contains five unmanaged allocations.
No real credentials or network service were used.
