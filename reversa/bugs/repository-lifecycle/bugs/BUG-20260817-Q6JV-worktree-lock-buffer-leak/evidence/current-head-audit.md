# Current-head worktree lock-buffer audit

## Scope

- Date: 2026-08-27
- Checked head: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca`
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` (`fix: harden native binding cleanup`)
- Environment: local Windows Flutter test environment; no network access.

## Current implementation

`lib/src/bindings/worktree.dart:isLocked` allocates its `git_buf` through the call arena, queries `git_worktree_is_locked`, and unconditionally passes the buffer to `git_buf_dispose` in `finally`. This releases libgit2-owned reason storage after normal returns and thrown native interop failures. The current source is the same corrective body introduced by `e2d8bb4`, which is contained by both local `HEAD` and `origin/0.5.5`.

## Validation

| Command | Result | What it proves |
| --- | --- | --- |
| `flutter test -j 1 test/worktree_test.dart` | exit 0; 16 tests passed | The local worktree lock test covers unlocked, locked, and unlocked-again queries without behavior regression. |
| `flutter analyze lib/src/bindings/worktree.dart lib/src/worktree.dart test/worktree_test.dart` | exit 0; no issues | Focused static quality. |
| `git diff --check e2d8bb4^ e2d8bb4 -- lib/src/bindings/worktree.dart` | exit 0 | Historical corrective diff is structurally clean. |
| `git merge-base --is-ancestor e2d8bb4 HEAD` and `... origin/0.5.5` | exit 0 for both | The correction is present locally and in the tracked branch. |

No allocator-growth instrumentation is exposed by the local harness. The deterministic ownership proof is the explicit `finally` disposal that encloses the native query, paired with the state-transition regression. No source or test edit is warranted.

## Verdict and delivery

The effective architecture decision requires native output buffers to be disposed, so the verdict is `spec-correta`. The correction is fixed in the tracked branch, but package publication remains required by closure policy. The record stays `active/delivering` and no `DONE.md` is created.
