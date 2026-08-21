---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: ambiguity_log
producedBy: orchestrator
hash: "sha256:<body hash below front-matter>"
---

# Ambiguity Log

> Consolidation of all ⚠️ AMBIGUOUS or pending items detected by agents throughout the pipeline.
> Expected final status when the pipeline completes: no items PENDING.

## Summary
- Total items: <N>
- PENDENTES: <n>
- RESOLVED WITH HUMAN DECISION: <n>
- REFERRED TO CODING: <n>

## Items

### AMB-001
- **Description**: <text>
- **Detectado por**: paradigm_advisor | curator | strategist | designer | screen_translator | inspector
- **Origin**: <reference to artifact and section>
- **Status**: PENDING | RESOLVED WITH HUMAN DECISION | REFERRED TO CODING
- **Decision made** (if any):
  - **Choice**: <text>
  - **Decisor**: <name>
- **When**: <ISO-8601>
  - **Rationale**: <text>

<repetir por item>

## Items related to coding
> Lists only items with status `REFERRED TO CODING`. They appear highlighted in `handoff.md`.

- AMB-XXX: <short description>

## Notas
<Final remarks from the orchestrator.>
