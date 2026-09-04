# Onboarding: Validate the 0.5.6 Candidate with Companion Binaries 1.14.0

## Purpose

This runbook lets a maintainer validate the release candidate while preserving
the boundary between observed evidence and unproven behavior.

## Prerequisites

- Dart SDK `>=3.7.2 <4.0.0` and Flutter `>=3.29.3` available on the test host.
- A clean or intentionally understood working tree.
- Network access to pub.dev for dependency resolution and package dry-run.
- On Windows, native DLL availability on `PATH` when running native tests.
- Android emulator and iOS simulator access only when collecting those target results.

## Steps

1. Inspect `pubspec.yaml` and confirm the planned range is `>=1.14.0 <1.15.0`; run dependency resolution and confirm `pubspec.lock` selects exactly 1.14.0.
2. Retain the completed 1.13.0-to-1.14.0 public declaration comparison with the release evidence. Record that it is not ABI, package-artifact, or runtime proof.
3. Confirm `lib/git2dart.dart` still exports `PlatformSpecific`; confirm `PlatformSpecific.initialize`, `androidInitialize`, and `iosInitialize` remain callable.
4. Run the local quality gate: formatting check, `flutter analyze`, and the automated test suite. Record the host OS, Flutter/Dart versions, commands, result, and skipped tests.
5. Run `dart pub publish --dry-run` and record its result separately from any actual publication.
6. Where available, execute Android and iOS initialization coverage on the configured emulator/simulator. If unavailable, record each target as unproven rather than failed or passing.
7. Trigger or observe the configured GitHub Actions Build matrix. Record Quality, Linux, macOS, Windows, Android, and iOS results separately, tied to the candidate commit.
8. Update `CHANGELOG.md` for 0.5.6 only after the compatibility outcome and observed evidence are known. Include the 1.14.0 companion upgrade and no-public-declaration-change outcome without claiming native or live-network equivalence.
9. Before a release tag or publication, obtain the required release authorization. A successful dry-run or CI run is not publication evidence.

## Expected result

The candidate resolves the intended companion version, keeps its public Dart
surface and explicit mobile initialization paths, and has an evidence record
whose claims match the exact local and hosted checks actually observed.

## Troubleshooting

| Symptom | First action | Claim boundary |
|---------|--------------|----------------|
| Resolution chooses a version other than 1.14.0 | Inspect the constraint and lock file before changing source. | Dependency-selection issue only. |
| Analyzer fails after resolution | Map the diagnostic to a hand-written adapter and delivered declaration. | A concrete compatibility finding, not broad ABI proof. |
| Android/iOS initialization fails | Isolate the platform helper and companion runtime artifact; collect target logs. | Target-specific runtime finding. |
| A remote test is skipped or unavailable | Record it as unproven; do not replace it with offline suite success. | No live HTTPS/SSH claim. |
| Publish job is skipped | Record workflow status only. | Not proof of publication. |
