# Gate 2 Proposal Validation

## Construction boundary

The production/dependency proposal was constructed in the disposable ordinary clone `.reversa/tmp-zc7x-gate2-20260823`. It is not a Git worktree. No proposed production, documentation, or dependency file was applied to the active `F:/git2dart` checkout.

The API comparison command was:

```powershell
dart run tool/compare_git2dart_binaries_api.dart --old 1.12.1 --new F:/git2dart_binaries
```

It confirms the breaking removal of `libgit2` and `libgit2Opts`, plus the additions of `libgit2Runtime`, `Libgit2Runtime`, `Libgit2RuntimeState`, and `Libgit2OwnerLease`. This declaration comparison does not prove native ABI, packaging, or cross-platform behavior.

## Proposed diffs

| Change | Scope | SHA-256 |
| --- | --- | --- |
| `fix/CHG-003.proposed.diff` | Managed runtime API migration across 58 source/test files | `C99C10A65F0FB9FF34399CD808CDBE3DB1E900D12949F6307EB62091E04FE0FE` |
| `fix/CHG-004.proposed.diff` | Shared owner adapter plus `Repository` and `Commit` exact-once owner guards | `85B9D38C50F455F9AF9EE4606A1A6FB3FA2C6D2335481F8C79FC5FD8A73CE603` |
| `fix/CHG-005.proposed.diff` | Public shutdown API and lifecycle documentation | `9F1AE01A2150AA83D2F583BB81735508B3ACB7DF26639A848010EFFC91845BAD` |
| `fix/CHG-006.proposed.diff` | Minimum companion contract and API baseline `1.12.2` | `D6DDA054223B353FF8F5EA32DF894E3E240740DB9D38C9BEEB7370ACD04A740E` |

Combined `git apply --check` against the active Gate 1 checkpoint succeeded. Diff hygiene found no temporary-copy, override, `.dart_tool`, or absolute-path leakage.

## Bounded validation

```powershell
flutter analyze lib test
```

Result: `No issues found`.

```powershell
$env:GIT2DART_BINARIES_PACKAGE_ROOT='C:/Users/Viktor/AppData/Local/Pub/Cache/hosted/pub.dev/git2dart_binaries-1.12.1'
flutter test -j 1 test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart
```

Result: `8/8` tests passed.

The Dart API and lifecycle implementation came from the direct `F:/git2dart_binaries` override. Its local `windows/` directory contains source scaffolding but no native DLL payload, so the bounded Windows run explicitly used the hosted 1.12.1 package directory only as the native binary root. No Linux, macOS, Android, iOS, full-suite, CI, merge, publication, or release proof was produced.

## Remaining boundary

The concrete CHG-004 proposal guards the two owner types proven by Gate 1: `Repository` and independently usable `Commit`. Other finalizer-backed wrappers from the broader inventory are not part of this bounded proposal and must be evaluated before claiming universal live-owner shutdown protection.

The companion checkout still declares package version `1.12.1`; CHG-006 reserves the required `>=1.12.2 <1.13.0` delivery contract, but publication/availability of that version is not proven.
