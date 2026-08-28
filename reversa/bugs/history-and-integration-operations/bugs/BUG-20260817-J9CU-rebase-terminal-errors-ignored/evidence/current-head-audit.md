# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: rebase terminal bindings, public wrappers, recorded regression, and focused validation

## Historical red proof and current implementation

Before `1914a90`, `finish` directly returned the result of
`git_rebase_finish` and `abort` directly returned the result of
`git_rebase_abort`; neither integer status reached `checkErrorAndThrow`.
The recorded reproduction shows a second finish returned `-15` and the public
call returned normally.

The current implementations capture the two statuses and pass each through
`checkErrorAndThrow`. Public `Rebase.finish` and `Rebase.abort` continue to
delegate to those bindings. `git diff --check 1914a90^ 1914a90 --
lib/src/bindings/rebase.dart test/rebase_test.dart` exited 0.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/rebase_test.dart --plain-name "performs rebase when there is no conflicts"` | exit 0; 1 passing | successful finish and repeated-finish `LibGit2Error` regression |
| `flutter test -j 1 test/rebase_test.dart --plain-name "aborts rebase in progress"` | exit 0; 1 passing | normal abort restores repository state |
| `flutter analyze lib/src/bindings/rebase.dart lib/src/rebase.dart test/rebase_test.dart` | exit 0; no issues | focused static analysis is clean |

## Proof boundary and closure

No safe deterministic abort-failure stimulus is available in this libgit2
build: repeated abort and temporary index/HEAD lock-file probes are
idempotent. Static control flow nevertheless proves that the fallible abort
status now reaches the shared error boundary. No unsafe stale-pointer
injection was used.

The evidence supports `spec-correta`; see `spec-verdict.md`. The correction
is contained by local and origin `0.5.5`, but package publication remains
pending, so this record is `active` / `delivering`.
