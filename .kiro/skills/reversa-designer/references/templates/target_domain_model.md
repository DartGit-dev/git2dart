---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: target_domain_model
producedBy: designer
hash: "sha256:<body hash below front-matter>"
---

# Target Domain Model

> New system domain model. Explicit traceability to legacy (in `reversa/sdd/domain.md` or equivalent).

## Aggregates

### AGG-Pedido
- **Aggregate root**: Pedido
- **Invariantes**:
  - <invariante 1>
  - <invariante 2>
- **Comandos aceitos**: <list>
- **Eventos publicados** (se paradigma event-driven): <list>
- **Legacy Origin**: <ref to `domain.md` or equivalent>

<repetir por aggregate>

## Entidades

| Entity | Aggregate owner | Main attributes | Origin in legacy |
|---|---|---|---|
| <name> | <agg> | <summary list> | <ref> |

## Value objects

| Value object | Attributes | Validations | Origin |
|---|---|---|---|
| <name> | <list> | <rules> | <ref> |

## Domain events
> Mandatory section if the paradigm is event-driven or hybrid.

| Evento | Publicado por | Consumido por | Schema (resumido) |
|---|---|---|---|
| <PedidoCriado> | AGG-Pedido | Pagamento, Estoque | <campos> |

## Domain rules
> Mapping of rules coming from `target_business_rules.md` (just the MIGRATE ones) to the aggregates / services where they live now.

| Rule (ID) | Location in new domain | Source (target_business_rules.md) |
|---|---|---|
| BR-MIGRAR-001 | AGG-Pedido.invariante <name> | BR-MIGRAR-001 |

## Traceability to legacy

| New element | Origin in legacy | Mapping type |
|---|---|---|
| AGG-Pedido | `domain.md § Pedido` + `sdd/orders.md` | fundido |
| <new> | <ref> | 1-to-1 / merged / split / new |

## Notas
<Additional modeling notes.>
