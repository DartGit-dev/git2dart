# Reproduction Capsule

## Baseline

- Commit: `a725bac1b8641156819c2f08a007fcc1a74f80bf`
- Branch: `0.5.4`
- OS: Microsoft Windows NT `10.0.26200.0` (`windows_x64`)
- Dart: `3.10.0` stable
- Flutter: `3.38.2`
- `git2dart_binaries`: `1.12.1`

## Isolation

The reproduction runs in a dedicated Flutter test worker. Each attempt copies
the repository fixture to a new system-temporary directory. The worker is
expected to terminate after the invalid native ownership sequence; all four
temporary fixture directories created during diagnosis were removed after the
runs.

## Command

```text
dart --packages=F:\flutter\packages\flutter_tools\.dart_tool\package_config.json \
  F:\flutter\bin\cache\flutter_tools.snapshot test \
  _reversa_bugs\git-objects-and-object-database\bugs\BUG-20260817-E3LU-tree-entry-invalid-free\evidence\reproduce_invalid_free_test.dart \
  -j 1
```

## Result

- Reproduction rate: `3/3` Flutter worker terminations.
- Exit code: `79` on every counted attempt.
- Test runner result: `did not complete`; no Dart exception was reported.
- Diagnostic run markers: `before-borrowed-free`, `after-borrowed-free`, and
  `after-parent-free` were emitted before the worker terminated during later
  repository cleanup. This is consistent with delayed native heap corruption.
- Classification: deterministic.

An earlier direct Dart-runner attempt exited `254` before executing the capsule
because Flutter's `dart:ui` is unavailable to a standalone Dart process. That
attempt is excluded from the reproduction rate.

## Causal Observation

The binding contract identifies index, name, and OID lookups as borrowed, while
path lookup returns a caller-owned entry. The high-level wrapper stores both in
the same `TreeEntry` representation without ownership state, and its public
`free()` method unconditionally invokes `git_tree_entry_free`. Freeing a
borrowed entry therefore corrupts parent-owned native storage; subsequent
parent/repository cleanup terminates the worker.
