# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope: every current `git_*_options_init` call in `lib/src/bindings`

## Historical red proof

The initial inspection documented unchecked native initializer results in checkout, remote, repository, merge, submodule, diff, stash, reset, commit, blob, status, worktree, describe, blame, and rebase binding paths. Immutable historical source confirms representative direct unchecked uses, including `git_checkout_options_init` and `git_merge_options_init`, followed by writes through the returned option structures. This is an environment-dependent native negative path, so no mismatched-ABI runtime harness was synthesized.

## Static completeness

Current source has 44 `git_*_options_init` call sites across 16 binding files. Context inspection confirms each call either appears directly inside `checkErrorAndThrow(...)` or stores its status and calls `checkErrorAndThrow(error)` before the initialized structure is read, mutated, or passed onward.

| Binding file | Initializer calls |
| --- | ---: |
| `blob.dart` | 1 |
| `blame.dart` | 2 |
| `checkout.dart` | 5 |
| `commit.dart` | 2 |
| `describe.dart` | 3 |
| `diff.dart` | 4 |
| `merge.dart` | 5 |
| `patch.dart` | 1 |
| `rebase.dart` | 2 |
| `remote.dart` | 4 |
| `repository.dart` | 3 |
| `reset.dart` | 2 |
| `stash.dart` | 3 |
| `status.dart` | 2 |
| `submodule.dart` | 2 |
| `worktree.dart` | 3 |
| **Total** | **44** |

The recorded correction files touched by `1914a90` are `blob.dart`, `checkout.dart`, `commit.dart`, `diff.dart`, `merge.dart`, `rebase.dart`, `remote.dart`, `repository.dart`, and `stash.dart`. The other enumerated files were already checked before that commit and remain checked at HEAD.

## Validation

| Command | Result | Proof boundary |
| --- | --- | --- |
| `flutter test -j 1 test/checkout_test.dart test/remote_test.dart test/repository_test.dart test/stash_test.dart test/rebase_test.dart test/blob_test.dart test/diff_test.dart test/commit_test.dart` | exit 0; local targeted matrix passed, with 7 network tests skipped | existing option consumers and their downstream failure paths remain green on the available Windows runtime |
| `flutter analyze lib/src/bindings/checkout.dart lib/src/bindings/remote.dart lib/src/bindings/repository.dart lib/src/bindings/merge.dart lib/src/bindings/submodule.dart lib/src/bindings/diff.dart lib/src/bindings/stash.dart lib/src/bindings/reset.dart lib/src/bindings/commit.dart lib/src/bindings/blob.dart lib/src/bindings/status.dart lib/src/bindings/worktree.dart` | exit 0; no issues | affected implementation set is statically clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/bindings` | exit 0 | recorded correction commit has no whitespace errors in bindings |

## Proof boundary and closure

No mismatched-ABI harness or five-platform native load matrix was available, so this audit cannot prove runtime initializer failure behavior on unsupported artifacts. That limitation remains in `blocking`; it does not invalidate the static proof that a negative initializer status is now translated before structure use.

The evidence supports `spec-correta`; see `spec-verdict.md`. The correction is contained by local and remote `0.5.5`, but platform-matrix and package-publication evidence remain pending, so this record is `active` / `delivering`.
