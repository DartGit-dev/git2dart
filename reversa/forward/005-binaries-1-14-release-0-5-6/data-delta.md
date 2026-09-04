# Data Delta: Companion Binaries 1.14 Upgrade and 0.5.6 Release Preparation

## Conceptual diff

| Area | Before | After | Confidence |
|------|--------|-------|------------|
| Git-domain data model | Existing Git objects, refs, index, configuration, worktree, and repository formats | Unchanged | 🟢 |
| Application database | None; the package has no relational application database | None | 🟢 |
| Package dependency metadata | `git2dart_binaries >=1.13.0 <1.14.0`, locked 1.13.0 | Planned `>=1.14.0 <1.15.0`, locked 1.14.0 | 🟢 |
| Package release identity | `git2dart` 0.5.5 | Planned 0.5.6 | 🟢 |

## Fields and entities

No domain entity, persisted field, index, serialization format, or Git object
format is added, removed, renamed, or transformed by this feature.

## Required migration

No data migration is required. Dependency resolution updates package metadata
and its lock-file selection; it does not migrate consumer repositories or
persisted application data.

## Safety boundary

The absence of a data-model migration does not prove that new native binaries
are ABI-, packaging-, or behavior-equivalent. Those questions belong to the
release validation evidence described in `roadmap.md` and `investigation.md`.
