# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: global option facade, structural global-option regression, and option round trips

## Current implementation

`lib/src/libgit2.dart` captures and immediately checks every current
`git_libgit2_opts_*` result before reading an output buffer or returning. The
structural regression identifies every global-option call and requires a
following `checkErrorAndThrow`; it passed on current HEAD. The focused source
files have no local working-tree diff.

The historical red proof and Gate 2 green evidence remain recorded in
`evidence/gate-1-red.md` and `evidence/gate-2-green.md`. The correction's
recorded diff has no whitespace errors:

`git diff --check 1914a90^ 1914a90 -- lib/src/libgit2.dart test/libgit2_option_error_test.dart test/libgit2_test.dart` exited 0.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/libgit2_option_error_test.dart test/libgit2_test.dart` | exit 0; 34 passing | native failure translation, complete structural checking, and supported option round trips |
| `flutter analyze lib/src/libgit2.dart test/libgit2_option_error_test.dart test/libgit2_test.dart` | exit 0; no issues | focused facade and regressions are statically clean |

## Specification and closure

The effective requirements and ADR already require immediate translation of
negative native statuses. The evidence therefore supports `spec-correta`; no
effective-spec addendum is required. The corrective commit is contained by
local and origin `0.5.5`, but package publication remains pending, so this
record is `active` / `delivering`.
