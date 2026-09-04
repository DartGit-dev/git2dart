# Actions: Companion Binaries 1.14 Upgrade and 0.5.6 Release Preparation

> Identifier: `005-binaries-1-14-release-0-5-6`
> Date: `2026-09-04`
> Roadmap: `reversa/forward/005-binaries-1-14-release-0-5-6/roadmap.md`

## Summary

| Metric | Value |
|--------|-------|
| Total actions | 20 |
| Parallelizable (`[//]`) | 2 |
| Longest dependency chain | 16 actions: T002 -> T003 -> T004 -> T006 -> T009 -> T010 -> T011 -> T012 -> T013 -> T014 -> T015 -> T016 -> T017 -> T018 -> T019 -> T020 |

## Phase 1, Preparation

| ID | Description | Dependencies | Parallelism | Primary target file | Confidence | Status |
|----|-------------|--------------|-------------|---------------------|------------|--------|
| T001 | `[//]` Create the release-evidence record with the pre-change working-tree state, host/toolchain identity, and an explicit evidence matrix; reserve separate entries for local checks, each hosted target, dry-run, publication, and live HTTPS/SSH behavior. | - | `[//]` | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[X]` |
| T002 | `[//]` In one metadata-only edit, set package version `0.5.6` and the hosted companion constraint `git2dart_binaries: >=1.14.0 <1.15.0`; do not copy or regenerate companion declarations or binaries. | - | `[//]` | `pubspec.yaml` | 🟢 | `[X]` |
| T003 | Resolve dependencies from the T002 metadata and verify that `pubspec.lock` records exactly hosted `git2dart_binaries` `1.14.0` with its integrity metadata; record the observed resolver result and any registry failure. | T002 | - | `pubspec.lock` | 🟢 | `[X]` |

## Phase 2, Tests

| ID | Description | Dependencies | Parallelism | Primary target file | Confidence | Status |
|----|-------------|--------------|-------------|---------------------|------------|--------|
| T004 | Re-run the 1.13.0-to-1.14.0 public-declaration comparison against the resolved package and attach its exact outcome to release evidence; classify a clean comparison as public-declaration evidence only, never ABI, artifact, runtime, or transport proof. | T003 | - | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[X]` |
| T005 | Execute the existing `PlatformSpecific` focused tests against the resolved companion version and record command, host, result, and skips; mark Android/iOS device or simulator behavior unproven unless it was directly observed. | T003 | - | `test/platform_specific_test.dart` | 🟢 | `[X]` |
| T006 | Only if T005 exposes an initialization incompatibility, add one focused positive and one negative regression test for that evidenced mismatch; otherwise record that no test edit was justified. | T004, T005 | - | `test/platform_specific_test.dart` | 🟢 | `[X]` |

## Phase 3, Core

| ID | Description | Dependencies | Parallelism | Primary target file | Confidence | Status |
|----|-------------|--------------|-------------|---------------------|------------|--------|
| T007 | Inspect the resolved declarations and compile/analyzer diagnostics for an evidenced hand-written adapter, import, type, ownership, ABI-width, or platform-helper mismatch; map any finding to the exact adapter and record no finding when none is observed. | T003 | - | `lib/src/platform_specific.dart` | 🟢 | `[X]` |
| T008 | Verify that `lib/git2dart.dart` continues to export `PlatformSpecific` and that `initialize`, `androidInitialize`, and `iosInitialize` remain callable without changing the public facade; record this static-surface result separately from target runtime evidence. | T003 | - | `lib/git2dart.dart` | 🟢 | `[X]` |
| T009 | Only for a mismatch evidenced by T006 or T007, make the smallest adapter or platform-helper repair while preserving shared error translation, arena/finalizer ownership, and the no-raw-pointer public boundary; add its matching focused regression coverage when T006 did not already cover it; otherwise record that no production-source edit was justified. | T006, T007 | - | `lib/src/<evidenced-adapter>.dart` | 🟢 | `[X]` |

## Phase 4, Integration

| ID | Description | Dependencies | Parallelism | Primary target file | Confidence | Status |
|----|-------------|--------------|-------------|---------------------|------------|--------|
| T010 | Run the release-candidate local gate (`dart format . --set-exit-if-changed`, `flutter analyze --fatal-infos`, and `flutter test -j 1 --reporter expanded`) after all justified code/test changes; capture exact commands, host, tool versions, outcomes, and skipped tests. | T008, T009 | - | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[X]` |
| T011 | Run `dart pub publish --dry-run` for the candidate and record its output separately from actual publication; a successful dry-run proves package assembly and pub validation only. | T010 | - | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[X]` |
| T012 | Add the 0.5.6 changelog entry naming the 1.14.0 companion upgrade and the observed no-public-declaration-change outcome; exclude unobserved native ABI, artifact, publication, and live-network claims. | T004, T011 | - | `CHANGELOG.md` | 🟢 | `[X]` |
| T013 | Create the release-candidate commit containing only the approved 0.5.6 release delta and its evidence artifacts, using an English Conventional Commit message; record the exact commit SHA for hosted validation. | T011, T012 | - | `git commit` | 🟢 | `[ ]` |
| T014 | Trigger or observe the Build workflow for the T013 commit and capture Quality, Linux, macOS, Windows, Android, and iOS job URLs/statuses individually; do not substitute historical 1.13.0 results. | T013 | - | `.github/workflows/build.yml` | 🟢 | `[ ]` |
| T015 | Complete the evidence matrix from T014: identify each unrun, unavailable, skipped, or failed target by name and leave it unproven; keep publication and live HTTPS/SSH in separate unproven rows unless directly observed. | T014 | - | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[ ]` |

## Phase 5, Polish

| ID | Description | Dependencies | Parallelism | Primary target file | Confidence | Status |
|----|-------------|--------------|-------------|---------------------|------------|--------|
| T016 | Review the release evidence and changelog for scope accuracy: local checks must remain host-scoped, the declaration comparison must remain API-scoped, and no statement may claim unobserved ABI, artifact, publication, or live transport behavior. | T015 | - | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[ ]` |
| T017 | Stop for explicit maintainer authorization that names the verified candidate commit and authorizes the release tag, pub.dev publication, and GitHub release; do not create any tag or publish before this authorization. | T016 | - | `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | 🟢 | `[ ]` |
| T018 | After T017 authorization, create and push annotated tag `v0.5.6` at the authorized candidate commit and record the remote tag reference. | T017 | - | `git tag v0.5.6` | 🟢 | `[ ]` |
| T019 | After the authorized tag is remotely visible, publish version 0.5.6 to pub.dev through the established release procedure and record the publication result separately from the earlier dry-run. | T018 | - | `pub.dev/git2dart 0.5.6` | 🟢 | `[ ]` |
| T020 | Create the GitHub release for the already-published `v0.5.6` tag and link it to the recorded candidate commit and evidence; record any failure without treating tag creation as release publication proof. | T019 | - | `GitHub release v0.5.6` | 🟢 | `[ ]` |

## Execution notes

- Planned source scope is `pubspec.yaml`, `pubspec.lock`, `CHANGELOG.md`, and only an evidence-triggered file under `lib/src/` or `test/`; `lib/git2dart.dart` and `lib/src/platform_specific.dart` are validation-only unless T007 proves a mismatch.
- Generated declarations, native binaries, public API rewrites, and the paused `004-open-defects-remediation` feature are out of scope.
- T017 is a mandatory human authorization boundary. T018--T020 are intentionally blocked until its recorded authorization.

## Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-09-04 | Initial version generated by `/reversa-to-do` | reversa |
