# Current-head worktree list ownership audit

## Scope

- Date: 2026-08-27
- Checked head: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca`
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` (`fix: harden native binding cleanup`)
- Environment: local Windows Flutter test environment; no network access.

## Current implementation

`bindings.list` returns owning `git_worktree` pointers. `Worktree.list` copies the names in a `try` block and releases every returned pointer in its `finally` loop. Cleanup therefore runs after a successful list and if a name conversion throws. The same ownership boundary is preserved: wrappers returned by explicit lookup/create are still owned by their `Worktree` instances.

`git blame` attributes the cleanup block to `e2d8bb4`; its historical diff shows the direct replacement of the leaking projection. The commit is contained by both local `HEAD` and `origin/0.5.5`.

## Validation

| Command | Result | What it proves |
| --- | --- | --- |
| `flutter test -j 1 test/worktree_test.dart` | exit 0; 16 tests passed | Worktree listing remains correct across empty/populated, create, lookup, prune, and native list-error flows. |
| `flutter analyze lib/src/bindings/worktree.dart lib/src/worktree.dart test/worktree_test.dart` | exit 0; no issues | Focused static quality. |
| `git diff --check e2d8bb4^ e2d8bb4 -- lib/src/worktree.dart` | exit 0 | Historical corrective diff is structurally clean. |
| `git merge-base --is-ancestor e2d8bb4 HEAD` and `... origin/0.5.5` | exit 0 for both | The correction is present locally and in the tracked branch. |

No allocation-growth instrumentation is available in the local test harness. The deterministic ownership proof is the explicit `finally` release loop over every binding-returned handle, backed by the focused behavior suite. No source or test edit is warranted.

## Verdict and delivery

The effective specification requires explicit native-resource release, so the verdict is `spec-correta`. The correction is fixed in the tracked branch, but the registry has `package` closure policy. Publication remains outstanding; the record stays `active/delivering` and no `DONE.md` is created.
