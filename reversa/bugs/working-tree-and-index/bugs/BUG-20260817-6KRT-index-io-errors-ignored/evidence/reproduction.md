# Reproduction capsule

- Base commit: `654fb24db34d783060f4d3cd497271a0f794d877`
- Branch: `0.5.5`
- Environment: Windows host; Flutter 3.38.2 stable; Dart 3.10.0.
- Command: `flutter test -j 1 test/index_test.dart`
- Before correction: exit code 1, because `Index.newInMemory().read()` returned normally.
- After correction: exit code 0, 56 passing tests.
- Classification: deterministic for the safe in-memory read/write failure paths.

## Failing observation before CHG-002

The test expected `LibGit2Error` from `Index.newInMemory().read()`, but the
closure returned `null`. This proves that the native failure status was
discarded before it reached the public API.

## Read-tree boundary

The valid tree path is covered by the existing `reads tree with provided SHA
hex` test. An attempted null-tree negative stimulus was removed because libgit2
did not return an error status and the test did not complete; it is not a safe
failure injector. The `readTree` repair is instead supported by the complete
local control-flow trace from its returned status to `checkErrorAndThrow`.

## Passing observation after CHG-002

The safe in-memory `read` and `write` failure paths throw `LibGit2Error`; the
focused suite passes all 56 tests, including successful disk and tree paths.
