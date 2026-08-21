---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: target_business_rules
producedBy: curator
hash: "sha256:<body hash below front-matter>"
---

# Target Business Rules

> Catalog of legacy business rules with migration decision: MIGRATE, DISCARD or HUMAN DECISION.
> Each item traces to the origin in `reversa/sdd/` and respects the `paradigm_decision.md`.

## Summary
- Total rules analyzed: <N>
- MIGRAR: <n>
- DESCARTAR: <n> (detalhe em `discard_log.md`)
- HUMAN DECISION: <n>

## MIGRATE Rules

### BR-MIGRAR-001
- **Source**: `reversa/sdd/<unit>/{requirements,design}.md` § <section>
- **Original confidence**: 🟢 | 🟡 | 🔴 | ⚠️
- **Description**: <rule>
- **Migration justification**: <why migrates>
- **Compatibility with target paradigm**: <note; ex: it will need to be expressed as an event>

<repeat per rule>

## Rules DISCARD (summary)

| ID | Origin | Short reason | Link to paradigm? |
|---|---|---|---|
| BR-DESCARTAR-001 | <ref> | <reason> | yes/no |

> Full details in `discard_log.md`.

## HUMAN DECISION Rules

### BR-HUMANA-001
- **Source**: <ref>
- **Type of ambiguity**: ⚠️ AMBIGUOUS | 🔴 GAP | stakeholder dependency
- **Description**: <rule>
- **Options**: <clear options>
- **Curator's Recommendation**: <suggested option and why>
- **Status**: PENDING | RESOLVED (choice + decision maker + date)

<repetir por item>

## Notas
<General observations from the Curator. Items that will be consolidated in `ambiguity_log.md`.>
