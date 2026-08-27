# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: `lib/src/bindings/reflog.dart`, `lib/src/reflog.dart`, and `test/reflog_test.dart`

## Historical red proof

The immutable parent `1914a90^` returned `git_reflog_entry_byindex` directly from `getByIndex`. A null native result therefore reached `RefLog.operator []`, which created a public `RefLogEntry` before any property dereference. The parent has no invalid-lookup regression test. This confirms the prior causal path without switching or checking out historical source.

## Current implementation

`bindings.getByIndex` now rejects `nullptr` with `Git2DartError('Out of bounds')` before returning any pointer. Both `RefLog.operator []` and the iterator obtain entries only through that binding, so neither can project a null native entry.

`1914a90` is an ancestor of current HEAD. The checked source and test files have no local working-tree diff, so unrelated checkout changes did not affect this audit.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/reflog_test.dart --plain-name "throws when looking up an entry at an invalid index"` | exit 0; 1 passing | lower and upper out-of-range indexes fail at the FFI boundary |
| `flutter test -j 1 test/reflog_test.dart --plain-name "returns the log message"` | exit 0; 1 passing | valid lookup still projects the native entry |
| `flutter analyze lib/src/bindings/reflog.dart lib/src/reflog.dart test/reflog_test.dart` | exit 0; no issues | focused source and tests are statically clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/bindings/reflog.dart test/reflog_test.dart` | exit 0 | recorded correction has no whitespace errors |

## Closure

The evidence supports `spec-correta`; see `spec-verdict.md`. The correction is contained by local and remote `0.5.5`, but package publication remains pending, so this record is `active` / `delivering`.
