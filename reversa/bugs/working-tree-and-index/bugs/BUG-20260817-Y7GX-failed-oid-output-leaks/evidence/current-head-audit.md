# Current-head OID failure-ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Validation: local repository-only index, stash, and diff scenarios

## Current implementation

The five recorded adapters preallocate output OID storage, return it only on
successful native completion, and free it in `catch` before rethrowing a
translated error. This preserves one owner for every successful high-level OID
and no owner on a failed operation.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/index_test.dart test/stash_test.dart test/diff_test.dart` | exit 0; 119 passing | local OID-producing success and existing error paths remain correct |
| `flutter analyze lib/src/bindings/index.dart lib/src/bindings/stash.dart lib/src/bindings/diff.dart test/index_test.dart test/stash_test.dart test/diff_test.dart` | exit 0; no issues | focused adapters and suites are clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/bindings/index.dart lib/src/bindings/stash.dart lib/src/bindings/diff.dart test/index_test.dart test/stash_test.dart test/diff_test.dart` | exit 0 | recorded correction has no whitespace errors |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective ownership design and ADR-003 already require releasing temporary
output before error propagation, supporting `spec-correta`. The correction is
contained by local and origin `0.5.5`; package publication remains pending, so
the record is `active` / `delivering`.
