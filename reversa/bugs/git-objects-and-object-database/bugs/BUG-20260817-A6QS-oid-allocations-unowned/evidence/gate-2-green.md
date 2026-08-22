# Gate 2 Green Proof

- Gate approval: user approved `APPROVE GATE 2` on 2026-08-21.
- Accepted source candidate: `aba8aa73dc94d9d11615809699616b8e9e644e84`
- Current branch: `0.5.5`
- Environment: Windows x64, Flutter 3.38.2, Dart 3.10.0

## Focused tests

Command:

```text
flutter test -j 1 test/oid_test.dart test/commit_test.dart
```

Result:

```text
00:02 +52: All tests passed!
```

## Scoped static analysis

Command:

```text
flutter analyze lib test
```

Result:

```text
Analyzing 2 items...
No issues found!
```

## Full regression suite

Command:

```text
flutter test -j 1
```

Result:

```text
00:46 +944 ~24: All tests passed!
```

## Full analyzer proof boundary

`flutter analyze` exits with four errors in the pre-existing E3LU reproduction
artifacts because their relative imports do not resolve
`test/helpers/util.dart`. No error is reported in `lib/` or `test/`, and the
issue is outside the approved A6QS change set. A6QS therefore has green source,
test, focused, and full-suite proof, while repository-wide analyzer closure
remains blocked by that unrelated diagnostic-artifact defect.
