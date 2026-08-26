# Addendum: Strict Git Validation

Feature ID: `001`

Date: 2026-08-24

Scenario: legacy

## Vigência

Vigente desde 2026-08-24.

## Resumo da entrega

This feature makes invalid Git object types and invalid reference names fail at
the package's public Dart boundary, before a native call. It replaces a partial
ODB type predicate with a finite concrete-type contract and applies one shared
Git reference-name grammar at covered public reference inputs. 8 of 8 planned
actions are complete.

## Impacto por artefato da extração

| Artefato | Seção | Tipo de impacto | Delta |
| --- | --- | --- | --- |
| `reversa/sdd/architecture.md` | [Feature wrappers](../architecture.md#feature-wrappers) | regra-alterada | The ODB wrapper now locally accepts only `commit`, `tree`, `blob`, and `tag` for write and hash inputs; all other object types fail with `ArgumentError` before native execution. |
| `reversa/sdd/architecture.md` | [Feature wrappers](../architecture.md#feature-wrappers) | regra-alterada | The reference wrapper now applies one local Git name grammar to every covered public name input before the existing native path and typed native-error translation. |
| `reversa/sdd/domain.md` | [Object and repository integrity](../domain.md#object-and-repository-integrity) | regra-nova | Read the concrete ODB-type rule as an enforced public-boundary contract with exhaustive positive and negative coverage. |
| `reversa/sdd/domain.md` | [References and history](../domain.md#references-and-history) | regra-nova | Read covered public reference-name positions as locally rejecting invalid Git syntax with `ArgumentError` while representative valid names remain eligible for native handling. |

## Regras sob vigilância

- [W001](../../forward/001-strict-git-validation/regression-watch.md#w001)
- [W002](../../forward/001-strict-git-validation/regression-watch.md#w002)

## Fontes

- `reversa/forward/001-strict-git-validation/legacy-impact.md`
- `reversa/forward/001-strict-git-validation/regression-watch.md`
- `reversa/forward/001-strict-git-validation/requirements.md`
- `reversa/forward/001-strict-git-validation/progress.jsonl`
- `reversa/sdd/architecture.md`
- `reversa/sdd/domain.md`
