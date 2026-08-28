# Reproduction capsule

- Base commit: `654fb24db34d783060f4d3cd497271a0f794d877`
- Branch: `0.5.5`
- Environment: Windows host; Flutter 3.38.2 stable; Dart 3.10.0.
- Command: `flutter test -j 1 test/reflog_test.dart`
- Before correction: exit code 1; the focused out-of-range test did not complete.
- After correction: exit code 0, 19 passing tests.
- Classification: deterministic; 1/1 non-completing attempt before correction.

## Failing observation before CHG-002

The suite passed the empty, first, and last entry cases, then reached the
out-of-range lookup test and did not complete. The runner reported the current
and remaining tests as `did not complete`, consistent with a null native entry
being dereferenced after the index operator constructed its wrapper.

## Passing observation after CHG-002

The same test passes after the binding rejects a null native result. Both
`reflog[-1]` and `reflog[reflog.length]` throw `Git2DartError` immediately.
