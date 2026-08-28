# Current-head checkout lookup audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Validation: local repository checkout scenarios only; no network access

## Current implementation

Reference checkout owns a looked-up reference and a temporary treeish under
nested `try/finally` blocks. Commit checkout owns its temporary treeish under
a `try/finally` block. Native checkout success and translated failure therefore
both release each temporary exactly once.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/checkout_test.dart` | exit 0; 12 passing | local reference/commit checkout success and invalid-directory error paths |
| `flutter analyze lib/src/checkout.dart test/checkout_test.dart` | exit 0; no issues | focused implementation and regression suite are clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/checkout.dart test/checkout_test.dart` | exit 0 | recorded correction has no whitespace errors |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective checkout flow and ownership design already require cleanup on
all exits, supporting `spec-correta`. The correction is contained by local and
origin `0.5.5`; package publication remains pending, so the record is `active`
/ `delivering`.
