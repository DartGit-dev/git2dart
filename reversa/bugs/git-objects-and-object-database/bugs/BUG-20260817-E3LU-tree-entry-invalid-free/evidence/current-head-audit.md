# Current HEAD Audit

## Scope

Audited BUG-20260817-E3LU without changing production source, tests,
specifications, Git history, or delivery state.

## Ownership correction

`Tree.entries`, index lookup, filename lookup, and OID lookup construct a
borrowed `TreeEntry`. Its default constructor sets `_isOwned` to `false`.
Path lookup alone uses `_byPath`, sets `_isOwned` to `true`, and attaches the
entry finalizer. `TreeEntry.free` raises `StateError` before a native free when
the entry is borrowed; owned path entries still call `freeEntry` and detach the
finalizer.

## Focused validation

```powershell
flutter test -j 1 test/tree_test.dart --plain-name 'manual release'
flutter test -j 1 test/tree_test.dart --plain-name 'looked up by path'
```

Results: exit code 0 for both commands. The first passed all four borrowed
release rejection routes; the second passed the owned path-entry release route.

## Specification verdict

The existing ownership model states that tree entries are borrowed or copied
according to the wrapper and must not outlive the native owner unless copied.
The requirements also require manual release to detach fallback cleanup while
borrowed views are not released. These pre-existing contracts support the
recorded `spec-correta` verdict; no addendum is needed.

## Delivery state

Correction commit `88bbed52ae15fd113ceb15af10e609591488943c` is an ancestor
of current HEAD and is contained by local `0.5.5` and `origin/0.5.5`. No pull
request, publication, release, or backport verification was performed or
implied.
