# Reproduction capsule

- Base commit: `654fb24db34d783060f4d3cd497271a0f794d877`
- Branch: `0.5.5`
- Environment: Windows host; Flutter 3.38.2 stable; Dart 3.10.0.
- Command: `flutter test -j 1 test/rebase_test.dart`
- Classification: deterministic for the repeated-finish native failure.

## Failing observation before CHG-002

After a successful rebase, a second `finish()` returned native status `-15`.
The binding discarded that value, so the public closure returned normally and
the expectation for `LibGit2Error` failed. The focused suite exited 1.

## Passing observation after CHG-002

`finish()` and `abort()` now route their returned statuses through
`checkErrorAndThrow`. The repeated `finish()` path throws `LibGit2Error`, while
the existing successful finish and conflicted-rebase abort paths remain green.
The focused suite exited 0 with 10 passing tests.

## Abort failure boundary

No safe deterministic negative abort stimulus was found on this libgit2 build.
Repeated `abort()` and temporary index/HEAD lock-file probes were idempotent,
returning success rather than a native failure. Unsafe stale-pointer injection
was intentionally not used. The abort repair is dynamically covered on its
success path and statically traced from its native status to the shared error
boundary.
