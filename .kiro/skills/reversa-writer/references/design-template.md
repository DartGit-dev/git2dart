# [Unit Name], Technical Design

> Template file `design.md`. Focuses on HOW the unit is built, based on the legacy code read.

## Interface
[Inputs, outputs, parameters, data types]

For HTTP endpoints:

| Method | Path | Entrance | Output | Status codes |
|--------|---------|---------|-------|--------------|
| GET | `/recurso/:id` | `id: string` | `Recurso` | 200, 404 |
| POST | `/recurso` | `RecursoCreate` | `Recurso` | 201, 400, 409 |

For classes/functions:

| Symbol | Subscription | Return | Note |
|---------|-----------|---------|------------|
| `NomeDaClasse.metodo` | `(arg1: T, arg2: U)` | `V` | [Detalhe relevante] |

## Main Stream
1. [Step 1, with reference to the legacy file when applicable]
2. [Passo 2]
3. [Passo N]

## Fluxos Alternativos
- **[Special condition]:** [behavior]
- **[Error case]:** [behavior]

## Dependencies
- [Component X], [reason, how to use]
- [Service Y], [reason, how to use]

## Design Decisions Identified

| Decision | Evidence in the code | Trust |
|---------|---------------------|-----------|
| [ex: persistence via Prisma with soft-delete] | `prisma/schema.prisma:42` | 🟢 |
| [ex: in-memory cache with TTL of 5min] | `cache/store.ts:18` | 🟡 |

## Estado Interno
[If the unit maintains state, describe which fields, where they are stored, how they evolve]

## Observabilidade
[Logs, metrics, traces issued by the unit, with reference to the code]

## Riscos e Lacunas
- 🔴 [Behavior that could not be inferred from the code, requires human validation]
- 🟡 [Assumption that may be wrong]
