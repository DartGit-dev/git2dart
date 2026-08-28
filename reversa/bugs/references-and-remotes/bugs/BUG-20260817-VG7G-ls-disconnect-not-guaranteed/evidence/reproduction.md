# Reproduction capsule

- Base commit: `654fb24db34d783060f4d3cd497271a0f794d877`
- Branch: `0.5.5`
- Environment: Windows host; Flutter 3.38.2 stable; Dart 3.10.0.
- Command: `flutter test -j 1 test/remote_test.dart`
- Classification: static deterministic failure path; local dynamic success path.

## Root-cause proof

Before CHG-002, `Remote.ls` called `connect`, `lsRemotes`, and `disconnect`
sequentially. `lsRemotes` validates the native `git_remote_ls` result and can
throw; that exceptional exit skipped the following disconnect. CHG-002 places
only `lsRemotes` in `try/finally`, so disconnect executes on both normal and
exceptional exits after a successful connection.

## Local validation

The focused suite passed with 34 tests and 7 network-tagged tests skipped. The
new test creates a remote pointing at the temporary local repository and lists
it twice successfully; no public network endpoint is used.

## Proof boundary

No safe deterministic local advertisement failure was found for
`git_remote_ls` after connect. The failure-path cleanup result is therefore a
direct control-flow proof, not live transport evidence.
