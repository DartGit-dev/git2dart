---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: cutover_plan
producedBy: strategist
hash: "sha256:<body hash below front-matter>"
---

# Cutover Plan

> Cutting plan from the legacy to the new system, aligned with the strategy chosen in `migration_strategy.md`.

## Base strategy
- **Strategy confirmed**: <reference to migration_strategy.md>

## Prerequisites
- [ ] <prerequisite 1: e.g. behavioral parity ≥ X% for N days>
- [ ] <prerequisite 2>
- [ ] <prerequisite 3>

## Janela de cutover
- **Data alvo**: <ISO-8601 ou janela>
- **Estimated duration**: <hours>
- **Affected environment**: <production / staging / other>
- **Prior communication**: <stakeholders notified, deadline>

## Passos do cutover

| # | Step | Owner | Duration | Reversible? |
|---|---|---|---|---|
| 1 | <ex: freeze writes in legacy> | | | |
| 2 | <ex: final ETL of data> | | | |
| 3 | <ex: roteamento DNS> | | | |
| 4 | <ex: smoke tests in the new> | | | |

## Plano de rollback
- **Trigger criteria**: <when ​​rollback is decided>
- **Passos**:
  1. <passo>
  2. <passo>
- **Maximum acceptable time until rollback**: <minutes / hours>
- **Owner do rollback**: <name / role>

## Go/no-go criteria
- **Go**:
- <criterion 1>
- <criterion 2>
- **No-go**:
- <criterion 1>
- <criterion 2>

## Post-cutover
- [ ] Monitoring extended for <period>
- [ ] Parity validation according to `parity_specs.md`
- [ ] Decommission of legacy on <date>

## Notas
<Additional notes.>
