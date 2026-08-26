# Roadmap: Analyzer Evidence Closure

> Identifier: `002-analyzer-evidence-closure`
> Date: `2026-08-24`
> Requirements: `reversa/forward/002-analyzer-evidence-closure/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Repair only the three named reproduction evidence sources under `reversa/bugs/`.
Correct the E3LU relative fixture imports by one directory level and migrate the
four ZC7X probe calls from the removed `libgit2` global to the companion's
compile-visible `libgit2Runtime.bindings` API. Preserve every reproduction
sequence, assertion, cleanup step, and product source file.

Validation has two deliberately separate results. First, retain the current
full-analyzer baseline under the active direct-companion override: 21 errors,
comprising the eight covered evidence diagnostics and 13 excluded `lib/`
errors. Then validate the repaired evidence using the previously proven
temporary ea87cf runtime with its staged Windows DLL payload, run the full
analyzer, and report zero covered evidence errors while still reporting the
excluded `lib/` errors. Restore the original override/runtime state in a
finally-style cleanup whether validation passes or fails. 🟢

## 2. Applied principles

`.reversa/principles.md` is absent; no project-specific principle can be
evaluated or changed. The proposal respects the extracted quality and native
boundary principles.

| Principle | Feature relationship | Status |
|-----------|----------------------|--------|
| No project principle artifact exists | Record the absence; do not invent a replacement principle. | n/a |
| Quality path: static analysis and Flutter tests (`reversa/sdd/architecture.md#Quality and Delivery Architecture`) | Makes diagnostic attribution reproducible without claiming repository-wide health. | respects 🟢 |
| Native binding/runtime boundary (`reversa/sdd/architecture.md#Native binding adapters`) | Uses the companion's exported runtime API; does not add loading or lifecycle code to the consumer. | respects 🟢 |
| Borrowed native data must not outlive its owner (`reversa/sdd/architecture.md#Security and Trust Boundaries`) | Keeps the E3LU borrowed-entry cleanup sequence intact. | respects 🟢 |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternatives | Confidence |
|----|----------|-----------|-----------------------|------------|
| D-01 | Change both E3LU imports from five to six parent traversals so they resolve `test/helpers/util.dart` from the repository root. | The evidence files live under `reversa/bugs/<module>/bugs/<bug>/evidence/`; the current path stops at `reversa/test`. | Copy the fixture helper; move evidence; use a package-private import. | 🟢 |
| D-02 | Replace only four ZC7X `libgit2` probe references with `libgit2Runtime.bindings`. | ea87cf intentionally removes the eager global and exports the managed runtime boundary. | Restore the removed global; add a local runtime wrapper; change production lifecycle code. | 🟢 |
| D-03 | Preserve the probe's init/shutdown pair and both public-call count assertions exactly. | The evidence demonstrates refcount growth; it is not a lifecycle remediation. | Delete the probe; weaken to compilation-only evidence. | 🟢 |
| D-04 | Treat the active override's 21-error output as the baseline, not the final result. | Current evidence proves 8 in scope plus 13 excluded `lib/` errors. | Call the repository analyzer green; fold the 13 product errors into this feature. | 🟢 |
| D-05 | Reuse the documented temporary ea87cf runtime and staged DLL procedure only for validation, then restore the original override/runtime artifacts in cleanup. | It is the previously proven Windows runtime boundary; temporary configuration must not leak into the workspace. | Change dependencies/binaries permanently; use a worktree; skip restoration on failure. | 🟢 |

## 4. Assumptions

None. `requirements.md` contains no `[DÚVIDA]` markers; its clarify session
explicitly authorizes the scoped runtime procedure.

## 5. Architectural delta

| Component | Legacy source | Change type | Summary |
|-----------|---------------|-------------|---------|
| Git objects and object database evidence | `reversa/sdd/code-analysis.md#Feature 2: Git Objects and Object Database` | changed evidence import | E3LU capsules regain the shared fixture dependency without changing the borrowed-entry scenario. |
| Native runtime and platform boundary evidence | `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary` | changed evidence API reference | ZC7X uses the current companion runtime binding surface for its probes. |
| Native binding adapters and product wrappers | `reversa/sdd/architecture.md#Native binding adapters` | unchanged | No `lib/`, `test/`, dependency, generated-binding, binary, or OpenSSL edit. |

## 6. Data-model delta

- No Git object, reference, index, configuration, repository, schema, or file
  format changes.
- Evidence source imports and API identifiers are the only in-memory/source-level
  delta.
- Detail: `reversa/forward/002-analyzer-evidence-closure/data-delta.md`.

## 7. External-contract delta

No HTTP, queue, gRPC, GraphQL, file-format, public-package, or ABI contract
changes. `interfaces/` is intentionally omitted.

## 8. Exact implementation and validation plan

| File | Exact delta | Acceptance evidence |
|------|-------------|---------------------|
| `reversa/bugs/git-objects-and-object-database/bugs/BUG-20260817-E3LU-tree-entry-invalid-free/evidence/reproduce_invalid_free.dart` | Change only the shared-helper relative import to the repository-root-correct six-level path. | URI and `setupRepo` diagnostics disappear; borrowed entry, explicit free, parent free, repository free, and fixture deletion remain unchanged. |
| `reversa/bugs/git-objects-and-object-database/bugs/BUG-20260817-E3LU-tree-entry-invalid-free/evidence/reproduce_invalid_free_test.dart` | Make the same one-level import correction only. | URI and `setupRepo` diagnostics disappear; test still records borrowed free, parent free, repository cleanup, and fixture teardown. |
| `reversa/bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-ZC7X-unbalanced-libgit2-lifecycle/evidence/reproduction_test.dart` | Replace the four init/shutdown probes through `libgit2Runtime.bindings`; retain imports, restoration guard, two explicit shutdowns, output, and count assertions. | All four undefined-`libgit2` diagnostics disappear; the evidence remains a count-growth reproduction. |

### Baseline and final proof boundary

1. Before editing, record the current `flutter analyze` result under the active
   `pubspec_overrides.yaml -> ../git2dart_binaries` override: 21 errors total.
   Attribute exactly eight to the three files above and 13 to excluded `lib/`
   paths. This is a failing baseline, not a repository-health claim.
2. After editing, run targeted analysis for the three evidence files to establish
   zero covered diagnostics.
3. Reuse the prior temporary Windows compatibility procedure: companion Dart
   runtime at commit `ea87cf29626a371fcb33e646be64bfe30b565c72`, staged DLL
   payload from the recorded hosted 1.12.1 native root, and the documented
   `GIT2DART_BINARIES_PACKAGE_ROOT` setting where runtime execution needs it.
4. Under that temporary runtime, run the full `flutter analyze` and classify
   output: zero diagnostics from the three covered evidence files; the known 13
   `lib/` diagnostics remain explicitly excluded. Do not label the command
   green unless it has zero total diagnostics.
5. In guaranteed cleanup, restore the pre-validation override/runtime files and
   remove only the temporary staged runtime artifacts created for this run.
   Re-run a non-mutating state check to prove the original incompatible override
   is restored.

No product or test source is planned. Feature 001 remains paused and untouched.

## 9. Migration plan

1. No data migration or consumer migration applies.
2. Update only the three evidence sources.
3. Restore the temporary validation runtime after collecting proof; it is not a
   deliverable dependency or binary change.

## 10. Risks and mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A relative import is still rooted one level too shallow | high | low | Analyze each E3LU file directly before full analysis. |
| ZC7X compilation succeeds but changes its lifecycle observation | high | low | Preserve the init/shutdown restoration guard and exact count assertions. |
| Full-analyzer output is reported as clean despite excluded errors | high | medium | Require path-based accounting: 0 covered evidence, 13 excluded `lib/`, never an unqualified green claim. |
| Temporary runtime or DLL payload leaks into the workspace | high | medium | Fingerprint original state first and restore in guaranteed cleanup; validate restored state afterward. |
| Scope expands into lifecycle remediation or binaries | high | low | Restrict edits to the three listed evidence files; no `lib/`, `test/`, pubspec, override, companion, or OpenSSL commit. |

## 11. Definition of done

- [ ] Both E3LU evidence imports resolve `test/helpers/util.dart` and `setupRepo`.
- [ ] All four ZC7X runtime probe references compile via `libgit2Runtime.bindings`.
- [ ] Borrowed-entry cleanup and lifecycle count assertions remain unchanged.
- [ ] Targeted analysis reports no diagnostics in the three covered files.
- [ ] Full analyzer is reported honestly: no covered evidence diagnostics, with
  excluded product diagnostics listed separately if still present.
- [ ] The temporary ea87cf/DLL validation environment is restored to its original
  incompatible override state, even after a failed validation.
- [ ] No feature 001, product source/test, dependency, binary, OpenSSL, secret,
  worktree, commit, or push change occurs.

## 12. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-24 | Initial plan generated by `/reversa-plan` | reversa |

