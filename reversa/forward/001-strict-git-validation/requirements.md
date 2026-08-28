# Requirements: Strict Git Validation

> Identifier: `001-strict-git-validation`
> Date: `2026-08-24`
> Reverse-extraction folder: `reversa/sdd/`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP / QUESTION

## 1. Executive summary

This feature makes invalid Git object types and invalid reference names fail at
the package's public Dart boundary. It serves application developers who need
deterministic, actionable input errors without a native call. It replaces the
current partial object-type predicate, which is a defect rather than a
compatibility contract, and establishes equivalent strict validation for every
public reference-name input.

## 2. Context from the legacy system

| Source | Relevant evidence | Confidence |
|-------|-------------------|-------------|
| `reversa/sdd/architecture.md#Architectural Style` | The package has local Dart validation and a separate native-error boundary. | 🟢 |
| `reversa/sdd/domain.md#Object and repository integrity` | Only concrete commit, tree, blob, and annotated tag object types may be written or hashed. | 🟢 |
| `reversa/sdd/domain.md#References and history` | References are direct immutable object identifiers (OIDs) or symbolic reference names, with strict symbolic validation enabled by default. | 🟢 |
| `reversa/sdd/code-analysis.md#Feature 2: Git Objects and Object Database` | The current ODB predicate rejects only selected abstract and delta types before native execution. | 🟢 |
| `reversa/sdd/code-analysis.md#Feature 4: References and Remotes` | Reference operations accept direct and symbolic names and currently surface invalid-name failures from the native layer. | 🟢 |

The approved addenda address root-commit marshalling and status ownership only;
neither supersedes nor changes this validation scope
(`reversa/sdd/addenda/bug-BUG-20260817-T8MW-v001.md#Delta`,
`reversa/sdd/addenda/bug-BUG-20260817-V9TR-v001.md#Delta`). 🟢

## 3. Personas and usage scenarios

| Persona | Goal | Key scenario |
|---------|------|--------------|
| Package consumer | Receive an immediate, precise error for invalid Git input. | Passes an invalid object type or ref name while constructing, looking up, changing, or deleting a reference. |
| Package contributor | Preserve a single documented validation contract. | Adds or reviews an API path that accepts an object type or a reference name. |
| CI maintainer | Detect regression without a native runtime dependency. | Runs focused positive and negative validation tests. |

## 4. New or changed business rules

1. **BR-01:** Object database (ODB) write, hash, and file-hash inputs accept exactly the finite
   set `commit`, `tree`, `blob`, and `tag`; every other enum value is invalid.
   🟢
   - Legacy origin: `reversa/sdd/domain.md#Object and repository integrity`
   - Type: changed; the existing lightweight predicate is defective.
2. **BR-02:** Every public reference-name input is validated locally before its
   operation reaches the native Git layer. 🟢
   - Legacy origin: `reversa/sdd/code-analysis.md#Feature 4: References and Remotes`
   - Type: changed.
3. **BR-03:** A reference name is invalid when it is empty; contains an ASCII
   control character, space, `~`, `^`, `:`, `\\`, `?`, `[`, or `*`; contains
   `..` or `@{`; starts with `/`; ends with `/` or `.`; contains `//`; contains
   a component beginning with `.`; or contains a component ending in `.lock`.
   A top-level name is allowed only when it is uppercase letters and underscores
   and begins and ends with a letter; all other names must use a non-empty
   slash-separated `refs/` namespace. 🟢
   - Legacy origin: `reversa/sdd/code-analysis.md#Feature 4: References and Remotes`
   - Type: changed.
4. **BR-04:** Invalid local input throws `ArgumentError`; native failures that
   occur after successful local validation retain the existing typed native-error
   translation. 🟢
   - Legacy origin: `reversa/sdd/architecture.md#Architectural Style`
   - Type: changed.

## 5. Functional requirements

| ID | Requirement | Priority | Acceptance criterion | Confidence |
|----|-------------|----------|----------------------|------------|
| FR-01 | The ODB type validator shall accept only commit, tree, blob, and tag for each public ODB write/hash entry point. | Must | Each accepted type proceeds past local validation; every other enum value throws `ArgumentError`. | 🟢 |
| FR-02 | The ODB type validator shall not treat a partially enumerated deny-list as sufficient validation. | Must | A test iterating every object-type enum value proves the accepted set is exactly four values. | 🟢 |
| FR-03 | Every public reference operation accepting a reference name shall validate it locally, including creation, matching creation, lookup, removal, rename, direct-target update, and symbolic-target update. | Must | Each named input position rejects every BR-03 invalid category with `ArgumentError`. | 🟢 |
| FR-04 | The reference validator shall accept representative valid top-level and namespaced reference names. | Must | `HEAD`, `ORIG_HEAD`, `refs/heads/main`, `refs/tags/v1.0`, and `refs/remotes/origin/main` pass local validation. | 🟢 |
| FR-05 | A locally rejected type or reference name shall not invoke the corresponding native operation. | Must | Focused tests prove no native call is made for each invalid-input class. | 🟡 |
| FR-06 | Public documentation for affected inputs shall state the locally enforced failure behavior. | Should | A reader can identify `ArgumentError` and the supported object-type/ref-name contract from public API documentation. | 🟢 |

## 6. Non-functional requirements

| Type | Requirement | Evidence or rationale | Confidence |
|------|-------------|-----------------------|------------|
| Performance | Validation is deterministic, in-process, and requires no repository access or native call for invalid input. | Local validation is the existing architectural error boundary. | 🟢 |
| Reliability | The same input has the same validity result at every covered public entry point. | Prevents inconsistent validation across the typed wrapper surface. | 🟢 |
| Security | Invalid Git syntax is rejected before it can reach native parsing. | Narrows the native input surface while preserving native errors for valid syntax. | 🟢 |
| Compatibility | This feature may break callers that relied on invalid input reaching the native layer; that behavior is explicitly classified as defective. | User-authorized scope; no compatibility mode is required. | 🟢 |
| Testability | Focused tests must be self-contained and not require network access. | The standard suite is not proof of live network behavior. | 🟢 |

## 7. Acceptance criteria

```gherkin
Scenario: Hash data with every supported concrete object type
  Given data to hash and one of commit, tree, blob, or tag
  When the consumer requests an ODB hash
  Then local validation accepts the type
  And the native operation remains eligible to run

Scenario: Reject a non-concrete object type
  Given any object-type enum value other than commit, tree, blob, or tag
  When the consumer requests an ODB write, hash, or file hash
  Then an ArgumentError is thrown
  And no corresponding native operation is invoked

Scenario: Accept a valid reference name
  Given the reference name "refs/heads/main"
  When the consumer supplies it to a covered reference operation
  Then local validation accepts the name

Scenario: Reject Git-invalid reference syntax before native execution
  Given a covered reference-name input containing "..", "@{", a prohibited character, an empty component, a leading-dot component, or a ".lock" component suffix
  When the consumer invokes the reference operation
  Then an ArgumentError is thrown
  And no corresponding native operation is invoked

Scenario: Document the local validation contract
  Given a consumer reads the affected public API documentation
  When the consumer checks object-type or reference-name input failures
  Then the documentation identifies the accepted contract and ArgumentError behavior
```

## 8. MoSCoW priority

| Item | MoSCoW | Rationale |
|------|--------|-----------|
| FR-01 and FR-02 | Must | Restores the documented finite object-type contract. |
| FR-03 through FR-05 | Must | Ensures invalid reference syntax fails before the native boundary. |
| FR-06 | Should | Makes the revised contract discoverable to consumers. |
| Self-contained focused tests | Must | Provides regression evidence without network dependence. |

## 9. Clarifications

> No clarification session has been recorded. No pending clarification marker exists.

## 10. Gaps

- None identified for the authorized scope. Dynamic cross-platform and live-network
  validation remain outside this requirements feature.

## 11. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial version generated by `/reversa-requirements` | reversa |
