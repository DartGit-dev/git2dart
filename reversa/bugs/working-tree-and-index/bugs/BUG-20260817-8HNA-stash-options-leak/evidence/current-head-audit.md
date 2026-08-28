# Current-head stash-options ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Validation: local repository-only stash scenarios; no remote network access

## Current implementation

`checkout.initOptions` accepts the caller arena and allocates checkout options
and optional path-pointer storage through that arena. Both stash apply and pop
run inside `using((arena))` and pass that exact arena to the helper, preserving
one owner across normal and throwing native exits. The recorded correction is
whitespace-clean:

`git diff --check 1914a90^ 1914a90 -- lib/src/bindings/checkout.dart lib/src/bindings/stash.dart test/stash_test.dart` exited 0.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/stash_test.dart` | exit 0; 17 passing | local apply/pop success and invalid-index error paths |
| `flutter analyze lib/src/bindings/checkout.dart lib/src/bindings/stash.dart test/stash_test.dart` | exit 0; no issues | focused binding and local regression suite are clean |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The memory ADR already requires deterministic temporary ownership, supporting
`spec-correta`. The correction is contained by local and origin `0.5.5`;
package publication remains pending, so the record is `active` / `delivering`.
