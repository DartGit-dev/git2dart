# Current-head ownership audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `c8ce43e` (`fix: release remote native allocations`)
- Inputs: local synthetic callback values only; no network operation and no real credential material

## Current implementation

The callback bridge retains its credential-attempt payload under a nullable
owner, releases it in `reset`, and clears the owner so repeated reset is safe.
The SSH-key builder uses a call-scoped arena for its temporary native values.
Credential error-message conversion also uses bounded callback arenas. The
recorded cleanup diff is whitespace-clean:

`git diff --check c8ce43e^ c8ce43e -- lib/src/bindings/remote_callbacks.dart lib/src/bindings/credentials.dart test/callbacks_test.dart test/credentials_test.dart` exited 0.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/callbacks_test.dart test/credentials_test.dart --exclude-tags remote_fetch` | exit 0; 16 passing | local ownership, idempotent reset, and callback cleanup contracts |
| `flutter analyze lib/src/bindings/remote_callbacks.dart lib/src/bindings/credentials.dart test/callbacks_test.dart test/credentials_test.dart` | exit 0; no issues | focused implementation and tests are clean |

No current source or test gap was demonstrated, so this audit applied no code
or test edit and did not trigger an independent review.

## Verdict and closure

The effective requirements and ADR already require native temporary ownership
and release, supporting `spec-correta`. The correction is contained by local
and origin `0.5.5`; package publication remains pending. The record therefore
stays `active` / `delivering`.
