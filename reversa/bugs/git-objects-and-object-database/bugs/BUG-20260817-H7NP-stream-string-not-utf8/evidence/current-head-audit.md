# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134` (`fix: address registered libgit2 defects`)
- Scope checked: `lib/src/writestream.dart` and `test/blob_test.dart`

## Historical red proof

The immutable parent `1914a90^` implemented `BlobWriteStream.writeString` as `Uint8List.fromList(text.codeUnits)`. It therefore passed UTF-16 code units to an 8-bit native write API rather than UTF-8 bytes. The parent has no UTF-8 blob-stream regression. This establishes the data-corruption path without switching or checking out historical source.

## Current implementation

`writeString` now delegates to `utf8.encode(text)` before the existing byte-write path. The regression source is UTF-8 encoded: byte inspection confirms the literal contains Cyrillic `Привет` (`D0 9F ... D1 82`), emoji `😀` (`F0 9F 98 80`), and the combining acute escape `e\\u0301`. The displayed mojibake in a non-UTF-8 console is not source corruption.

`1914a90` is an ancestor of current HEAD. The checked source and test files have no local working-tree diff, so unrelated checkout changes did not affect this audit.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/blob_test.dart --plain-name "writes UTF-8 text to a blob stream"` | exit 0; 1 passing | mixed ASCII, Cyrillic, emoji, and combining-character content round-trips and matches exact UTF-8 bytes |
| `flutter analyze lib/src/writestream.dart test/blob_test.dart` | exit 0; no issues | focused source and regression test are statically clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/writestream.dart test/blob_test.dart` | exit 0 | recorded correction has no whitespace errors |

## Closure

The effective SDD omitted the `writeString` encoding contract, so the approved evidence-based verdict is `spec-gap`; see `spec-verdict.md` and the immutable UTF-8 addendum. The correction is contained by local and remote `0.5.5`, but package publication remains pending, so this record is `active` / `delivering`.
