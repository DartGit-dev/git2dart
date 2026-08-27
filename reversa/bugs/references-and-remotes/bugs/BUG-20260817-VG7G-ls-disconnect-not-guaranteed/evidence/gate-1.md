# Gate 1 Evidence

## Authorization

The broad automatic-remediation authorization is recorded in
`evidence/authorization.md`. It covers this test-only correction without a
new plan or Gate 1 question.

## Applied test change

CHG-003 adds a structural assertion for the `Remote.ls` cleanup block. The
test normalizes CRLF to LF before matching the source, so the assertion checks
the same Dart control flow on Windows and Unix working trees.

## Historical red proof

Command, without checkout, switch, reset, or worktree:

```powershell
git show '1914a90^:lib/src/remote.dart' | rg -U -n 'try \{\r?\n      refs = remote_bindings\.lsRemotes\(_remotePointer\);\r?\n    \} finally \{\r?\n      remote_bindings\.disconnect\(_remotePointer\);'
```

Result: exit code 1 with no match. The pre-fix method is sequential, so the
CHG-003 `contains` assertion is red against this immutable historical source.

## Current green proof

Command:

```powershell
flutter test -j 1 test/remote_test.dart
```

Result: exit code 0; 36 tests passed and 7 network-tagged tests skipped. The
`Remote keeps advertisement listing cleanup in finally` test passed.

## Scope and proof boundary

No public remote was contacted. The red proof is structural and establishes
the absent cleanup block in the immutable pre-fix source; it is not a live
native advertisement-listing failure.
