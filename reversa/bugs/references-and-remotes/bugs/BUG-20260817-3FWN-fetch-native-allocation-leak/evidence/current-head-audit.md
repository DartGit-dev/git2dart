# Current-head local ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `c8ce43e` (`fix: release remote native allocations`)
- Validation: local source-contract test only; no remote network access

## Current implementation

The fetch binding allocates its refspec wrapper, pointer array, and fetch
options through the active arena. The source-contract regression rejects the
former global `calloc` patterns. The recorded correction is whitespace-clean:

`git diff --check c8ce43e^ c8ce43e -- lib/src/bindings/remote.dart test/remote_test.dart` exited 0.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/remote_test.dart --plain-name "owns fetch temporary allocations through the active arena"` | exit 0; 1 passing | all three fetch temporary containers are arena-owned |
| `flutter analyze lib/src/bindings/remote.dart test/remote_test.dart` | exit 0; no issues | focused binding and regression are clean |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective fetch requirements and ADR already require deterministic
temporary ownership, supporting `spec-correta`. The correction is contained
by local and origin `0.5.5`; package publication remains pending, so the
record stays `active` / `delivering`.
