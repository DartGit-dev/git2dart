# Roadmap: Strict Git Validation

> Identifier: `001-strict-git-validation`
> Date: `2026-08-24`
> Requirements: `reversa/forward/001-strict-git-validation/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Change only the local Dart validation boundary described by
`reversa/sdd/architecture.md#Architectural Style`. Replace ODB's partial
deny-list with an allow-list of the four concrete Git object types, then add a
single private reference-name validator inside the existing `Reference` wrapper.
Call it before every public `Reference` entry point that accepts a ref name,
including symbolic targets. Keep valid-input calls and all native error
translation unchanged. Extend the existing focused ODB and Reference tests; do
not change bindings, generated declarations, libgit2 configuration, or any
external contract. 🟢

## 2. Applied principles

`.reversa/principles.md` is absent, so no project-specific principle can be
evaluated. The feature otherwise follows the extracted local-validation and
native-error boundary.

| Principle | Feature relationship | Status |
|-----------|----------------------|--------|
| No project principle artifact exists | Record absence; do not invent or weaken a principle. | n/a |
| Local Dart validation plus typed native errors (`reversa/sdd/architecture.md#Architectural Style`) | Rejects invalid input before FFI while retaining the existing native path for valid input. | respects 🟢 |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|----|----------|-----------|-----------------------|------------|
| D-01 | Make `Odb._checkWritableObjectType` an explicit allow-list: `commit`, `tree`, `blob`, `tag`. | `GitObject` has seven values; a finite allow-list cannot accidentally permit a future abstract/delta enum member. | Preserve the current deny-list; defer entirely to libgit2. | 🟢 |
| D-02 | Keep reference validation private to `lib/src/reference.dart` and invoke it at each affected public parameter position. | One source of truth covers `create`, `createMatching`, `lookup`, `delete`, `remove`, `rename`, `setTarget`, `ensureLog`, and `nameToId` without adding public API. | Duplicate checks per method; a new public validator; native-only validation. | 🟢 |
| D-03 | Implement exactly the requirements' Git-invalid rules and its explicit top-level exception (`HEAD`-style uppercase underscore names); otherwise require a non-empty `refs/` hierarchy. | Matches the approved requirements and existing `Reference.create` documentation while retaining deterministic Dart errors. | Normalize invalid names; accept arbitrary one-level names; broaden to refspec/glob syntax. | 🟢 |
| D-04 | Test invalid input at the public boundary with `ArgumentError`, valid representatives, and a deliberately unusable native receiver where possible. | This proves validation precedes the native call without modifying bindings or introducing test-only FFI seams. | Mock generated bindings; integration-only tests; assert native error types. | 🟡 |
| D-05 | Update only existing public Dart doc comments for affected ODB and Reference inputs. | FR-06 needs discoverable behavior; this avoids unrelated API or documentation churn. | Changelog/release work; package-wide documentation rewrite. | 🟢 |

## 4. Assumptions

None. `requirements.md` has no `[DÚVIDA]` markers.

## 5. Architectural delta

| Component | Legacy source | Change type | Summary |
|-----------|---------------|-------------|---------|
| Git objects and object database | `reversa/sdd/architecture.md#Feature wrappers`; `reversa/sdd/code-analysis.md#Feature 2: Git Objects and Object Database` | changed rule | `Odb` admits only concrete writable/hashable object types before the binding call. |
| References and remotes | `reversa/sdd/architecture.md#Feature wrappers`; `reversa/sdd/code-analysis.md#Feature 4: References and Remotes` | changed rule | `Reference` validates caller-supplied ref names and symbolic targets before lookup/create/update/remove bindings. |
| Native binding adapters | `reversa/sdd/architecture.md#Native binding adapters` | unchanged boundary | No FFI declaration, marshalling, native option, or `git2dart_binaries` change. |

## 6. Data-model delta

- No persistent-model, schema, file-format, index, or migration change.
- The only new in-memory concept is a deterministic validity predicate for an existing `String` input.
- Detail: `reversa/forward/001-strict-git-validation/data-delta.md`.

## 7. External-contract delta

No HTTP, queue, gRPC, GraphQL, file, or other external-system contract changes.
The public Dart behavior is documented in the existing wrapper doc comments;
therefore `interfaces/` is intentionally omitted.

## 8. Minimal implementation and test plan

| File | Exact delta | Focused verification |
|------|-------------|----------------------|
| `lib/src/odb.dart` | Replace the partial `_checkWritableObjectType` deny-list with the four-value allow-list; tighten docs for `write`, `writeDirect`, `hash`, and `hashFile`. | `test/odb_test.dart` iterates `GitObject.values`, accepts exactly four, and rejects the remaining three for all four entry points. |
| `lib/src/reference.dart` | Add one private validator; apply it before every ref-name position in `create`, `createMatching`, `lookup`, `delete`, `remove`, `rename`, `setTarget`, `ensureLog`, and `nameToId`; update public docs to promise `ArgumentError`. | `test/reference_test.dart` covers valid top-level/namespaced names, each invalid category, every listed input position, and symbolic target/current-target positions. |
| `test/odb_test.dart` | Replace narrow `GitObject.any` coverage with finite-set table/iteration coverage and invalid-before-native checks. | `flutter test -j 1 test/odb_test.dart`. |
| `test/reference_test.dart` | Convert legacy invalid-name expectations from `LibGit2Error` to `ArgumentError`; add table-driven syntax cases and boundary-order checks. | `flutter test -j 1 test/reference_test.dart`. |

No other production/test files are planned. In particular, do not touch
`git2dart_binaries`, bindings, OpenSSL/platform setup, secrets, worktrees,
commits, or pushes.

## 9. Migration plan

1. No persisted-data migration is needed.
2. Update callers only if they intentionally passed invalid types or ref names
   and depended on a later native error; that behavior is a documented defect.
3. Run focused tests, formatter, analyzer, and the ordinary relevant suite;
   no live-network or cross-repository validation is introduced by this feature.

## 10. Risks and mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Validator diverges from the approved Git rules | high | medium | Table-test every listed invalid class and representative valid names; retain the official Git reference as background evidence. |
| A public name position bypasses validation | high | medium | Enumerate and test every `Reference` public string input named in the minimal plan. |
| Valid native errors become `ArgumentError` | medium | low | Validate syntax only; retain binding calls and typed native-error translation after validation succeeds. |
| Scope creeps into branches, refspec globs, FFI, or binaries | medium | low | Limit edits to the four files above and treat non-`Reference` string APIs as out of scope. |

## 11. Definition of done

- [ ] `Odb` accepts exactly `commit`, `tree`, `blob`, and `tag` for write/hash paths.
- [ ] All covered invalid ref-name positions throw `ArgumentError` before native work.
- [ ] Valid representative top-level and `refs/` names remain eligible for native work.
- [ ] Affected public API docs describe local `ArgumentError` behavior.
- [ ] Focused tests pass, formatting is clean, and `flutter analyze` has zero warnings.
- [ ] No bindings, binaries, OpenSSL, secrets, worktrees, commits, pushes, or unrelated files changed.

## 12. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial plan generated by `/reversa-plan` | reversa |

