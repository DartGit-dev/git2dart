# Current-head OID ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `aba8aa73dc94d9d11615809699616b8e9e644e84` (`fix: manage Oid native memory ownership`)
- Scope checked: owned OID release, borrowed-pointer copy, finalizer safety net, and focused commit use

## Current implementation

High-level `Oid` instances own one native allocation, expose explicit release,
and attach a finalizer safety net. `Oid.fromBorrowed` copies the native value
before taking ownership, so parent-owned storage is never freed by the child.
The recorded correction is whitespace-clean:

`git diff --check aba8aa7^ aba8aa7 -- lib/src/oid.dart lib/src/bindings/oid.dart test/oid_test.dart test/commit_test.dart` exited 0.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/oid_test.dart test/commit_test.dart` | exit 0; 52 passing | explicit release, copied borrowed-pointer lifetime, and focused OID producer behavior |
| `flutter analyze lib/src/oid.dart lib/src/bindings/oid.dart test/oid_test.dart test/commit_test.dart` | exit 0; no issues | focused implementation and regressions are clean |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Verdict, boundary, and closure

The effective design and memory ADR already require managed or explicitly
released OID storage, supporting `spec-correta`. The correction is contained
by local and origin `0.5.5`; package publication remains pending.

Package-wide compatibility with alternate companion APIs was not revalidated
or migrated here; it remains the separate boundary recorded in
`evidence/local-binaries-compatibility.md`.
