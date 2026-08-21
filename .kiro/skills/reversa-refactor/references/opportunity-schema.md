# Schema of opportunity and transformation

Minimum contract for the artifacts that the Code Quality team writes. Front matter YAML + body in Markdown. Atomic writing (tempfile + rename, UTF-8 without BOM).

## opportunities/<id>.md

```yaml
---
schema_version: 1
id: OPP-<YYYYMMDD>-<suffix> # suffix: 4 base32 chars of title+date hash
display_number: <n> # global human nickname, largest existing + 1
context: <context-slug>
verb: restructure | modularize | decouple | optimize | simplify | standardize | prune
title: <short sentence>
target:
  files: [<path>, ...]
  symbol: <optional: function/class/module>
smell: <code smell or objective reason>
roi:
  confidence: green | yellow | red    # 🟢 coberto e entendido | 🟡 parcial | 🔴 sem prova
  impact: <why it matters: hot path, coupling, risk, clarity>
  cost: low | medium | high
  est_return: <expected return in a sentence>
state: proposed | approved | applied | reverted | declined
traceability:
  soul: [<locator in soul.md>, ...] # soul rules/decisions that touch the target
  specs: [<path#anchor>, ...] # related committed spec sections
---

<description of the opportunity, with what was previously observed and the proposed transformation>
```

## transformations/OPP-.../transformation.md

```yaml
---
schema_version: 1
id: OPP-<...>
verb: <same as opportunity>
state: applied | reverted
safety_net:
  kind: existing | characterization | none
  green_before: true | false
  green_after: true | false
preservation:
  method: tests | equivalence-proof | death-proof | pattern-only
  evidence: [<relative path>, ...]
measurement:                          # required for optimize/decouple/simplify
  before: <complexity/coupling/time before>
  after: <after>
change_set:
  - chg: CHG-001
    file: <path>
    purpose: <o que muda>
approval:
  by: user
  at: <ISO 8601>
reversible_via: [CHG-001.diff, ...]
---

<what was done, by stage, with relative links to the evidence>
```

## Rules

- Confirmed `soul` and `specs` that touch the target are always consulted. Committed business rule is never harmed nor treated as dead code.
- States are monotonic in the audit sense: `declined` and `reverted` preserve the history, never delete the record.
- `prune` only marks `state: applied` with `preservation.method: death-proof` and the attached proof. Suspected orphan gets `proposed` with `promoted_to: null`.
