# Reproduction Capsule

- Base commit: `9683aa78b8eba77da50965d3a635005b6030d431`
- Branch: `0.5.5`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0
- Command: `flutter test -j 1 reversa/bugs/references-and-remotes/bugs/BUG-20260817-3FWN-fetch-native-allocation-leak/evidence/reproduction-test.dart`
- Exit code: `0`
- Rate: `3/3` probes observed three unmanaged allocations in `fetch`
- Classification: `deterministic`

The reproduction test characterizes the current implementation. The `fetch`
path executes inside an arena but allocates its `git_strarray`, pointer array,
and `git_fetch_options` with the global allocator and supplies no explicit
release on either success or error unwind.
