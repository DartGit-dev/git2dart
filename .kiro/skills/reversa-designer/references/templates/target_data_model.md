---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: target_data_model
producedBy: designer
hash: "sha256:<body hash below front-matter>"
---

# Target Data Model

> New system data model. Schema, relationships and constraints.

## Overview
<Short text: type of main bank, division by bounded context, roles (OLTP / OLAP / event store).>

## Data entities

| Entity | Table/Collection | Aggregate owner | PK | Bound context |
|---|---|---|---|---|
| <name> | <ref> | <AGG> | <field> | <BC> |

## Schema (DDL ou equivalente)

```sql
-- Replace with the actual DDL of the target system.
CREATE TABLE pedidos (
    id UUID PRIMARY KEY,
    cliente_id UUID NOT NULL,
    status TEXT NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Relacionamentos

| Source | Destination | Cardinality | Integrity | Notes |
|---|---|---|---|---|
| pedidos.cliente_id | clientes.id | N:1 | FK ON DELETE RESTRICT | |

## Restrictions

- **Unicidade**: <list>
- **Referential Integrity**: <enabled / disabled and why>
- **Partitioning / sharding** (if applicable): <description>
- **Critical indices**: <list>

## Considerations specific to the target paradigm

> Dedicated section when the target paradigm is event-driven, functional or other with direct implications for the data model.

- <ex: event-driven → outbox table for at-least-once guarantee>
- <ex: event sourcing → event store as source of truth, derived projections>
- <ex: immutability → immutable events/snapshots, no updates>

## Origin in legacy

| New Table/Collection | Origin in legacy | Transformation |
|---|---|---|
| requests | `<schema legado>.tb_pedidos` | renaming + normalized types |

## Notas
<Additional notes on the data model.>
