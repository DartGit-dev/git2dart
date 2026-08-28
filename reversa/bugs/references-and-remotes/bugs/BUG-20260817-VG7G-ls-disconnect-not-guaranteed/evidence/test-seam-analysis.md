# Test Seam Analysis

## Goal

Produce a deterministic regression that distinguishes the former post-connect
listing cleanup defect without contacting a public remote or adding a mutable
runtime hook to the package API.

## Alternatives considered

1. A local repository advertised through the existing `Remote.ls` test proves
   only the success path. The former sequential implementation also disconnects
   after a successful `lsRemotes` call, so this test is green before CHG-002.
2. A binding override that throws after connect would exercise the exceptional
   path dynamically, but it requires mutable production test infrastructure in
   `lib/src/bindings/remote.dart`. That expands the correction surface and
   cannot be introduced in the tests-only Gate 1 without changing source.
3. A controlled malformed local advertisement was not established as a safe
   deterministic stimulus. It could fail during connect rather than listing,
   or depend on libgit2 transport details.

## Selected seam

Add a source-structure assertion in `test/remote_test.dart`. It scopes its
read to `Remote.ls` and verifies that `try` precedes `lsRemotes`, that
`finally` follows it, and that `disconnect` follows the `finally` clause.
The project already uses this testing style for resource-lifetime structure in
the same file.

## Proof boundary

The regression is deterministic and fails against the former sequential body
in commit `1914a90^`; it passes against the current `try/finally` body. It
proves the Dart wrapper's exceptional cleanup structure, not a live libgit2
advertisement failure. The existing local remote test remains the dynamic
success-path check. Both tests require Gate 1 approval before any test file is
changed.
