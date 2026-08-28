# Reproduction and regression evidence

## Capsule

- Date: 2026-08-26
- Branch: current checkout (no branch mutation)
- Environment: Windows, Flutter stable, Dart 3.7.2+
- Command: `flutter test -j 1 test/index_test.dart`
- Classification: deterministic
- Rate before repair: 2/2 focused ownership tests failed

## Red proof

Before the correction, `does not mutate borrowed index entries before add` expected the source path `file` but observed `owned-entry.txt`. `replaces and disposes owned index entry storage` expected a new owned address after path replacement but observed the same borrowed address. The command exited 1 with 56 passing and 2 failing tests.

## Green proof

After CHG-002 and CHG-003, the same command exited 0 with 58 passing tests. `flutter analyze` exited 0 with `No issues found`. The full `flutter test -j 1` suite completed with `All tests passed`: 965 passing and 24 skipped.

## Proof boundary

The regression observes that each path replacement changes away from the still-live prior block, explicit disposal nulls the owned pointer, repeated disposal is safe, the borrowed index entry remains unchanged until `Index.add`, and the mutated owned copy is accepted by `Index.add`. No generated declarations, dependency versions, binaries, commits, or external delivery state were changed.
