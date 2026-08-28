# Actions: Companion Binaries 1.13 Migration

> Identifier: `003-binaries-1-13-migration`
> Date: `2026-08-26`
> Roadmap: `reversa/forward/003-binaries-1-13-migration/roadmap.md`

## Summary

| Metric | Value |
|--------|-------|
| Total actions | 27 |
| Parallelizable (`[//]`) | 12 |
| Longest dependency chain | 11 |

## Phase 1, Preparation

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|-------------|--------|
| T001 | Verify that `pubspec.yaml`, `pubspec.lock`, and the API-diff baseline already adopt hosted `git2dart_binaries` 1.13.0. Preserve these artifacts as migration inputs: do not regenerate declarations, change binaries, add an override, or claim an unavailable 1.12.2-to-1.13.0 comparison. | - | - | `pubspec.yaml`, `pubspec.lock`, `tool/api_diff/git2dart_binaries.baseline` | 🟢 | [X] |
| T002 | Inventory every hand-written use of removed package-level runtime access and every feature-owned obsolete direct error construction. Record the exact owners: `libgit2.dart`; `error_helper.dart`; `bindings/commit.dart`; `bindings/diff.dart`; and both callback paths in `bindings/remote_callbacks.dart`. | T001 | - | `lib/src/` | 🟢 | [X] |

## Phase 2, Tests

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|-------------|--------|
| [//] T003 | Add table-driven global-option coverage that distinguishes the four `Pointer<Size>` getter groups—mmap window size, mmap mapped limit, mmap file limit, and pack maximum objects—from the two cached-memory `Pointer<IntPtr>` outputs. Preserve public `int` setter/getter forms, restore every changed process-global option in teardown, and conditionally prove an accepted 64-bit `4_294_967_296` round-trip without claiming concurrency safety. | T002 | `[//]` | `test/libgit2_test.dart` | 🟢 | [X] |
| [//] T004 | Extend negative-result tests to assert the delivered-error branch and authorized `StateError` fallback, then statically reject obsolete direct error construction in all four named source files, including both remote-callback paths. Retain the existing guard that each fallible global-option call checks its status. | T002 | `[//]` | `test/libgit2_option_error_test.dart` | 🟢 | [X] |
| [//] T005 | Make platform-startup coverage explicitly preserve Android certificate initialization and iOS eager native-symbol loading under the adopted 1.13 runtime, while retaining safe non-target-platform host execution. | T001 | `[//]` | `test/platform_specific_test.dart` | 🟢 | [X] |

## Phase 3, Core

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|-------------|--------|
| [//] T006 | Migrate `Libgit2` to the delivered runtime object's `bindings` and `options` surface. Use `Size` only for mmap window size, mmap mapped limit, mmap file limit, and pack maximum objects; retain `IntPtr` for both cached-memory outputs; release all temporary pointers on successful and failing native calls; and retain public Dart APIs. | T003 | `[//]` | `lib/src/libgit2.dart` | 🟢 | [X] |
| [//] T007 | Replace the obsolete direct error construction in the shared helper with delivered last-error retrieval and the authorized stable `StateError` fallback when no native detail exists. Keep `checkErrorAndThrow` as the common negative-result entry point. | T004 | `[//]` | `lib/src/helpers/error_helper.dart` | 🟢 | [X] |
| [//] T008 | Replace the obsolete direct error construction owned by the commit binding with the delivered-error or authorized-`StateError` contract, without changing its public wrapper behavior or native ownership rules. | T004 | `[//]` | `lib/src/bindings/commit.dart` | 🟢 | [X] |
| [//] T009 | Replace the obsolete direct error construction owned by the diff binding with the delivered-error or authorized-`StateError` contract, preserving the existing diff API and cleanup behavior. | T004 | `[//]` | `lib/src/bindings/diff.dart` | 🟢 | [X] |
| [//] T010 | Replace the obsolete direct error construction in each of the two remote-callback paths with the delivered-error or authorized-`StateError` contract. Preserve callback lifetime, return-code, and exception-propagation semantics. | T004 | `[//]` | `lib/src/bindings/remote_callbacks.dart` | 🟢 | [X] |
| [//] T011 | Reconcile platform initialization with the delivered 1.13 runtime only where required, preserving Android certificate setup, iOS eager symbol loading, and the current public initialization methods. | T005 | `[//]` | `lib/src/platform_specific.dart` | 🟢 | [X] |

## Phase 4, Integration

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|-------------|--------|
| T012 | Execute the focused global-option, error-contract, and platform-startup suites against the adopted 1.13.0 resolution. Confirm the exact `Size`/`IntPtr` split, conditional 64-bit round-trip where accepted, both error branches, host-safe platform initialization, and restored process-global options before the full local gate. | T006, T007, T011 | - | `test/libgit2_test.dart`, `test/libgit2_option_error_test.dart`, `test/platform_specific_test.dart` | 🟢 | [X] |
| T013 | Execute focused commit, diff, and remote regression suites after the three binding error migrations. Confirm each named binding remains reachable and that neither remote callback path regresses its exception propagation. | T008, T009, T010 | - | `test/commit_test.dart`, `test/diff_test.dart`, `test/remote_test.dart` | 🟢 | [X] |
| T022 | Run a scoped inventory for obsolete error-constructor or obsolete error-contract wording only in consumer-facing `///` comments under `lib/`, `doc/types/`, and the README/API-reference sources. Classify each hit as affected or unrelated; do not widen the feature to general native-error documentation cleanup. | T002 | - | `lib/**/*.dart`, `doc/types/**/*.md`, `README.md`, `doc/README.md`, `doc/git2dart_binaries_api_updates.md` | 🟢 | [X] |
| [//] T023 | Update only the affected consumer-facing public Dart `///` comments identified by T022 so they describe the delivered native error and authorized `StateError` fallback. Do not modify unrelated or internal binding documentation. | T007, T008, T009, T010, T022 | `[//]` | `lib/**/*.dart` (T022 matches only) | 🟢 | [X] |
| [//] T024 | Update only matched `doc/types/` pages that promise obsolete constructor semantics, aligning them with the delivered-error plus authorized-`StateError` contract. Leave unmatched type documentation unchanged. | T022 | `[//]` | `doc/types/**/*.md` (T022 matches only) | 🟢 | [X] |
| [//] T025 | Update only README or API-reference passages matched by T022 that promise obsolete constructor semantics, aligning them with the delivered-error plus authorized-`StateError` contract. Leave unrelated README and API reference wording unchanged. | T022 | `[//]` | `README.md`, `doc/README.md`, `doc/git2dart_binaries_api_updates.md` (T022 matches only) | 🟢 | [X] |
| T026 | Repeat the same scoped documentation search after T023-T025. Require zero remaining obsolete error-constructor or obsolete error-contract promises in the affected public Dart comments, `doc/types/`, README, and API-reference matches. | T023, T024, T025 | - | `lib/**/*.dart`, `doc/types/**/*.md`, `README.md`, `doc/README.md`, `doc/git2dart_binaries_api_updates.md` | 🟢 | [X] |
| T027 | Generate API documentation with the exact `dart doc` command. Record the command and outcome; treat generation failure as a completion blocker. | T026 | - | `doc/api/` | 🟢 | [X] |
| T014 | Complete the local delivery gate after both focused branches and the scoped documentation check: resolve dependencies, verify formatting for all planned Dart files, require zero-warning analysis, run the full Flutter suite, and confirm the diff contains no generated declarations, binaries, overrides, or unrelated files. | T012, T013, T027 | - | `pubspec.lock` | 🟢 | [X] |
| T015 | Obtain a green Linux job from the existing CI workflow after the local delivery gate, using the adopted hosted 1.13.0 resolution. | T014 | - | `.github/workflows/publish.yml` | 🟢 | [X] |
| T016 | Obtain a green macOS job from the existing CI workflow after the local delivery gate, using the adopted hosted 1.13.0 resolution. | T014 | - | `.github/workflows/publish.yml` | 🟢 | [X] |
| T017 | Obtain a green Windows job from the existing CI workflow after the local delivery gate, using the adopted hosted 1.13.0 resolution. | T014 | - | `.github/workflows/publish.yml` | 🟢 | [X] |
| T018 | Obtain a green Android job from the existing CI workflow after the local delivery gate, proving Android certificate initialization with the adopted hosted 1.13.0 resolution. | T014 | - | `.github/workflows/publish.yml` | 🟢 | [X] |
| T019 | Obtain a green iOS job from the existing CI workflow after the local delivery gate, proving eager native-symbol loading with the adopted hosted 1.13.0 resolution. | T014 | - | `.github/workflows/publish.yml` | 🟢 | [X] |
| T020 | Reconcile the CI evidence only after Linux, macOS, Windows, Android, and iOS jobs are all green. Treat missing, skipped, or failed platform evidence as incomplete migration proof rather than substituting local Windows results. | T015, T016, T017, T018, T019 | - | `.github/workflows/publish.yml` | 🟢 | [X] |

## Phase 5, Polish

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
|----|-------------|--------------|-------------|-------------|-------------|--------|
| T021 | Reconfirm the adopted 1.13.0 API-diff baseline after complete CI proof. Preserve it without regeneration or rewriting comparison history, and record that the migration consumed only the reviewed hand-written runtime boundary. | T020 | - | `tool/api_diff/git2dart_binaries.baseline` | 🟢 | [X] |

## Execution Notes

This regeneration supersedes the prior task definitions after the approved roadmap refresh. It intentionally resets every task status to `[ ]`, as required for a newly generated action plan. The immutable historic execution evidence remains in `progress.jsonl`; it records prior completion claims for T001-T014 and T022-T027, but does not establish that those claims satisfy these refreshed definitions.

## Change History

| Date | Change | Author |
|------|--------|--------|
| 2026-08-26 | Initial action plan generated by `/reversa-to-do`. | reversa |
| 2026-08-26 | Atomically regenerated from the refreshed approved roadmap; retained stable IDs and preserved historic progress externally. | reversa |
