# Actions: Analyzer Evidence Closure

> Identifier: `002-analyzer-evidence-closure`  
> Scope: evidence-only analyzer closure. Product sources, tests, dependencies, binaries, OpenSSL, feature 001, commits, pushes, and worktrees are excluded.

## Phase 1 — Reproduce and characterize current evidence diagnostics

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-001 | Run scoped analyzer/diagnostic reproduction for the two E3LU evidence programs and record the current unresolved helper URI and `setupRepo` diagnostics without changing sources. Preserve the borrowed-entry/free/fixture-teardown reproduction semantics as the baseline. | none | parallel with A-002 and A-003 | `reversa/bugs/git-objects-and-object-database/bugs/BUG-20260817-E3LU-tree-entry-invalid-free/evidence/reproduce_invalid_free.dart`, `reversa/bugs/git-objects-and-object-database/bugs/BUG-20260817-E3LU-tree-entry-invalid-free/evidence/reproduce_invalid_free_test.dart` | High | [X] |
| A-002 | Run scoped analyzer/diagnostic reproduction for the ZC7X lifecycle evidence program and record the four unresolved lifecycle-symbol diagnostics without changing sources. Preserve the count-growth reproduction, restoration guard, two explicit shutdowns, output, and assertions as the baseline. | none | parallel with A-001 and A-003 | `reversa/bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-ZC7X-unbalanced-libgit2-lifecycle/evidence/reproduction_test.dart` | High | [X] |
| A-003 | Read the Reversa state and feature 001 checkpoint without mutating either artifact; confirm `001-strict-git-validation` remains paused and that this feature is the only forward artifact to be advanced. | none | parallel with A-001 and A-002 | `.reversa/state.json`, `reversa/forward/001-strict-git-validation/actions.md` | High | [X] |

## Phase 2 — Correct evidence-only imports and symbol usage

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-004 | Correct only the shared-helper import in each E3LU program from five to six parent traversals, resolving `../../../../../../test/helpers/util.dart` and `setupRepo` from the repository root. Do not change fixture setup, borrowed-entry/free sequence, parent/repository cleanup, or assertions. | A-001 | parallel with A-005 | `reversa/bugs/git-objects-and-object-database/bugs/BUG-20260817-E3LU-tree-entry-invalid-free/evidence/reproduce_invalid_free.dart`, `reversa/bugs/git-objects-and-object-database/bugs/BUG-20260817-E3LU-tree-entry-invalid-free/evidence/reproduce_invalid_free_test.dart` | High | [X] |
| A-005 | Replace only the four lifecycle probes with the compile-visible `libgit2Runtime.bindings` API in the ZC7X program. Retain imports, restoration guard, two explicit shutdowns, output, and count assertions so the artifact remains a lifecycle count-growth reproduction rather than a remediation. | A-002 | parallel with A-004 | `reversa/bugs/native-runtime-and-platform-boundary/bugs/BUG-20260817-ZC7X-unbalanced-libgit2-lifecycle/evidence/reproduction_test.dart` | High | [X] |

## Phase 3 — Scoped evidence validation

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-006 | Run scoped analyzer checks for all three corrected evidence programs. Require zero diagnostics attributable to their import/symbol changes, and execute the available diagnostic reproductions only when the existing local runtime permits it; report runtime incompatibility as evidence rather than changing dependencies or binaries. | A-004, A-005 | sequential after both evidence changes | three evidence programs listed in A-001 and A-002 | High | [X] |

## Phase 4 — Temporary compatible runtime and full-analyzer evidence

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-007 | Before full validation, fingerprint the active override/runtime state; prepare the documented temporary compatible companion runtime at `ea87cf29626a371fcb33e646be64bfe30b565c72` with the recorded staged hosted-1.12.1 Windows DLL payload, setting `GIT2DART_BINARIES_PACKAGE_ROOT` only for validation commands. Do not persist dependency, override, binary, or OpenSSL changes. | A-006 | sequential environment preparation | temporary validation environment only; no repository source target | Medium | [X] |
| A-008 | In the temporary compatible runtime arrangement, run full `flutter analyze`. Classify the result precisely: require zero diagnostics in the three covered evidence programs, retain the known excluded `lib/` diagnostics as excluded evidence, and do not claim a repository-wide green analyzer. | A-007 | sequential full-validation gate | three evidence programs listed in A-001 and A-002 | High | [X] |
| A-009 | In a guaranteed cleanup path after A-007/A-008, restore the pre-run override/runtime artifacts, remove only temporary staged artifacts created by this run, and compare the recorded fingerprint/content to prove restoration. If restoration cannot be proven, mark the environment dirty and stop rather than advancing a forward stage. | A-007, A-008 | sequential cleanup gate | temporary validation environment only; no repository source target | High | [X] |

## Phase 5 — Scope and handoff validation

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-010 | Verify the final diff is limited to the three approved evidence programs and this feature's Reversa artifacts. Reconfirm feature 001 remains paused and untouched; verify no product source/test, `git2dart_binaries`, OpenSSL, dependency, secret, worktree, commit, or push change occurred. | A-003, A-009 | sequential final gate | three evidence programs and `reversa/forward/002-analyzer-evidence-closure/` | High | [X] |

## Execution notes

Reserved for `/reversa-coding` to record reproduction results, analyzer classifications, temporary-runtime fingerprints, and cleanup evidence.

## Change history

- 2026-08-24 — Created the evidence-only analyzer-closure action plan from the approved requirements, roadmap, and onboarding artifacts.
