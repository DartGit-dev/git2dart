# Reproduction Capsule

## Baseline

- Commit: `8956617db7b9e3aa8d758f0df6ca55521a445f4a`
- Branch: `0.5.5`
- OS: Microsoft Windows NT 10.0.26200.0
- Dart: 3.10.0 stable, windows_x64
- Flutter: 3.38.2 stable
- FFI package: 2.1.4

## Structural Reproduction

The reproduction checks whether `listPerfdata` returns a
`Pointer<git_diff_perfdata>` allocated by the same `Arena` that is released when
the surrounding `using` callback completes.

```powershell
$source = Get-Content -Raw 'lib/src/bindings/status.dart'
$pattern = '(?s)Pointer<git_diff_perfdata>\s+listPerfdata.*?using\(\(arena\).*?arena<git_diff_perfdata>\(\).*?return out;.*?\}\);'
[regex]::IsMatch($source, $pattern)
```

- Exit code: 0
- Result: `True`
- Rate: 1/1
- Classification: deterministic

The installed FFI implementation closes the causal lifetime path. Its
top-level `using` function returns the callback result and then calls
`arena.releaseAll()` from `finally`. Therefore the pointer returned at
`lib/src/bindings/status.dart:139` has already been released when control
reaches the caller.

## Baseline Test

```powershell
flutter test -j 1 test\repository_test.dart
```

- Exit code: 0
- Result: 44 tests passed
- Observation: the existing suite does not call `listPerfdata` and therefore
  does not detect the ownership violation.

## Regression Provenance

- Good commit: `f87ce8db749ddf5f83eb2d0f3d0654c5993f01bf`
- Culprit commit: `ca9e4a6810793028d245bc9a404f4d970e5ac8cd`
- Evidence: the culprit adds the complete `listPerfdata` function; the parent
  commit contains no `listPerfdata` or `git_status_list_get_perfdata` symbol.

### Isolated Bisect

The bisect ran in a disposable local clone so that the active worktree and its
uncommitted Reversa records were not changed. The good endpoint was
`f87ce8db749ddf5f83eb2d0f3d0654c5993f01bf`, and the bad endpoint was the
current `0.5.5` head. The predicate classified a revision as bad when
`listPerfdata` returned `Pointer<git_diff_perfdata>`.

- Steps: 6
- Exit code: 0
- First bad commit: `ca9e4a6810793028d245bc9a404f4d970e5ac8cd`
- Subject: `Add helper bindings`
- Result: confirms the commit found by `git log -S` and parent comparison

## Proof Boundary

This reproduction confirms the invalid lifetime from source and the installed
allocator contract. It does not claim an observed crash or sanitizer finding.
The correction tests must exercise the result after allocator churn and must
assert that no native pointer escapes the binding.
