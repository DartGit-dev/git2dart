---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: screen_deviation_log
producedBy: screen-translator
mode: append-only
hash: "sha256:<body hash below front-matter>"
---

# Screen Deviation Log

> Record of all divergences between the legacy and the spec generated in `target_screens.md`. Append-only. Pending deviations block the handoff to the Inspector.
> Approved deviations are propagated to `parity_specs.md § Exceptions` when Inspector runs.

## Conventions

- **ID**: `DEV-NNN` (sequential, three digits).
- **Tipo**:
- `tecnica`: technical limitation of the target (e.g. Windows terminal without UTF-8 without `chcp 65201`).
- `modernizacao`: intentional divergence resulting from modernized mode.
- `plataforma`: divergence forced due to platform incompatibility (ex: Win16 → web).
- `correcao`: legacy visual bug that the target fixes (e.g. typo in label).
- **Approval**: `pending` | `approved` | `rejected` (also accept legacy Portuguese values when reading existing files).
- Deviation `approved` → also listed in `parity_specs.md § Exceptions`.
- Deviation `pending` → blocks handoff to Inspector.
- Deviation `rejeitado` → archived with explicit note; agent regenerates the screen in conforming mode.

## Summary

- **Total**: <N>
- **Pendentes**: <N>
- **Aprovadas**: <N>
- **Rejeitadas**: <N>

## Entradas

### DEV-001

| Field | Value |
|---|---|
| Screen affected | <canonical-name> |
| Tipo | `tecnica` \| `modernizacao` \| `plataforma` \| `correcao` |
| Description | <what diverges between legacy and new> |
| Reason | <why divergence is necessary or acceptable> |
| Origin in legacy | <file:line> |
| Implication for parity tests | <ex: false byte-by-byte comparison, use semantic comparison> |
| Approval | `pending` \| `approved` \| `rejected` |
| Approved by | <name or identifier, when approved> |
| Approved in | <ISO-8601, when approved> |
| Propagates to `parity_specs.md § Exceptions` | yes \| no |

### DEV-002

(repeat the block above for each deviation)

## Screens with more than one deviation

| Screen | IDs |
|---|---|
| <screen X> | DEV-001, DEV-007 |

## Notas

<General observations about the set of deviations: patterns, lessons that are valid for future migrations in the same source→target pair, suggestions for an improved adapter for v2.>
