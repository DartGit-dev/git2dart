# Current-head extensions disposal audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` (`fix: harden native binding cleanup`)
- Validation: local global-option round trip only; no network access

## Current implementation

`Libgit2.extensions` obtains its native output array, converts all values to
Dart strings, and invokes `git_strarray_dispose` in `finally` before releasing
the outer allocation. This preserves returned Dart strings while releasing the
native-owned string array on both successful conversion and a throwing path.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/libgit2_test.dart --plain-name "sets and returns the list of git extensions"` | exit 0; 1 passing | local extension set/get values remain valid |
| `flutter analyze lib/src/libgit2.dart test/libgit2_test.dart` | exit 0; no issues | focused getter and regression are clean |
| `git diff --check e2d8bb4^ e2d8bb4 -- lib/src/libgit2.dart test/libgit2_test.dart` | exit 0 | recorded corrective commit has no whitespace errors |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective native-memory requirement and ADR-003 already require a matching
native disposer, supporting `spec-correta`. The correction is contained by
local and origin `0.5.5`; package publication remains pending, so the record is
`active` / `delivering`.
