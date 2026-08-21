---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: data_migration_plan
producedBy: designer
hash: "sha256:<body hash below front-matter>"
---

# Data Migration Plan

> Data migration plan from legacy to the new system: mapping, transformations, ETL, data cutover and validation.

## Summary
- Estimated volume: <lines/GB per main entity>
- Migration window: <see `cutover_plan.md`>
- Strategy: prior backfill + delta + cut | single bulk | continuous replication

## Legacy mapping → new

| Source | Destination | Type | Notes |
|---|---|---|---|
| `<schema legado>.tb_pedidos` | `pedidos` | renaming | type normalization |
| `<schema legado>.tb_pedido_item` | `pedido_itens` | renaming | FK adjusted |
| `<schema legado>.usr_x` | `usuarios` (partial) + `perfis` | division | extracts profile data |

## Transformations

### Transformation T-01: <name>
- **Aplica em**: <coluna ou tabela>
- **Rule**: <explicit text>
- **Invalid treatment**: <discard | reject | fill with default>
- **Rule origin**: <reference to `target_business_rules.md` or `discard_log.md`>

<repeat for transformation>

## ETL Strategy

- **Ferramenta**: <ex: scripts SQL, dbt, Airbyte, custom>
- **Fluxo**:
1. <extraction>
2. <transformation>
  3. <carga>
- **Idempotency**: <how ETL is safe for re-execution>
- **Throughput esperado**: <ex: 50k linhas/s>

## Backfill e delta

- **Backfill**: <start date, scope, duration>
- **Captura de delta**:
- **Mechanism**: CDC | log mining | timestamps | replication | trigger
- **Acceptable latency**: <seconds>
- **Periodic reconciliation**: <frequency, scope>

## Data cutover

> See also `cutover_plan.md`. Here only the specific part of data.

- **Janela**: <ISO-8601>
- **Cutting sequence**:
  1. <passo>
  2. <passo>
- **Post-cut check**:
- **Counts**: <which tables, tolerance>
- **Checksums**: <critical columns>

## Quality validation

| Metric | Target | Measurement source |
|---|---|---|
| Count by entity | equal ± 0% | direct comparison |
| Sum of monetary values ​​| equal ± 0.01% | financial reconciliation |
| Referential integrity | 0 orphans | audit scripts |

## Data-specific risks
- <RISK-XXX: ver `risk_register.md`>

## Notas
<Additional notes.>
