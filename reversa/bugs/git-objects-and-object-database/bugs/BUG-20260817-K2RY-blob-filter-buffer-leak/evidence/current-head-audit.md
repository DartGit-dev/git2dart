# Current-head blob-buffer disposal audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` (`fix: harden native binding cleanup`)
- Validation: local blob-filter scenarios only; no network access

## Current implementation

The filter binding creates the outer buffer in its arena, converts the
libgit2-owned contents to Dart text, and calls `git_buf_dispose` in `finally`.
That finalizer executes after successful conversion and after an error result,
before the arena releases the outer structure.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/blob_test.dart` | exit 0; 20 passing | local filter success, attribute-commit filtering, and native-error behavior |
| `flutter analyze lib/src/bindings/blob.dart test/blob_test.dart` | exit 0; no issues | focused binding and regression suite are clean |
| `git diff --check e2d8bb4^ e2d8bb4 -- lib/src/bindings/blob.dart test/blob_test.dart` | exit 0 | recorded correction has no whitespace errors |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective ownership design and ADR-003 already require disposal of internal
native buffer storage, supporting `spec-correta`. The correction is contained
by local and origin `0.5.5`; package publication remains pending, so the record
is `active` / `delivering`.
