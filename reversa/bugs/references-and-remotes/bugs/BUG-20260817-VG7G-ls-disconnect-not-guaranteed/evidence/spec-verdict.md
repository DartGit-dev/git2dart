# Specification verdict

- Date: 2026-08-27
- Bug: `BUG-20260817-VG7G`
- Verdict: `spec-correta`

## Effective specification

- `reversa/sdd/references-and-remotes/requirements.md` BR-RR-06 requires remote listing to disconnect after advertisements are read.
- FR-RR-07 requires advertised references to return after connection lifecycle cleanup and requires errors to throw.
- `flows.md` FL-RR-03 orders copying advertised data before disconnect.
- `edge-cases.md` EC-RR-12 explicitly requires disconnect and temporary cleanup when connection, authentication, or listing fails.

## Comparison and decision

The former sequential implementation diverged from those requirements because a post-connect `lsRemotes` error bypassed disconnect. Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` encloses listing in `try/finally`, disconnecting on both normal and exceptional exits while preserving the listing error as the primary outcome.

The focused current suite passed 36 tests, the immutable pre-fix source lacks the required cleanup structure, and current `Remote.ls` retains it. The blanket authorization recorded in `evidence/authorization.md` permits this evidence-based default verdict. No specification addendum is required.
