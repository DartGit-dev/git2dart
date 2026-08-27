# Current HEAD Audit

## Scope

Audited BUG-20260817-T8MW without changing production source, tests,
specifications, Git history, or delivery state.

## Code

`lib/src/bindings/commit.dart` passes `nullptr` when `parents.isEmpty` in all
three serializers: `create`, `createBuffer`, and `createFromIds`. Each
non-empty branch alone allocates `parentCount` pointer elements and copies the
input parents. No `parentsC[0] = nullptr` sentinel write remains.

## Focused validation

```powershell
flutter test -j 1 test/commit_test.dart --plain-name 'without parents'
flutter test -j 1 test/commit_test.dart --plain-name 'zero-length parent pointer arrays'
```

Results: exit code 0 for both commands. The first command passed all three
root-commit routes (buffer, public creation, and creation from IDs); the
second passed the source invariant that rejects zero-length pointer writes.

## Effective specification

`reversa/sdd/addenda/bug-BUG-20260817-T8MW-v001.md` is present and agrees
with the current code: zero parents require `nullptr` without indexing an
empty allocation, while non-empty lists preserve ordered parent pointers for
all three serializers.

## Delivery state

Correction commit `88bbed52ae15fd113ceb15af10e609591488943c` is an ancestor
of current HEAD and is contained by local `0.5.5` and `origin/0.5.5`. No pull
request, publication, release, or backport verification was performed or
implied.
