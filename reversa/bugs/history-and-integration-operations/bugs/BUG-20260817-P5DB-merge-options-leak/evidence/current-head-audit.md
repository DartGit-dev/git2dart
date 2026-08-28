# Current-head merge-options ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Validation: local merge scenarios only; no network access

## Current implementation

The shared merge-options helper receives a caller arena and allocates the
native options structure through it. Merge, merge-commits, and merge-trees all
invoke the helper within their own arena scope, so each temporary has one owner
on success and on a translated native error.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/merge_test.dart` | exit 0; 27 passing | local merge, merge-commits, merge-trees, and error behavior |
| `flutter analyze lib/src/bindings/merge.dart test/merge_test.dart` | exit 0; no issues | focused binding and regression suite are clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/bindings/merge.dart test/merge_test.dart` | exit 0 | recorded correction has no whitespace errors |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective merge design and ADR-003 already require deterministic temporary
ownership, supporting `spec-correta`. The correction is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
