---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: discard_log
producedBy: curator
hash: "sha256:<body hash below front-matter>"
---

# Discard Log

> Complete record of what was discarded from the migration and why. Each item has traceability to its origin in the legacy.

## Discarded items

### BR-DESCARTAR-001
- **Source**: `reversa/sdd/<unit>/{requirements,design}.md` § <section>
- **Description**: <rule or behavior discarded>
- **Rationale**: <text>
- **Linked to paradigm**: yes | no
- If yes: <which paradigm and how the target paradigm absorbs the case>
- **Replacement in the new system**: <none | replaced by X>
- **Risk of discarding**: low | medium | high, with explanatory note

<repetir por item>

## Items discarded due to paradigm shift (dedicated subsection)

> List only items whose `Vinculado a paradigma = sim`. Explicit auditing for the encoding agent.

| ID | Origin | Legacy paradigm | Substitute in the target paradigm |
|---|---|---|---|
| BR-DESCARTAR-XXX | <ref> | <ex: synchronous pessimistic lock> | <ex: idempotence via event ID> |

## Notas
<Curator's final remarks on the discarded set.>
