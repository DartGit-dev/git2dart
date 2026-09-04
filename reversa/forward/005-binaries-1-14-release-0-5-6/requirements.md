# Requirements: Companion Binaries 1.14 Upgrade and 0.5.6 Release Preparation

> Identifier: `005-binaries-1-14-release-0-5-6`
> Date: `2026-09-04`
> Reverse-engineering output folder: `reversa/sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / QUESTION

## 1. Executive summary

Prepare git2dart version 0.5.6 around an explicit upgrade of the hosted
git2dart_binaries dependency from 1.13.0 to 1.14.0. The release must retain
the existing public Dart API and the companion boundary for generated native
declarations and binaries. It must produce scoped validation evidence for the
release package without claiming unsupported platform or live-network results.

## 2. Context from the legacy system

| Source | Relevant excerpt | Confidence |
|--------|------------------|------------|
| `reversa/sdd/architecture.md#Companion native package` | The companion package supplies generated FFI declarations and platform binaries; a deliberate upgrade is the intended control for declaration and ABI drift. | 🟢 |
| `reversa/sdd/architecture.md#Quality and Delivery Architecture` | Formatting, zero-warning static analysis, Flutter tests, and the hosted platform matrix are the established delivery boundary; default tests do not prove live remote interoperability. | 🟢 |
| `reversa/sdd/inventory.md#Technology Profile` | The repository is a Dart/Flutter package with package metadata, a lock file, and a hosted publication workflow. | 🟢 |
| `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary` | The hand-written boundary depends on ABI compatibility with companion declarations and keeps platform initialization, error translation, and ownership safety within the library. | 🟢 |
| `reversa/sdd/addenda/003-binaries-1-13-migration.md#Deployment status 2026-08-27` | The 1.13.0 migration was completed and deployed on user confirmation; its generated-declaration and companion ownership boundaries remain applicable. | 🟢 |

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|------|--------------|
| Package maintainer | Publish the next compatible package release | The maintainer prepares version 0.5.6 after selecting companion version 1.14.0. |
| Dart or Flutter consumer | Upgrade without source changes | The consumer resolves 0.5.6 and continues using the public Dart API unchanged. |
| Release automation operator | Assess release readiness from scoped evidence | The operator distinguishes local checks, hosted platform checks, and any unproven live behavior. |

## 4. New or changed business rules

1. **BR-01:** The release scope upgrades the hosted companion dependency from 1.13.0 to 1.14.0 while retaining companion ownership of generated declarations and native artifacts. 🟢
   - Legacy origin: `reversa/sdd/architecture.md#Companion native package`
   - Type: changed
2. **BR-02:** Version 0.5.6 must preserve the existing public Dart API; the completed 1.13.0-to-1.14.0 declaration comparison reported no public Dart declaration changes. 🟢
   - Legacy origin: `reversa/sdd/architecture.md#Public package facade`
   - Type: changed
3. **BR-03:** Release-readiness evidence must state its exact scope; local or standard automated checks must not be presented as proof of live HTTPS or SSH interoperability. 🟢
   - Legacy origin: `reversa/sdd/architecture.md#Quality and Delivery Architecture`
   - Type: changed
4. **BR-04:** Supported mobile initialization paths remain available as consumer-visible behavior throughout the dependency upgrade. 🟢
   - Legacy origin: `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`
   - Type: changed

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-------------|----------|----------------------|-------------|
| FR-01 | The release candidate shall declare compatibility with git2dart_binaries 1.14.0 rather than 1.13.0. | Must | Dependency resolution selects 1.14.0 for the release candidate and no generated declarations are copied into this repository. | 🟢 |
| FR-02 | The release candidate shall retain all public Dart declarations available before the companion upgrade. | Must | A comparison from 1.13.0 to 1.14.0 reports no removed or changed public Dart declaration, and public API verification completes without a compatibility failure. | 🟢 |
| FR-03 | The release candidate shall identify itself as git2dart version 0.5.6 and describe the dependency upgrade in release notes. | Must | Release metadata shows 0.5.6 and release notes name the 1.14.0 companion upgrade and the public-API compatibility outcome. | 🟢 |
| FR-04 | The release candidate shall retain documented Android and iOS initialization behavior before Git API use. | Must | Targeted validation confirms the initialization entry points remain available, or records an explicit platform-specific validation gap. | 🟢 |
| FR-05 | The release candidate shall provide scoped release validation evidence. | Must | Evidence separately records formatting, static analysis, automated tests, and each hosted platform result that was actually observed; it labels unrun targets and live-network behavior as unproven. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or justification | Confidence |
|------|-------------|---------------------------|------------|
| Compatibility | Existing consumer source that uses the public Dart API shall not require source changes solely because of this companion upgrade. | `reversa/sdd/architecture.md#Public package facade`; completed declaration comparison supplied for 1.13.0 to 1.14.0. | 🟢 |
| Native safety | The upgrade shall preserve the confinement of raw native calls and ownership handling to binding adapters. | `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`. | 🟢 |
| Platform support | Validation shall cover each supported platform only to the extent evidence is actually obtained; Android and iOS startup behavior remains in scope. | `reversa/sdd/inventory.md#Executive Summary`; `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`. | 🟢 |
| Quality | The release candidate shall meet the established formatting, zero-warning analysis, and automated-test delivery gates before it is considered ready. | `reversa/sdd/architecture.md#Quality and Delivery Architecture`. | 🟢 |
| Observability | Release documentation shall distinguish observed validation results from unobserved external behavior. | `.reversa/principles.md#VI. Make Validation Evidence Match Its Scope`. | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: Prepare a compatible 0.5.6 release candidate
  Given git2dart currently uses the 1.13.0 companion contract
  When the maintainer prepares release candidate 0.5.6 for companion version 1.14.0
  Then dependency resolution selects 1.14.0
  And the public Dart API comparison reports no declaration change
  And release metadata identifies version 0.5.6

Scenario: Preserve supported platform startup behavior
  Given a supported Android or iOS consumer application
  When it invokes the documented initialization path before Git API use
  Then the path remains available for validation
  And any platform target without observed validation evidence is reported as unproven

Scenario: Do not overstate release evidence
  Given only local checks or a partial hosted platform matrix have been observed
  When release readiness is reported
  Then the report separates the observed checks from unrun platforms
  And it does not claim live HTTPS or SSH interoperability without direct evidence
```

## 8. MoSCoW priority

| Item | MoSCoW | Justification |
|------|--------|---------------|
| FR-01 | Must | The explicit companion contract is the feature objective. |
| FR-02 | Must | Public API compatibility is a durable package promise. |
| FR-03 | Must | The requested git2dart 0.5.6 release cannot be prepared without release identity and notes. |
| FR-04 | Must | Explicit supported-platform initialization is a project principle. |
| FR-05 | Must | Release decisions require evidence whose boundary is clear. |

## 9. Clarifications

> No clarification session has been recorded. Run `/reversa-clarify` if a question becomes pending.

## 10. Gaps

- No initial gaps are pending. The 1.13.0-to-1.14.0 public Dart declaration comparison was completed before this requirements document; platform and live-network claims remain constrained by the evidence collected during implementation.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-09-04 | Initial version generated by `/reversa-requirements` | reversa |
