# Principles Impact Report

> Project: `git2dart`
> Date: `2026-08-26`
> Source: `.reversa/principles.md`

## Scope

This report reviews the templates named by the active principles. It suggests
changes only; no template was modified by this execution.

## Template review

### `requirements-template.md`

**Current coverage.** The template already captures legacy evidence,
confidence, business rules, functional and non-functional requirements,
acceptance scenarios, and gaps.

**Suggested adjustment.** Add a short `Principles alignment` section after
the legacy context or before business rules. It should list each applicable
active principle, whether the feature respects or conflicts with it, and the
evidence or scope boundary supporting that judgement. This would make the
quality check reproducible without prescribing an implementation.

### `roadmap-template.md`

**Current coverage.** Section 2, `Principles applied`, already provides the
required principle, relationship, and status fields.

**Suggested adjustment.** No structural change is necessary. Guidance may
clarify that each listed principle should cite the relevant requirement,
reverse-extraction artifact, or explicit gap.

### `actions-template.md`

**Current coverage.** The template supports atomic implementation and test
tasks with target files, dependencies, confidence, and status.

**Suggested adjustment.** No new placeholder is necessary. When a principle
creates a validation obligation, the derived verification task should name the
principle-relevant proof boundary in its description.

## Feature 003 applicability summary

| Principle | Feature relationship | Evidence |
|-----------|----------------------|----------|
| I. Preserve the Safe Public Dart Facade | Respects: BR-04 and FR-04 preserve public behavior and call forms. | `requirements.md` sections 4-5 |
| II. Keep Generated Artifacts in the Companion Boundary | Respects: BR-01 and FR-01 prohibit regeneration and vendoring. | `requirements.md` sections 4-5 |
| III. Preserve Native ABI and Memory Ownership Safety | Respects: BR-02, FR-03, and the ABI/memory non-functional requirements require native-width preservation and cleanup. | `requirements.md` sections 4-6 |
| IV. Translate Native Failures at One Boundary | Respects: BR-03, FR-04, and FR-05 require shared error propagation and a deterministic fallback. | `requirements.md` sections 4-5 |
| V. Keep Supported Platform Initialization Explicit | Respects: FR-07 retains Android and iOS startup behavior. | `requirements.md` section 5 |
| VI. Make Validation Evidence Match Its Scope | Respects: BR-05, FR-07, and the documented gaps distinguish local, CI, concurrency, and runtime proof. | `requirements.md` sections 4-6 and 10 |

## Conclusion

Feature `003-binaries-1-13-migration` can now be checked against active
project principles. Rerun `/reversa-quality` to perform the previously blocked
principles-alignment check against the current requirements revision.
