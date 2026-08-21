# User Stories — Working Tree and Index

> 🟢 **CONFIRMED** — Stories expose controlled mutable projections and conflict-aware behavior.

## US-WI-01 — Stage and Serialize Content

🟢 **CONFIRMED** — As a Git application, I want to add/update/remove index entries and write a conflict-free tree so that staged content becomes an immutable snapshot.

## US-WI-02 — Resolve Conflicts

🟢 **CONFIRMED** — As a merge UI, I want nullable ancestor/ours/theirs plus REUC/NAME metadata so that I can resolve three-way conflicts without losing provenance.

```gherkin
Dado an index with unresolved conflict stages
Quando all paths are resolved and the index is written
Então writeTree succeeds only after no unresolved conflict remains
```

## US-WI-03 — Inspect and Apply Changes

🟢 **CONFIRMED** — As a review tool, I want diffs, patches, hunks, lines, stats, and check-only apply so that I can inspect applicability before mutation.

## US-WI-04 — Materialize or Stash Work

🟢 **CONFIRMED** — As an application, I want explicit checkout/stash strategies and paths so that mutation scope and destructive intent are caller-controlled.

## US-WI-05 — Match Repository Paths

🟢 **CONFIRMED** — As a caller, I want pathspec, ignore, attribute, and filter evaluation so that repository policy is applied consistently.

## Unresolved Persona Need

🔴 **GAP** — Transactional rollback, callback concurrency, borrowed patch lifetime, and platform path normalization require decisions/evidence.

