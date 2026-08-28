# Current-head identity error audit

## Scope

- Date: 2026-08-27
- Checked head: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca`
- Historical correction: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Environment: local Windows Flutter test environment; no network access.

## Current implementation

`lib/src/bindings/repository.dart` allocates the `name` and `email` output-pointer slots, invokes `git_repository_ident`, translates the returned status through `checkErrorAndThrow(error)`, and only then reads non-null outputs. Its `finally` block frees both allocation slots on success and on the translated-error path.

The historical diff for `1914a905` shows that this ordering and cleanup replaced the unchecked native call. `git blame` attributes the changed body to that commit. The commit is contained by both local `HEAD` and `origin/0.5.5`.

## Validation

| Command | Result | What it proves |
| --- | --- | --- |
| `flutter test -j 1 test/repository_empty_test.dart` | exit 0; 18 tests passed | Configured identity is returned and an unset identity has the documented empty public representation. |
| `flutter analyze lib/src/bindings/repository.dart lib/src/repository.dart test/repository_empty_test.dart` | exit 0; no issues | Focused static quality. |
| `git diff --check 1914a905^ 1914a905 -- lib/src/bindings/repository.dart` | exit 0 | Historical corrective diff is structurally clean. |
| `git merge-base --is-ancestor 1914a905 HEAD` and `... origin/0.5.5` | exit 0 for both | The correction is present locally and in the tracked branch. |

No supported public seam safely forces `git_repository_ident` itself to fail: an artificial invalid native repository pointer would be undefined behavior, and no binding injection seam exists. The direct source-order audit is therefore the deterministic error-path proof; no test or source edit is warranted.

## Verdict and delivery

The existing specification requires native failures to be translated, so the verdict is `spec-correta`. The correction is fixed in the tracked branch, but the registry uses the `package` closure policy. Publication of the containing package version remains outstanding; status therefore remains `active/delivering` and no `DONE.md` is created.
