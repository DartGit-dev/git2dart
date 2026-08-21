---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: migration_brief
producedBy: orchestrator
hash: "sha256:<body hash below front-matter>"
---

# Migration Brief

> Migration criteria document collected in interview at the beginning of `/reversa-migrate`.
> Consumed by the six agents of the Migration Team. It does not ask paradigm (responsibility of Paradigm Advisor) nor appetite (derived in `paradigm_decision.md`).

## Migration objective
<Why does this migration exist? What changes in the business if it happens or not.>

## Success metrics
- <metric 1, with clear numerical or qualitative target>
- <metric 2>
- <metric 3>

## Restrictions
- **Prazo**: <data ou janela>
- **Budget**: <range, team, hiring involved>
- **Techniques**: <External APIs that cannot change, contracts, regulatory rules>
- **Operational**: <maintenance windows, SLAs during migration>

## Fatores de risco conhecidos
- <risk 1: short description>
- <risk 2>

## Stakeholders
| Name / role | Responsibility in migration |
|---|---|
| <name> | <responsabilidade> |

## Stack alvo
- **Language**: <ex: Node.js 20>
- **Framework**: <ex: Fastify>
- **Bank**: <ex: PostgreSQL 16>
- **Mensageria** (se houver): <ex: SQS, Kafka, none>
- **Infra**: <ex: AWS Lambda, Kubernetes, on-premise>
- **Other relevant components**: <cache, observability, gateway>

## Escopo declarado
- **Included**: <legacy modules included>
- **Excluded**: <modules that are left out or will be discontinued>

## Notas livres
<Any context the user wants to leave on record for agents to read.>
