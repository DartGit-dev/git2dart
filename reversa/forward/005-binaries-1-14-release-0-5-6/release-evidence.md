# Release Evidence: 0.5.6 Candidate

> Feature: `005-binaries-1-14-release-0-5-6`
> Candidate host: Windows x64 (Asia/Novosibirsk)
> Evidence boundary: each result below is scoped to the named command, host, and observation.

## Pre-change state

- Starting commit: `832481f`
- Starting branch: `0.5.6`
- Pre-existing working-tree changes preserved outside this release delta: `.lean-ctx/overlays.json`, `.reversa/active-requirements.json`, and the untracked feature directory.
- Toolchain: Flutter 3.38.2 stable; Dart 3.10.0 stable; Windows x64.

## Evidence matrix

| Evidence area | Command or target | Result | Scope and limitations |
|---|---|---|---|
| Dependency resolution | `flutter pub get` | Passed | Resolved hosted `git2dart_binaries` 1.14.0; lock SHA-256 `d876a7a48170a53a7b50fc65de42b8ab5e1b8a7e1902747e5ceb308b054c887d`. |
| Exported Dart declarations | `dart run tool/compare_git2dart_binaries_api.dart --old 1.13.0 --new 1.14.0` | Passed: 0 breaking, 0 non-breaking, 0 changed declarations | Public-Dart-API-only result; cannot prove ABI, binary packaging, ownership, runtime, or transport behavior. Temporary report inspected then deleted. |
| Focused platform tests | `flutter test -j 1 test/platform_specific_test.dart` | Passed: 3 tests | Observed on Windows x64 only. Android and iOS device/simulator behavior remains unproven. |
| Adapter/static surface | Resolved declarations, static facade inspection, and analyzer diagnostics | No mismatch observed; no source or test repair justified | `PlatformSpecific` facade and `Libgit2` adapter remain compatible by local static/test evidence; not target runtime proof. |
| Local candidate gate | `dart format . --set-exit-if-changed`; `flutter analyze --fatal-infos`; `flutter test -j 1 --reporter expanded` | Passed | Format: 158 files, 0 changed. Analyze: no issues. Test: 956 passed, 24 skipped. Host-scoped Windows x64 evidence only. |
| Package dry-run | `dart pub publish --dry-run` | Passed | Package assembly and pub validation only; not publication. |
| Hosted Quality | Not run | Unproven | Requires explicit push authorization. |
| Hosted Linux | Not run | Unproven | Requires explicit push authorization. |
| Hosted macOS | Not run | Unproven | Requires explicit push authorization. |
| Hosted Windows | Not run | Unproven | Requires explicit push authorization. |
| Hosted Android | Not run | Unproven | Requires explicit push authorization. |
| Hosted iOS | Not run | Unproven | Requires explicit push authorization. |
| Publication | Not run | Unproven | Requires explicit maintainer authorization. |
| Live HTTPS behavior | Not run | Unproven | No live transport observation in this candidate. |
| Live SSH behavior | Not run | Unproven | No live transport observation in this candidate. |

## Release boundary

This document records local release-candidate evidence only. No remote workflow was triggered or observed, no tag was created, and no package was published.

## Candidate and hosted-validation boundary

- Local candidate commit: `f55e816` (`chore: prepare 0.5.6 release candidate`).
- T014 is blocked pending explicit authorization to push this candidate. No Build workflow was triggered or observed, so Quality, Linux, macOS, Windows, Android, and iOS remain individually unproven.
- The available local portions of T015 and T016 are complete: the matrix names every unrun hosted target and keeps API comparison, local validation, package dry-run, publication, and live HTTPS/SSH as distinct evidence scopes. T015 and T016 remain unchecked because their T014 dependency has not run.

## Corrected local-gate finding

The initial full Windows x64 suite exposed a concrete post-upgrade expectation mismatch: `Libgit2 returns up to date version of libgit2` expected `1.9.6`, while the bundled 1.14.0 runtime reported `1.9.7`. With explicit authorization, the single assertion was corrected to `1.9.7`; the full candidate gate then passed.

## Dependency and upstream review

- The resolved companion changelog for 1.14.0 was inspected: its bundled libgit2 build is 1.9.7 and the release notes a CVE-2026-5917 libssh2 remote-path escaping fix.
- Relevant upstream libgit2 1.9 release notes were inspected. They identify the 1.x line as ABI-stable until the planned 2.0 break; that upstream statement does not prove this package's artifact contents or this candidate's runtime behavior.
- No live HTTPS or SSH operation was performed. The security change is release-note context, not live transport proof.
