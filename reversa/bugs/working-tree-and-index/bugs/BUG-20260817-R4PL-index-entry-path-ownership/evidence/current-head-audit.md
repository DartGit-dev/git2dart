# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: `lib/src/index.dart`, `lib/src/bindings/index.dart`, and `test/index_test.dart`

## Historical red proof

The immutable parent `1914a90^` constructs `IndexEntry` directly from the borrowed `git_index_entry` pointer. Its `oid` and `mode` setters write that pointer directly, and its `path` setter assigns `path.toCharAlloc()` to the borrowed structure's `path` field. The parent has neither `copyEntry` nor `freeEntry`, and it has no two focused ownership tests. This establishes the pre-correction causal path without switching or checking out historical source.

## Current implementation

`IndexEntry` now calls `bindings.copyEntry` for every non-null projection. `copyEntry` allocates the complete `git_index_entry` and its NUL-terminated UTF-8 path in one `calloc` block, copies all structure fields, and adjusts only the path-length flag bits when replacing a path. `_IndexEntryOwner.replace` installs the successor before freeing the predecessor; `free` detaches the finalizer and makes repeated disposal idempotent.

`1914a90` is an ancestor of the current HEAD. The three corrective source/test files have no local working-tree diff, so unrelated checkout changes did not affect this audit.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/index_test.dart` | exit 0; 58 passing | borrowed-entry isolation, add of owned mutation, replacement allocation, and idempotent disposal pass |
| `flutter analyze lib/src/index.dart lib/src/bindings/index.dart test/index_test.dart` | exit 0; no issues | focused source and regression test are statically clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/index.dart lib/src/bindings/index.dart test/index_test.dart` | exit 0 | recorded correction has no whitespace errors |

## Specification and closure

The correction fulfills the existing ownership requirements in `reversa/sdd/working-tree-and-index/design.md#ownership-and-errors` and `reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision`. The evidence supports a `spec-correta` recommendation; the user must still make that mandatory verdict. The package closure policy also still requires delivery evidence, so this record remains `active` / `awaiting-human`.
