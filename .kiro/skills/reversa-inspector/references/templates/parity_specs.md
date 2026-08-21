---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: parity_specs
producedBy: inspector
hash: "sha256:<body hash below front-matter>"
---

# Parity Specs

> Behavioral equivalence validation strategy between legacy and new system, adapted to the paradigm chosen in `paradigm_decision.md`.

## General strategy
- **Applicable validation modes** (mark those used):
- [ ] Shadow mode (traffic mirroring with asynchronous comparison)
- [ ] Characterization tests (suite derived from the current behavior of the legacy)
  - [ ] Contract tests (interfaces externas)
  - [ ] Data parity (snapshots e checksums)
  - [ ] Outro: <especificar>

## "Accepted parity" criteria
- **Primary metric**: <ex: functional divergence index < 0.01% on N consecutive days>
- **Observation window**: <evaluation period>
- **Blocking criterion**: <when ​​insufficient parity blocks the cutover>

## Coverage adapted to the paradigm

> This section changes depending on the target paradigm confirmed in `paradigm_decision.md`.

### No paradigm shift
- Standard functional equivalence: same input → same output → same observable side effect.

### Synchronous change → event-driven
- **Message order**: <acceptance criteria per channel / partition>
- **Idempotence**: <proof that reprocessing does not double the effect>
- **Eventual consistency**: <maximum accepted propagation window>
- **Comportamento sob falha de fila**: <retry, DLQ, replay>

### Procedural change → OO
- **Invariants in aggregates**: <set to be validated>
- **Validation in factories / builders**: <critical cases>

### OO change → functional
- **Immutability**: <critical points to note>
- **Lack of expected side effects**: <where the legacy had an implicit side effect>
- **Equivalence under composition**: <composite functions are equivalent to legacy flow>

## Tipos de teste a aplicar
- **Functional**: <description, tool>
- **Contract**: <description, tool>
- **Load / performance**: <description, targets>
- **Resilience** (if applicable): <queue failure, external dependency unavailable>

## Reuso de characterization_specs do time de descoberta
- **Origin**: `reversa/sdd/characterization_specs/` or equivalent available.
- **Necessary adaptations for the new system**: <text>

## Outputs
- `parity_tests/*.feature`: Gherkin scenarios for critical flows.

## Notas
<Additional notes.>
