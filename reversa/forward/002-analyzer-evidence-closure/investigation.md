# Investigation: Analyzer Evidence Closure

## Confirmed baseline

A fresh `flutter analyze` under the active direct `../git2dart_binaries`
override reports 21 errors:

| Attribution | Count | Diagnostics |
|-------------|-------|-------------|
| E3LU evidence pair | 4 | Two unresolved `../../../../../test/helpers/util.dart` URIs and two undefined `setupRepo` symbols. |
| ZC7X reproduction evidence | 4 | Four undefined `libgit2` references: two probe operations and two final shutdowns. |
| Product source, excluded | 13 | `LibGit2Error` constructor and FFI pointer-type errors under `lib/`. |

The 13 product diagnostics are not evidence of an E3LU/ZC7X failure and are not
authorized for remediation here. The full analyzer therefore remains non-green
after evidence closure unless those separate product issues are later authorized.

## Root causes

### E3LU

Both capsules live six directory levels below the project root. Their current
five-level relative import resolves below `reversa/`, not the root-level
`test/helpers/util.dart`. The missing URI causes the two consequential
undefined-`setupRepo` diagnostics. Correcting the import is sufficient and
does not alter the reproduction's ownership sequence.

### ZC7X

The evidence imports `git2dart_binaries` but uses the legacy `libgit2`
global. The companion lifecycle contract at ea87cf intentionally removed that
global and exposes `libgit2Runtime`, whose `bindings` member gives the
evidence compile-visible access to init/shutdown probes. The evidence must use
that boundary, not recreate native loading or change package code.

## Prior runtime proof to reuse

The ZC7X Gate 2 evidence documents the Windows validation boundary:

- direct companion Dart API/lifecycle implementation at
  `ea87cf29626a371fcb33e646be64bfe30b565c72`;
- hosted `git2dart_binaries-1.12.1` used only as the missing Windows native
  DLL root;
- `GIT2DART_BINARIES_PACKAGE_ROOT` set for runtime commands;
- no claim of package publication, ABI validation, other platforms, CI, or full
  product correctness.

This feature may reuse that setup transiently to validate the evidence. It must
restore the original override/runtime state afterward and must not publish,
upgrade, or edit dependencies/binaries.

## Applicable practices

- [Dart analyzer command documentation](https://dart.dev/tools/dart-analyze)
- [Flutter command-line reference](https://docs.flutter.dev/reference/flutter-cli)
- [Flutter unit-test command guidance](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [ZC7X companion lifecycle contract](../../reversa/bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-ZC7X-unbalanced-libgit2-lifecycle/evidence/companion-lifecycle-contract.md)

## Alternatives considered

| Alternative | Decision | Reason |
|-------------|----------|--------|
| Fix all 21 diagnostics | Rejected | Thirteen are product-source errors outside explicit scope. |
| Restore the legacy `libgit2` global | Rejected | Contradicts ea87cf's managed runtime contract and expands into companion API work. |
| Add a local lifecycle wrapper in evidence or `lib/` | Rejected | Duplicates native-runtime ownership. |
| Copy `test/helpers/util.dart` into evidence | Rejected | Duplicates fixture behavior and hides the incorrect root relation. |
| Suppress errors with ignores | Rejected | Fails the requirement that URI/symbol/API references resolve. |
| Permanently change the override or stage DLLs | Rejected | Validation setup is temporary and must be restored. |

## Validation interpretation

Targeted analysis proves closure of the eight named diagnostics. The final full
analyzer is a classification report, not a binary pass/fail for this feature:
success means no covered evidence diagnostics and a restored runtime state; the
known 13 excluded `lib/` errors must remain visible and separately named.

