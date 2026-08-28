# Cross-check Audit: Companion Binaries 1.13 Migration

> Date: `2026-08-26`
> Feature: `003-binaries-1-13-migration`
> Artifacts: [requirements](../requirements.md), [roadmap](../roadmap.md), [actions](../actions.md)
> Mode: independent strict read-only final audit; no analyzed artifact was modified

## Summary

| Severity | Count |
|----------|------:|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |

The requirements-to-roadmap-to-actions chain is complete, the action graph is
sound, all 27 actions are marked complete, and the recorded implementation and
delivery evidence is consistent with the current product commit. No CRITICAL or
HIGH audit blocker prevents `/reversa-sync`.

One non-blocking legacy-reference inconsistency remains. The pre-sync addendum
also requires mandatory reconciliation during `/reversa-sync`; that expected
sync-owned stale state is documented separately below and is not counted as a
finding against the three primary audit artifacts.

## Findings

| ID | Severity | Axis | Description | Where |
|----|----------|------|-------------|-------|
| A001 | MEDIUM | Coherence with legacy | BR-05 cites `reversa/sdd/gaps.md#Overlapping native operations`, but that heading does not exist. The underlying extracted concern does exist as `GAP-C02`, “Callback/global/repository concurrency contract absent,” under `gaps.md#Critical`; the rule is traceable, but its section anchor is inaccurate. | `requirements.md`, section 4, BR-05; `reversa/sdd/gaps.md`, Critical table, GAP-C02 |

## Passed checks

### Coverage

- FR-01 maps to D-01 and T001/T014/T021.
- FR-02 maps to D-02 and T002/T006.
- FR-03 maps to D-03/D-04 and T003/T006/T012.
- FR-04 maps to D-02/D-03/D-05 and T003/T004/T006/T012.
- FR-05 maps to D-05 and T004/T007-T010/T012-T013.
- FR-06 maps to D-06 and the executable T022-T027 chain, which gates T014.
- FR-07 maps to D-07 and T005/T011/T015-T020.
- D-01 through D-08 each map to at least one action.
- All nine Gherkin scenarios map to decisions and actions: hosted resolution,
  runtime access, native-width reads, the conditional 64-bit boundary,
  delivered native errors, deterministic missing-error fallback, public option
  compatibility, documentation validation, and platform startup.

### FR-06 executable ownership

- T022 inventories only consumer-facing public Dart `///` comments, `doc/types/`,
  and the named README/API-reference roots. It requires classification of each
  hit as affected or unrelated and forbids general native-error documentation
  cleanup.
- T023 changes only affected public Dart comments identified by T022 and
  excludes unrelated/internal binding documentation.
- T024 changes only matched `doc/types/` pages.
- T025 changes only matched README/API-reference passages in `README.md`,
  `doc/README.md`, and `doc/git2dart_binaries_api_updates.md`.
- All named documentation roots exist. The generated `doc/api/` output used by
  T027 is excluded by `.gitignore`.
- T026 repeats the same scoped search after T023-T025 and requires zero obsolete
  constructor or error-contract promises in the affected match set.
- T027 runs the exact `dart doc` command, records the
  command/result, and treats generation failure as a blocker.
- T014 depends directly on T027 as well as T012 and T013, so neither local gate
  completion nor downstream platform CI can bypass documentation validation.

### Consistency

- The feature identifier is identical across requirements, roadmap, and actions.
- Every FR, D, and T identifier cited by the three primary artifacts exists.
- `Size`, `IntPtr`, the runtime object's `bindings`/`options` surface,
  `StateError`, hosted 1.13.0 adoption, the no-concurrency-guarantee boundary,
  scoped documentation, and mandatory platform CI use consistent terminology.
- `interfaces/` is consistently omitted because no HTTP, RPC, queue, file-format,
  or other external-system protocol changes.

### Coherence with the legacy extraction

- The referenced architecture components and headings exist: public package
  facade, native binding adapters, companion native package, and quality and
  delivery architecture.
- The native runtime/platform boundary exists in `code-analysis.md`; its global
  options, shared error translation, and Android/iOS initialization concerns are
  represented in the feature plan.
- The exception-type change is explicitly authorized and traceable from BR-03
  through D-05 and T004/T007-T010.
- Companion ownership of declarations/binaries, public API stability,
  native-width handling, scoped temporary allocation, explicit mobile startup,
  and validation-scope limits align with active Principles I-VI.

### Action sanity

- All 27 action IDs are unique and all 27 statuses are `[X]`.
- Every dependency points to an existing action ID; the graph is acyclic.
- The longest dependency path contains eleven actions (ten edges), matching the
  summary's action-count convention.
- All twelve `[//]` actions have disjoint concrete or T022-classified match-only
  write scopes. T023 excludes internal binding documentation and the current
  affected public-comment set does not collide with the parallel core targets.
- T023-T025 converge at T026; T027 gates T014; T014 gates all five CI jobs;
  T020 requires all platform results before T021.

### Implementation and local evidence

- `pubspec.yaml` requires hosted `git2dart_binaries >=1.13.0 <1.14.0`,
  `pubspec.lock` resolves hosted 1.13.0, and the API-diff baseline remains
  `1.13.0`; no dependency override or regenerated declaration is part of the
  feature evidence.
- Current source reaches native calls through `libgit2Runtime.bindings`, uses
  arena-managed `Size` for the affected `size_t` groups and `IntPtr` for both
  cached-memory outputs, retrieves delivered native error detail, and retains
  the authorized explanatory `StateError` fallback.
- Focused tests cover the option-group split, value restoration, the conditional
  64-bit `4_294_967_296` round trip, both error branches, obsolete-constructor
  rejection, and Android/iOS initialization source paths.
- `progress.jsonl` records successful dependency resolution, formatting of the
  planned Dart files, zero-warning analysis, `958` passing tests with `24`
  network-dependent skips, clean `git diff --check`, and successful `dart doc`
  with `17` pre-existing unresolved-reference warnings and zero errors.
- These local commands were not rerun by this strict audit; their recorded
  results are corroborated by the unchanged product commit and live hosted CI.

### Git and hosted CI evidence

- `HEAD` and `origin/0.5.5` both resolve to
  `9b47c0aaba67168ea74d671f9dee47418d10ad65`
  (`feat: migrate companion binaries to 1.13`).
- Before this report rewrite, the current uncommitted state was limited to four
  post-CI Reversa records: `.reversa/active-requirements.json`, `actions.md`,
  `progress.jsonl`, and `regression-watch.md`; no product source or test file
  differed from the pushed commit.
- Live GitHub inspection reconfirmed Build run `32974619039` at the exact commit:
  Quality, Linux, macOS, Windows, Android, and iOS all completed successfully.
- Live GitHub inspection reconfirmed Publish run `32974619046` at the exact
  commit: the workflow and its five platform test jobs completed successfully;
  the `publish` job was skipped. This is successful workflow/platform evidence,
  not evidence that a package was published.

### Hooks and prerequisites

- `.reversa/active-requirements.json` resolves to this feature inside the
  configured `reversa/forward/` directory and reports `current-stage: audit`.
- `requirements.md`, `roadmap.md`, and `actions.md` all exist.
- `before-audit` and `after-audit` are both empty hook lists.

## Required pre-sync reconciliation

The existing `reversa/sdd/addenda/003-binaries-1-13-migration.md` is a stale
pre-sync snapshot: it still states that only 20 of 27 actions are complete and
that T015-T021/platform CI are pending. It also links to `W003`, while the
current `regression-watch.md` defines only W001 and W002. `/reversa-sync` must
rewrite that addendum from the current 27/27 action state and verified CI
evidence, remove or replace the nonexistent W003 link, and preserve the explicit
distinction between a successful Publish workflow and an actual publication.

This stale addendum is the intended downstream sync target rather than an input
to the primary requirements/roadmap/actions cross-check. It does not invalidate
the product commit or the completed action graph, but sync must not report
success if the stale statements or ghost watch reference remain.

## Audit boundary

This audit read the current planning and supporting feature artifacts, relevant
reverse-extracted specifications and principles, current product implementation
and focused tests, Git commit/tracking state, recorded local evidence, and live
read-only GitHub Actions metadata. It did not modify requirements, roadmap,
actions, product code, tests, dependencies, binaries, generated declarations,
Git state, or external state. It did not rerun builds, tests, `dart doc`, native
code, or publication.

## Recommendation

`/reversa-sync` may proceed. It must perform the pre-sync reconciliation above.
A001 is non-blocking but should be corrected by `/reversa-clarify` or manual
editing so BR-05 names the actual GAP-C02 location.

> Digite **CONTINUAR** para prosseguir conforme a sugestão acima.
