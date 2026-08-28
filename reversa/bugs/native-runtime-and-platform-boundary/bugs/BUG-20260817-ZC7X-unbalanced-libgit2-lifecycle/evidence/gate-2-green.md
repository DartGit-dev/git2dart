# Gate 2 GREEN Evidence

## Applied change set

The approved diffs were applied in order to the active `F:/git2dart` checkout.
Each saved applied diff is byte-identical to its approved proposal.

| Change | Applied artifact | SHA-256 |
| --- | --- | --- |
| CHG-003 | `fix/CHG-003.diff` | `C99C10A65F0FB9FF34399CD808CDBE3DB1E900D12949F6307EB62091E04FE0FE` |
| CHG-004 | `fix/CHG-004.diff` | `85B9D38C50F455F9AF9EE4606A1A6FB3FA2C6D2335481F8C79FC5FD8A73CE603` |
| CHG-005 | `fix/CHG-005.diff` | `9F1AE01A2150AA83D2F583BB81735508B3ACB7DF26639A848010EFFC91845BAD` |
| CHG-006 | `fix/CHG-006.diff` | `D6DDA054223B353FF8F5EA32DF894E3E240740DB9D38C9BEEB7370ACD04A740E` |

Formatting covered all 62 Dart files touched by the approved diffs:

```text
Formatted 62 files (0 changed) in 0.38 seconds.
```

`flutter pub get` completed successfully and retained the direct
`F:/git2dart_binaries` path override. The package configuration resolves that
checkout as the Dart API/lifecycle implementation.

## Static validation

```powershell
flutter analyze lib test
```

Result: `No issues found! (ran in 4.1s)`.

## Scoped lifecycle validation

```powershell
$env:GIT2DART_BINARIES_PACKAGE_ROOT='C:/Users/Viktor/AppData/Local/Pub/Cache/hosted/pub.dev/git2dart_binaries-1.12.1'
flutter test -j 1 test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart
```

Result: `8/8` tests passed.

The source contract test confirms that production code contains no legacy
`libgit2`/`libgit2Opts` consumers and no direct uncontrolled initialization
increments. Runtime tests confirm stable repeated calls, guarded shutdown with
live `Repository`/independently usable `Commit` owners, exact-once explicit
release, construction rollback, transfer behavior, terminal shutdown, and
isolate composition in the tested Windows process.

## Proportionate broader validation

```powershell
$env:GIT2DART_BINARIES_PACKAGE_ROOT='C:/Users/Viktor/AppData/Local/Pub/Cache/hosted/pub.dev/git2dart_binaries-1.12.1'
flutter test -j 1 test/repository_test.dart test/commit_test.dart test/libgit2_test.dart
```

Result: `111/111` tests passed.

## Proof boundary

- Dart declarations and lifecycle behavior came from the direct
  `F:/git2dart_binaries` checkout.
- That checkout has no Windows DLL payload, so the Windows tests used the
  hosted 1.12.1 package directory only as the native binary root.
- CHG-004 proves lifecycle owner guards for `Repository` and independently
  usable `Commit`; it does not prove the wider 31-owner inventory.
- The companion checkout still declares 1.12.1. CHG-006 requires
  `>=1.12.2 <1.13.0`, but assignment/publication of a compatible 1.12.2 package
  remains unproven.
- No full-suite, Linux, macOS, Android, iOS, CI, merge, publication, tag, or
  release evidence was produced.

