# Requirements: Analyzer Evidence Closure

> Identifier: `002-analyzer-evidence-closure`
> Date: `2026-08-24`
> Reverse-extraction folder: `reversa/sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / QUESTION

## 1. Executive summary

This feature repairs the eight static-analysis diagnostics emitted by existing
bug-reproduction evidence artifacts. It enables contributors and continuous
integration (CI) maintainers to use those reproductions without changing package
behavior. It unblocks strict Git validation action A-008, while leaving
product-source diagnostics to their separately authorized workflow.

## 2. Context from the legacy system

| Source | Relevant evidence | Confidence |
|-------|-------------------|-------------|
| `reversa/sdd/architecture.md#Quality and Delivery Architecture` | The quality path requires zero-warning static analysis and Flutter tests. | 🟢 |
| `reversa/sdd/inventory.md#Test Surface` | Dart tests share `test/helpers/util.dart` fixtures. | 🟢 |
| `reversa/sdd/code-analysis.md#Feature 2: Git Objects and Object Database` | Object ownership is a documented feature boundary. | 🟢 |
| `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary` | Typed runtime access owns initialization and native invocation. | 🟢 |

Fresh `flutter analyze` on 2026-08-24 reports 21 errors: eight in scope under
evidence artifacts and 13 excluded product-source errors under `lib/`. 🟢

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|------|--------------|
| Bug investigator | Retain runnable documented reproductions. | Runs the ownership or lifecycle reproduction after analysis. |
| CI maintainer | Attribute diagnostics to their actual scope. | Confirms no diagnostic originates in the covered evidence files. |
| Strict-validation implementer | Begin A-008 with a clean evidence baseline. | Uses scoped analyzer proof without altering product code. |

## 4. New or changed business rules

1. **BR-01:** The two E3LU evidence programs must resolve the shared fixture
   through a project-root-correct import so `setupRepo` is defined. 🟢
   - Legacy origin: `reversa/sdd/inventory.md#Test Surface`
   - Type: changed.
2. **BR-02:** The ZC7X lifecycle evidence test must use compile-visible
   native-runtime access for all initialization and shutdown probes. 🟢
   - Legacy origin: `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`
   - Type: changed.
3. **BR-03:** Repairs may change only `reversa/bugs/**/evidence/` artifacts
   and necessary evidence tests; they must not change `lib/`, `test/`,
   dependencies, binaries, OpenSSL configuration, or feature 001. 🟢
   - Legacy origin: `reversa/sdd/architecture.md#Architectural Style`
   - Type: new scope guard.
4. **BR-04:** Closure means zero diagnostics contributed by the eight covered
   evidence errors; it is not a claim that excluded `lib/` diagnostics are fixed. 🟢
   - Legacy origin: `reversa/sdd/architecture.md#Quality and Delivery Architecture`
   - Type: new reporting rule.

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-------------|----------|----------------------|------------|
| FR-01 | Repair both E3LU evidence programs so their fixture import and `setupRepo` symbol resolve. | Must | No URI-resolution or undefined-`setupRepo` diagnostic is reported for either file. | 🟢 |
| FR-02 | Preserve the E3LU reproduction sequence and ownership cleanup. | Must | Each program still creates a fixture repository, obtains a borrowed entry, attempts release, and cleans up owned resources. | 🟢 |
| FR-03 | Repair the ZC7X lifecycle evidence test so all four initialization/shutdown probe references resolve. | Must | No undefined-identifier diagnostic is reported in that test. | 🟢 |
| FR-04 | Preserve the ZC7X count-restoration and repeated-public-call assertions. | Must | The evidence continues checking restored probe counts and documented count transitions. | 🟢 |
| FR-05 | Close the explicit eight-diagnostic baseline: four E3LU and four ZC7X diagnostics. | Must | Post-change analysis attributes none of the eight diagnostics to the three covered evidence files. | 🟢 |
| FR-06 | Report excluded product-source diagnostics separately. | Should | Validation does not call the repository analyzer green while excluded `lib/` errors remain. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or justification | Confidence |
|------|-------------|---------------------------|------------|
| Scope safety | Keep the change set within permitted evidence artifacts and evidence tests. | Prevents analyzer cleanup from changing package behavior. | 🟢 |
| Reproducibility | Retain deterministic local fixture setup. | The project test surface provides shared local fixtures. | 🟢 |
| Observability | Name covered paths and diagnostic categories in validation output. | Makes the eight-error closure auditable. | 🟢 |
| Compatibility | Preserve existing bug records and reproduction intent. | Evidence supports established ownership and lifecycle findings. | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: Resolve E3LU evidence dependencies
  Given static analysis runs from the repository root
  When it examines both E3LU evidence programs
  Then their fixture imports and setupRepo symbols resolve

Scenario: Preserve borrowed-entry evidence
  Given a repaired E3LU evidence program runs
  When it exercises the ownership sequence
  Then it opens a fixture repository, releases the borrowed entry, and cleans up owned resources

Scenario: Resolve ZC7X lifecycle probes
  Given static analysis examines the ZC7X lifecycle evidence test
  When it resolves initialization and shutdown probes
  Then all four formerly undefined probe references resolve

Scenario: Preserve lifecycle count evidence
  Given the repaired ZC7X evidence test runs
  When it probes repeated public calls
  Then every probe restores its count and the count-transition assertions remain

Scenario: Report scoped analyzer health honestly
  Given product-source diagnostics remain outside this feature
  When validation reports the evidence result
  Then it reports zero covered evidence diagnostics
  And it does not report the repository analyzer green
```

## 8. MoSCoW priority

| Item | MoSCoW | Justification |
|------|--------|---------------|
| FR-01 through FR-05 | Must | All eight evidence diagnostics block A-008. |
| FR-06 | Should | Prevents a scoped repair from overstating repository health. |
| Scope guard | Must | Explicit authorization boundary. |

## 9. Clarifications

### Session 2026-08-24

- **Q:** What is the exact scope of analyzer evidence closure?
  **R:** Exactly the eight existing diagnostics in `reversa/bugs/**/evidence`.
- **Q:** How should the 13 diagnostics under `lib/` be handled while the
  incompatible sibling override is active?
  **R:** They remain outside this feature and are not addressed here.
- **Q:** May this feature edit product code, dependencies, binaries, or
  OpenSSL configuration?
  **R:** No. Those areas are explicitly out of scope.
- **Q:** Which runtime procedure and override state govern final validation?
  **R:** Use the proven temporary compatible runtime procedure only when
  needed, then restore the original override.

## 10. Gaps

- The 13 current analyzer diagnostics under `lib/` are outside this feature and
  require a separately authorized product-source workflow.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial version generated by `/reversa-requirements` | reversa |
