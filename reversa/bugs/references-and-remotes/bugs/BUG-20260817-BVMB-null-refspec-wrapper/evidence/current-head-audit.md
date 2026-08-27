# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: `lib/src/bindings/remote.dart`, `lib/src/remote.dart`, `lib/src/refspec.dart`, and `test/remote_test.dart`

## Historical red proof

The immutable parent `1914a90^` returned `git_remote_get_refspec` directly from `getRefspec`. A null native result therefore reached `Remote.getRefspec`, which constructed a public `Refspec` around it. The parent has no invalid-refspec-index regression. This confirms the prior causal path without switching or checking out historical source.

## Current implementation

`remote_bindings.getRefspec` now rejects `nullptr` with `Git2DartError('Refspec index out of bounds')` before returning a pointer. `Remote.getRefspec` can therefore construct a `Refspec` only from a valid native result.

`1914a90` is an ancestor of current HEAD. The production source files have no local working-tree diff. `test/remote_test.dart` has an unrelated approved VG7G regression change, which this audit preserved and did not use as evidence for BVMB.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/remote_test.dart --plain-name "throws when refspec index is out of bounds"` | exit 0; 1 passing | lower and upper out-of-range indexes fail at the FFI boundary |
| `flutter test -j 1 test/remote_test.dart --plain-name "returns refspec"` | exit 0; 1 passing | valid native refspec still projects source, destination, direction, and transforms |
| `flutter analyze lib/src/bindings/remote.dart lib/src/remote.dart lib/src/refspec.dart test/remote_test.dart` | exit 0; no issues | focused source and tests are statically clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/bindings/remote.dart test/remote_test.dart` | exit 0 | recorded correction has no whitespace errors |

## Closure

The evidence supports `spec-correta`; see `spec-verdict.md`. The correction is contained by local and remote `0.5.5`, but package publication remains pending, so this record is `active` / `delivering`.
