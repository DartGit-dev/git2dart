# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: `lib/src/bindings/index.dart`, `lib/src/index.dart`, and `test/index_test.dart`

## Historical red proof

The immutable parent `1914a90^` discarded the return values of `git_index_read`, `git_index_read_tree`, and `git_index_write`. It had no `checkErrorAndThrow` call in any of those binding paths and no focused native-index-persistence failure test. This confirms the prior false-success causal path without switching or checking out historical source.

## Current implementation

The three bindings now capture the native integer status and pass it through `checkErrorAndThrow`. The public `Index.read`, `Index.readTree`, and `Index.write` methods continue to delegate only to those bindings, so a negative native status cannot return as a successful public operation.

`1914a90` is an ancestor of current HEAD. The checked source and test files have no local working-tree diff, so unrelated checkout changes did not affect this audit.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/index_test.dart --plain-name "throws when native index persistence operations fail"` | exit 0; 1 passing | in-memory read and write failures are translated as `LibGit2Error` |
| `flutter test -j 1 test/index_test.dart --plain-name "reads tree with provided SHA hex"` | exit 0; 1 passing | valid `readTree` behavior remains intact |
| `flutter analyze lib/src/index.dart lib/src/bindings/index.dart test/index_test.dart` | exit 0; no issues | focused source and tests are statically clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/bindings/index.dart test/index_test.dart` | exit 0 | recorded correction has no whitespace errors |

## Closure

The evidence supports `spec-correta`; see `spec-verdict.md`. The correction is contained by local and remote `0.5.5`, but package publication remains pending, so this record is `active` / `delivering`.
