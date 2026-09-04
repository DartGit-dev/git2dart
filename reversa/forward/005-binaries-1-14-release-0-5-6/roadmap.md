# Roadmap: Companion Binaries 1.14 Upgrade and 0.5.6 Release Preparation

> Identifier: `005-binaries-1-14-release-0-5-6`
> Date: `2026-09-04`
> Requirements: `reversa/forward/005-binaries-1-14-release-0-5-6/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Prepare a narrow release delta: move the hosted `git2dart_binaries` constraint
from the adopted 1.13.0 line to the 1.14.0 line, resolve the lock file, and
set the package release identity to 0.5.6. Preserve the public barrel and all
hand-written wrappers unless the resolved declaration contract produces a
compile, analyzer, or targeted platform-initialization failure. The completed
1.13.0-to-1.14.0 public Dart declaration comparison is a compatibility input,
not proof of native ABI, packaged artifacts, runtime behavior, or transport
interoperability. Release readiness will record only observed local and hosted
evidence, separately by target.

## 2. Applied principles

| Principle | Feature relationship | Status |
|-----------|----------------------|--------|
| I. Preserve the Safe Public Dart Facade | Retain `lib/git2dart.dart` exports and public signatures; investigate only if the delivered dependency makes an adapter incompatible. | respects |
| II. Keep Generated Artifacts in the Companion Boundary | Change the hosted dependency contract; do not copy, regenerate, or vendor declarations or binaries. | respects |
| III. Preserve Native ABI and Memory Ownership Safety | Treat the declaration comparison as insufficient for ABI or ownership proof; validate the delivered native boundary before release. | respects |
| IV. Translate Native Failures at One Boundary | Preserve shared error translation; any required adapter change must continue through it. | respects |
| V. Keep Supported Platform Initialization Explicit | Retain and test the exported Android/iOS initialization entry points. | respects |
| VI. Make Validation Evidence Match Its Scope | Separate dependency resolution, local checks, each CI target, publication, and live-network evidence. | respects |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|----|----------|-----------|-----------------------|------------|
| D-01 | Set `git2dart_binaries` to `>=1.14.0 <1.15.0` and resolve exactly 1.14.0 for this release candidate. | The current contract is `>=1.13.0 <1.14.0`; FR-01 requires the explicit next hosted contract. | Retaining 1.13.0; an unbounded range; copying declarations. | 🟢 |
| D-02 | Preserve `lib/git2dart.dart` and hand-written wrappers unless the resolved package causes an evidenced incompatibility. | The completed declaration comparison found no public Dart declaration change. | Proactive wrapper rewrite; assuming ABI or behavior equivalence. | 🟢 |
| D-03 | Release 0.5.6 as a metadata and compatibility release, documented in `CHANGELOG.md`. | FR-03 requires release identity and notes while preserving the public API. | A version-only unrecorded release; claiming a minor API feature. | 🟢 |
| D-04 | Gate release readiness on observed format, analyzer, automated-test, package dry-run, and target-specific CI results. | Local green cannot prove the supported matrix, publication, or live HTTPS/SSH behavior. | One-platform sign-off; treating skipped tests as proof. | 🟢 |
| D-05 | Retain `PlatformSpecific.initialize`, `androidInitialize`, and `iosInitialize`; add or adapt focused tests only if absent or broken by the resolved companion package. | They are the documented consumer-visible startup boundary. | Removing/defering startup preparation; platform claims without execution. | 🟢 |

## 4. Premises

No `[DÚVIDA]` markers were present in `requirements.md`; no premise was adopted.

## 5. Architectural delta

| Component | Legacy source | Change type | Summary |
|-----------|---------------|-------------|---------|
| Companion native package | `reversa/sdd/architecture.md#companion-native-package` and `reversa/sdd/addenda/003-binaries-1-13-migration.md` | altered contract | Adopt the hosted 1.14.0 dependency contract while preserving companion ownership of generated declarations and native binaries. |
| Public package facade | `reversa/sdd/architecture.md#public-package-facade` | validation-only | Preserve exported declarations; verify the supplied public-declaration comparison against the resolved release candidate. |
| Native binding adapters | `reversa/sdd/architecture.md#native-binding-adapters` | validation-only / conditional adaptation | Compile and test against delivered 1.14.0 declarations; modify only an evidenced adapter incompatibility, preserving allocation, ownership, and error rules. |
| Native runtime and platform boundary | `reversa/sdd/code-analysis.md#feature-6-native-runtime-and-platform-boundary` | validation-only / conditional adaptation | Preserve Android certificate setup and iOS eager loading while validating the new companion runtime/package artifacts. |
| Quality and Delivery Architecture | `reversa/sdd/architecture.md#quality-and-delivery-architecture` and addendum 003 | altered delivery evidence | Collect a fresh release-specific local gate and observed hosted matrix evidence; do not carry 1.13.0 results forward as 1.14.0 proof. |

## 6. Data-model delta

- No Git-domain entity, persisted repository format, or application database field changes are planned.
- The dependency constraint and lock resolution are package metadata, not domain-data migration.
- Detail: `reversa/forward/005-binaries-1-14-release-0-5-6/data-delta.md`.

## 7. External-contract delta

| Contract | Type | Detail |
|----------|------|--------|
| `git2dart_binaries` hosted companion dependency | Dart package / generated-FFI delivery contract | `interfaces/git2dart-binaries.md` |

## 8. Migration plan

1. Update release metadata and the hosted companion constraint; run dependency resolution so the lock selects 1.14.0.
2. Re-run the existing public declaration comparison as a release evidence attachment and inspect compiler/analyzer failures for real adapter deltas.
3. Make only evidenced binding, platform-initialization, test, or workflow-documentation changes; do not regenerate or vendor companion artifacts.
4. Run scoped local gates, `dart pub publish --dry-run`, and the observed hosted matrix; record skipped/unavailable targets and live network behavior as unproven.
5. Update release notes, obtain the required release authorization, then tag/publish only through the established release procedure.

## 9. Risks and mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Delivered 1.14.0 native ABI/artifact behavior differs despite stable Dart declarations | high | medium | Compile against the resolved package; run focused native/platform checks and the hosted matrix; block release on evidenced failures. |
| Lock file resolves a version other than 1.14.0 | high | low | Inspect resolved package version after dependency resolution. |
| Android or iOS startup behavior regresses | high | medium | Preserve entry points and collect targeted device/simulator or CI evidence separately. |
| Local Windows checks are misreported as cross-platform proof | high | medium | Publish an evidence matrix with each observed runner and explicit gaps. |
| Dry-run/package publication or live remote transport is inferred rather than observed | medium | medium | Record dry-run, publication, and live HTTPS/SSH as distinct evidence categories. |

## 10. Done criteria

- [ ] `pubspec.yaml` declares `git2dart_binaries >=1.14.0 <1.15.0`; `pubspec.lock` resolves 1.14.0.
- [ ] Package metadata is 0.5.6 and `CHANGELOG.md` records the companion upgrade and stable public API result.
- [ ] Public declaration comparison for 1.13.0 to 1.14.0 is retained as release evidence and has no compatibility failure.
- [ ] The public barrel and Android/iOS initialization entry points remain available; any platform gap is explicit.
- [ ] Formatting, zero-warning analysis, automated tests, and `dart pub publish --dry-run` have recorded outcomes.
- [ ] Hosted Linux, macOS, Windows, Android, and iOS results are individually recorded when observed; unrun targets remain unproven.
- [ ] No statement claims native ABI equivalence, package artifact equivalence, publication, or live HTTPS/SSH interoperability without direct evidence.
- [ ] All actions in `actions.md` are marked `[X]`; any `cross-check.md` contains no CRITICAL or HIGH finding; `regression-watch.md` exists.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-09-04 | Initial version generated by `/reversa-plan` | reversa |
