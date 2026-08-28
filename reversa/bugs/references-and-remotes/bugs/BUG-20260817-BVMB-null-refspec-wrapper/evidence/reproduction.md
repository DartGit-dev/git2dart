# Reproduction capsule

- Base commit: `654fb24db34d783060f4d3cd497271a0f794d877`
- Branch: `0.5.5`
- Environment: Windows host; Flutter 3.38.2 stable; Dart 3.10.0.
- Command: `flutter test -j 1 test/remote_test.dart`
- Before correction: exit code 1, 1 failing test out of 33 (7 network tests skipped).
- After correction: exit code 0, 33 passing tests (7 network tests skipped).
- Classification: deterministic; 1/1 failing attempt before the correction.

## Failing observation before CHG-002

Calling `remote.getRefspec(-1)` did not throw at lookup. The test expected
`Git2DartError`, but test reporting later evaluated the returned `Refspec` and
encountered:

```text
ArgumentError: Invalid argument(s): Unknown value for git_direction: 4294967295
```

The stack reached `Refspec.direction`, proving that the invalid lookup created a
wrapper instead of failing at the FFI boundary.

## Passing observation after CHG-002

Both `remote.getRefspec(-1)` and `remote.getRefspec(remote.refspecCount)` throw
`Git2DartError` immediately. Index zero continues to return a usable refspec.
