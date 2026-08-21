# Matriz de cobertura de paridade

Reference table to define the minimum set of scenarios `.feature` per flow, according to paradigm transition.

## Transition coverage

| Transition | Minimum scenarios per flow |
|---|---|
| no change | `@paridade` (input → expected output) |
| procedural → OO | `@paridade` + `@invariante` (invariante de aggregate validado) |
| procedural → event-driven | `@paridade` + `@idempotencia` + `@ordem` + `@dlq` (comportamento sob falha de fila) |
| Classic OO → OO with DI | `@paridade` + `@composicao` (no Active Record dependency) |
| Classic OO → event-driven | `@paridade` + `@idempotencia` + `@ordem` + `@saga` (failure compensation) |
| Classic OO → functional | `@paridade` + `@imutabilidade` + `@composicao` |
| OO with DI → event-driven | `@paridade` + `@idempotencia` + `@ordem` |
| functional → event-driven | `@paridade` + `@idempotencia` + `@ordem` |
| any → actor model | `@paridade` + `@supervisao` (failure recovery) |

## Tags convencionadas

- `@paridade`: always present; main equivalence.
- `@critico`: critical flow (regulatory, financial, sensitive data).
- `@regulatorio`: when there is an external formal requirement.
- `@idempotencia`: reprocessing does not double the effect.
- `@ordem`: ordem por chave respeitada.
- `@dlq`: behavior when reaching dead letter queue.
- `@saga`: compensation in distributed transaction.
- `@invariante`: invariante de aggregate validado.
- `@composicao`: equivalent behavior under functional composition.
- `@imutabilidade`: there is no shared mutation.
- `@supervisao`: supervisor recupera ator falhado.

## Typical "accepted parity" criteria

| System type | Primary metric |
|---|---|
| Web app without strong regulation | functional divergence < 1% for 7 days |
| Public API | functional divergence < 0.1% for 30 days + zero divergence in public contracts |
| Tax/regulatory system | functional divergence < 0.01% for 60 days + zero divergence in regulated fields |
| Financial system | financial divergence by monetary value < 0.001% + zero divergence in totalizers |
| Internal system low criticality | functional divergence < 5% for 7 days |

## Reuso de characterization_specs

When `reversa/sdd/characterization_specs/` exists:

1. For each spec → derive corresponding `.feature`, adapting inputs/outputs to the new system.
2. Keep the original `spec-id` in traceability.
3. Add extra scenarios according to the "Minimum scenarios per flow" table.

When it doesn't exist:

1. Infer critical flows from `code-analysis.md` + `sequences/` + `BR-MIGRAR` rules marked as critical.
2. Documentar lacuna em `parity_specs.md § Reuso de characterization_specs`.
