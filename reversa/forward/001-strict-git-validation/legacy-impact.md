# Legacy Impact: Strict Git Validation

Date: 2026-08-24
Feature: `001-strict-git-validation`
Anchor: `reversa/sdd/architecture.md` and `reversa/sdd/domain.md`

| Affected file | Component | Type | Severity | Rationale |
| --- | --- | --- | --- | --- |
| `lib/src/odb.dart` | Git objects and object database | regra-alterada | MEDIUM | Replaces the partial ODB type deny-list with the finite concrete-type contract before native calls. |
| `lib/src/reference.dart` | References and remotes | regra-alterada | MEDIUM | Adds one local Git reference-name grammar at every covered public input before native calls. |
| `test/odb_test.dart` | Git objects and object database | regra-nova | LOW | Adds public-boundary coverage for every `GitObject` value. |
| `test/reference_test.dart` | References and remotes | regra-nova | LOW | Adds valid and invalid reference-name boundary coverage for every planned input position. |

## Conceptual diff by component

The ODB wrapper now admits only commit, tree, blob, and tag types for write and
hash operations. Abstract and delta values now fail deterministically with
`ArgumentError` instead of reaching libgit2.

The reference wrapper now applies one shared Git name grammar to creation,
lookup, deletion, rename, target update, reflog, and name-to-OID operations.
Successfully validated input continues to use the existing native path and its
existing typed error translation.

## Preservadas

- Domain rule 4: only concrete commit, tree, blob, and tag object types may be
  written or hashed through ODB APIs.
- Domain rule 7: direct references carry OIDs; symbolic references carry
  reference names, and compare-and-set inputs retain matching representations.
- The architecture's native-error translation remains the error boundary after
  successful local validation.

## Modificadas

- ODB validation changes from a partial predicate to finite enforcement of
  domain rule 4 at each public write/hash input.
- Reference-name validation changes from native-only failure behavior to local
  deterministic enforcement before every covered public input reaches libgit2.
