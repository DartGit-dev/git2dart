# Gate 1 Red Proof

- Gate approval: user approved `APPROVE GATE 1` on 2026-08-21.
- Baseline commit: `3b719861df20912456ef7764d101eb02997e1f82`
- Test change set: `fix/CHG-001.diff`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0
- Command: `flutter test -j 1 test/oid_test.dart test/commit_test.dart`
- Exit code: `1`
- Result: `+0 -2`, both test files failed to load.

## Essential output

```text
test/oid_test.dart:90:24: Error: The method 'free' isn't defined for the type 'Oid'.
test/oid_test.dart:98:13: Error: The method 'free' isn't defined for the type 'Oid'.
test/oid_test.dart:103:14: Error: The method 'free' isn't defined for the type 'Oid'.
test/oid_test.dart:115:11: Error: The method 'free' isn't defined for the type 'Oid'.
test/commit_test.dart:356:11: Error: The method 'free' isn't defined for the type 'Oid'.
00:00 +0 -2: Some tests failed.
```

The red result is deterministic and occurs before runtime assertions because
the baseline high-level wrapper has no owned-release contract. The isolated
copy was used so the main `0.5.5` working tree remained on its current commit.
