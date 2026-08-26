# Requirements: Companion Binaries 1.13 Migration

> Identifier: `003-binaries-1-13-migration`
> Date: `2026-08-26`
> Reverse-extraction folder: `reversa/sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / QUESTION

## 1. Executive summary

This feature completes the compatibility migration to the delivered 1.13 line
of the companion native package. It serves package consumers and maintainers by
keeping the public Dart Git application programming interface (API) stable while
aligning the internal native runtime boundary, native-width option values, and native-error propagation with
the delivered declarations. It removes dependence on obsolete companion-package
entry points without regenerating declarations in this repository.

## 2. Context from the legacy system

| Source | Relevant evidence | Confidence |
|-------|-------------------|-------------|
| `reversa/sdd/architecture.md#Companion native package` | Generated declarations and platform binaries are supplied by the companion package; upgrades require coordinated native-interface and wrapper review. | 🟢 |
| `reversa/sdd/architecture.md#Quality and Delivery Architecture` | The quality path requires formatting, zero-warning static analysis, and Flutter tests across supported platforms. | 🟢 |
| `reversa/sdd/domain.md#Memory and ABI safety` | Binding adapters own raw calls and temporary allocation; negative native results are translated at a shared error boundary. | 🟢 |
| `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary` | Global options, initialization, native allocation, and error conversion are one architectural boundary. | 🟢 |
| `reversa/sdd/inventory.md#Technology Profile` | The project owns high-level wrappers and hand-written adapters, while declarations come from the companion package. | 🟢 |

The current delivery input is the already-applied hosted 1.13.0 resolution and
baseline state. The migration predecessor is the repository's 1.12.2 baseline;
the requirements do not claim that a new 1.12.2-to-1.13.0 comparison has been
performed. Existing declaration evidence reports five native-width
output-signature changes, removal of two former global binding fields, and
removal of the former native-error constructor. 🟢

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|------|--------------|
| Package consumer | Keep using the public Git API after the companion package is upgraded. | Reads global native options and handles a failed Git operation without source changes caused by internal foreign-function interface (FFI) migration. |
| Binding contributor | Preserve native-width value and ownership handling. | Updates an adapter after generated declarations replace fixed-width outputs with native-width outputs. |
| Continuous-integration (CI) maintainer | Detect migration regressions across the supported package matrix. | Runs formatting, static analysis, and tests against the hosted 1.13.0 dependency. |

## 4. New or changed business rules

1. **BR-01:** The package shall resolve the companion native package from its
   hosted 1.13.x release line; this repository shall not regenerate or vendor
   its generated declarations. 🟢
   - Legacy origin: `reversa/sdd/domain.md#Memory and ABI safety`
   - Type: changed.
2. **BR-02:** Every global-option value whose native declaration is
   platform-width shall retain its full native value at the binding boundary
   before becoming a Dart integer. The four `size_t` option groups use
   `Pointer<Size>`; both cached-memory outputs use `Pointer<IntPtr>`. 🟢
   - Legacy origin: `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`
   - Type: changed.
3. **BR-03:** A negative native result shall continue to surface the current
   native error when it is available; if no native error is available, the
   package shall throw the authorized deterministic `StateError` fallback. It
   shall not attempt to reconstruct a removed companion-package error
   constructor. This is an explicit exception-type change from the confirmed
   legacy rule. 🟢
   - Legacy origin: `reversa/sdd/domain.md#Memory and ABI safety`
   - Type: changed.
4. **BR-04:** Public Git behavior, public method signatures, and explicit
   ownership/finalizer contracts remain unchanged by this dependency migration.
   🟢
   - Legacy origin: `reversa/sdd/architecture.md#Public package facade`
   - Type: unchanged compatibility guard.

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-------------|----------|----------------------|------------|
| FR-01 | The package shall declare and resolve the hosted companion dependency in the 1.13.x line. | Must | Dependency resolution selects 1.13.0 from the hosted registry and no path override or generated-declaration replacement is introduced. | 🟢 |
| FR-02 | The internal native-call boundary shall use the delivered runtime access surface instead of removed global binding fields. | Must | Static analysis finds no production reference to either removed global field, and initialization, option access, and native calls remain reachable through the supported runtime surface. | 🟢 |
| FR-03 | The public getters for memory-mapped (mmap) window size, mmap mapped limit, mmap file limit, cache usage, and pack-object limit shall preserve native-width results. The four `size_t` groups use `Pointer<Size>`; cached-memory current/allowed outputs use `Pointer<IntPtr>`. | Must | Each affected getter compiles against the delivered declaration; its observed Dart integer equals the native result without fixed-width truncation. | 🟢 |
| FR-04 | The public setters paired with the affected option getters shall retain their existing Dart integer API and propagate native failures through the shared error boundary. | Must | Existing setter call forms compile unchanged; a native rejection produces the current native error when available. | 🟢 |
| FR-05 | Shared native-error handling shall use the delivered error retrieval contract and retain the authorized deterministic `StateError` fallback when native error details are absent. All obsolete direct `LibGit2Error(...)` construction paths shall be migrated, including `error_helper.dart`, `commit.dart`, `diff.dart`, and `remote_callbacks.dart`. | Must | A negative native result with error data throws that error; a negative result without error data throws `StateError`; no production code constructs the removed error type at any listed call site. | 🟢 |
| FR-06 | Affected public Dart API comments/docs and the README/API reference, wherever obsolete error wording exists, shall no longer promise an obsolete companion-package error type. | Should | A scoped static search finds no obsolete error-contract wording in those documentation sources, and `dart doc` or an equivalent documentation check succeeds. | 🟢 |
| FR-07 | The migration shall preserve supported platform initialization behavior, including Android certificate setup and iOS native-symbol loading. | Must | Full CI proof covers every project-supported desktop and mobile platform using the hosted 1.13.0 dependency; local Windows success alone is insufficient. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or justification | Confidence |
|------|-------------|---------------------------|------------|
| Application binary interface (ABI) safety | Native-width option outputs must not be represented through a narrower fixed-width pointer. | The native boundary is responsible for pointer ownership and ABI interaction. | 🟢 |
| Memory safety | Temporary output allocations must be released on both successful and failing native calls. | Short-lived native inputs and outputs use scoped allocation. | 🟢 |
| Compatibility | No public Git API signature or intended Git behavior changes solely because of this migration. | The public facade isolates consumers from generated declarations. | 🟢 |
| Reliability | Every negative native return has one shared, deterministic error path. | The legacy model centralizes error translation. | 🟢 |
| Delivery | Formatting, zero-warning analysis, and the project test suite must pass before migration completion. | `reversa/sdd/architecture.md#Quality and Delivery Architecture` | 🟢 |
| Platform coverage | Validation must include the project-supported desktop and mobile targets in CI; local Windows success alone is insufficient release proof. | The declared CI matrix covers desktop plus Android and iOS. | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: Resolve the delivered hosted companion package
  Given the package dependency configuration targets the 1.13 release line
  When dependencies are resolved
  Then the hosted 1.13.0 companion package is selected
  And no generated declaration is regenerated in this repository

Scenario: Read a native-width global option
  Given the native Git runtime reports a value for an affected global option
  When a consumer reads the corresponding public getter
  Then the returned Dart integer equals the full native value
  And no fixed-width truncation occurs

Scenario: Propagate a native error
  Given an internal native call returns a negative result with native error data
  When the public operation handles that result
  Then the current native error is thrown
  And no obsolete error object is constructed

Scenario: Handle a missing native error deterministically
  Given an internal native call returns a negative result without native error data
  When the public operation handles that result
  Then it throws a Dart state failure with an explanatory message

Scenario: Preserve a consumer-facing global option API
  Given existing consumer code sets or reads an affected global option
  When it is compiled against the migration
  Then its public Dart call form remains valid
  And a rejected native value follows the shared error behavior

Scenario: Retain platform startup support
  Given an Android or iOS consumer initializes platform support
  When it accesses the native Git API after initialization
  Then the supported platform initialization path remains available
```

## 8. MoSCoW priority

| Item | MoSCoW | Justification |
|------|--------|---------------|
| FR-01 through FR-05 | Must | They restore compilation and ABI-safe operation against the delivered dependency. |
| FR-07 | Must | Platform initialization is part of the package support contract. |
| FR-06 | Should | Accurate documentation prevents consumers from catching or expecting a removed error type. |
| Full CI platform proof | Must | It is a mandatory completion gate and must run through the existing supported-platform CI matrix. |

## 9. Clarifications

### Session 2026-08-26

- **Q:** What exception contract applies when a negative native result has no native error detail? **R:** Authorize the deterministic `StateError` fallback; this explicitly changes the confirmed legacy exception type.
- **Q:** Which pointer types apply to the migrated option getter groups? **R:** Use `Pointer<Size>` for the four `size_t` groups and `Pointer<IntPtr>` for both cached-memory outputs.
- **Q:** Which obsolete error-construction sites are in migration scope? **R:** Include `lib/src/helpers/error_helper.dart`, `lib/src/bindings/commit.dart`, `lib/src/bindings/diff.dart`, and both relevant paths in `lib/src/bindings/remote_callbacks.dart`.
- **Q:** How should the already-applied 1.13.0 dependency and baseline state be handled? **R:** Adopt it as pre-existing migration work; use the repository's 1.12.2 baseline as the predecessor constraint, without claiming that an unavailable 1.12.2-to-1.13.0 comparison has already been performed.
- **Q:** What CI evidence is mandatory? **R:** Full supported-platform CI proof is a required completion gate.
- **Q:** Which public documentation sources and verification own FR-06? **R:** Update affected public Dart API comments/docs and the README/API reference wherever obsolete error wording exists; verify with a scoped static search plus `dart doc` or an equivalent documentation check.

## 10. Gaps

- The API/declaration evidence covers exported Dart declarations; it does not
  itself prove native ABI compatibility, binary packaging, or live remote
  behavior. Those risks require the stated tests and full CI platform
  validation.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-26 | Initial version generated by `/reversa-requirements` | reversa |
