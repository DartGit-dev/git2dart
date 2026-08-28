# Current-head reference OID ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commits: `aba8aa73dc94d9d11615809699616b8e9e644e84` (OID ownership) and `1914a9053af88c6295fb58e6ed4e357dd8c27134` (reference caller cleanup)
- Validation: local repository reference lookup only; no network access

## Current implementation

The binding allocates an output OID, returns it only after native success, and
cleans it before rethrow on a native failure. `Reference.nameToId` wraps that
successful pointer in an owning `Oid`, which has explicit release and a
finalizer safety net. The OID is therefore released exactly once by its owner.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/reference_test.dart test/oid_test.dart` | exit 0; 75 passing | local name lookup, OID release, and borrowed-copy behavior |
| `flutter analyze lib/src/reference.dart lib/src/bindings/reference.dart lib/src/oid.dart test/reference_test.dart test/oid_test.dart` | exit 0; no issues | focused implementation and regressions are clean |
| `git diff --check 1914a90^ 1914a90 -- lib/src/reference.dart lib/src/bindings/reference.dart lib/src/oid.dart test/reference_test.dart test/oid_test.dart` | exit 0 | recorded correction has no whitespace errors |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict and closure

The effective reference requirements and ADR-003 already require explicit
ownership and release for returned native storage, supporting `spec-correta`.
The correction is contained by local and origin `0.5.5`; package publication
remains pending, so the record is `active` / `delivering`.
