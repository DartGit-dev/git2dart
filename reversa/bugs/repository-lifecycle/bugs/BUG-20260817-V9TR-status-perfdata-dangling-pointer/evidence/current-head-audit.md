# Current HEAD Audit

## Scope

Audited BUG-20260817-V9TR against the current checkout without modifying
production source, tests, specifications, Git history, or delivery state.

## Code

`lib/src/bindings/status.dart` defines `listPerfdata` with the managed
`StatusPerfData` return type. Before the native call it assigns
`GIT_DIFF_PERFDATA_VERSION`; after a successful call it copies `stat_calls`
and `oid_calculations` into immutable Dart fields before the local Arena is
released. No raw `Pointer<git_diff_perfdata>` escapes.

## Tests

`test/repository_test.dart` retains both approved checks:

1. The binding function is not typed as returning
   `Pointer<git_diff_perfdata>`.
2. The resulting counters remain readable after the helper returns.

Command:

```powershell
flutter test -j 1 test/repository_test.dart --plain-name 'status performance'
```

Result: exit code 0; 2 targeted tests passed.

## Effective specification

`reversa/sdd/addenda/bug-BUG-20260817-V9TR-v001.md` is present and matches
the code contract: native version initialization, Arena-local allocation,
managed copying, no raw pointer return, and existing error translation.

## Delivery state

The originally recorded commit `6d65b30ce2ed7e8e8a531930834195e94328a74b`
is not an ancestor of current HEAD. Equivalent correction commit
`764fbd712fb6065bcfee9e5179c57530c3eb5c16` is an ancestor of current HEAD and
is contained by local `0.5.5` and `origin/0.5.5`. No pull request, publication,
or release verification was performed or implied.
