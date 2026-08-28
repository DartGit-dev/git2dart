# Specification verdict

- Date: 2026-08-27
- Verdict: `spec-gap`
- Authorization: the user explicitly authorized evidence-based default specification verdicts while directing automatic remediation of all registered bugs.

## Evidence

`reversa/sdd/git-objects-and-object-database/requirements.md` requires blob text and streaming writes to preserve content and size, but it does not say how `BlobWriteStream.writeString` serializes Dart strings. The SDD test coverage similarly describes text/bytes/stream behavior without a UTF-8 conversion rule.

The prior implementation used UTF-16 code units while its API documentation promised UTF-8. The correction and byte-exact Unicode regression establish UTF-8 as the required contract. `reversa/sdd/addenda/bug-BUG-20260817-H7NP-v001.md` adds that contract without modifying an original specification.

Package publication remains the sole outstanding closure requirement.
