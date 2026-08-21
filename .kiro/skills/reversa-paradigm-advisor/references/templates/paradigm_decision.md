---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: paradigm_decision
producedBy: paradigm_advisor
hash: "sha256:<body hash below front-matter>"
---

# Paradigm Decision

> Conscious decision on how to deal with the change (or absence) of paradigm between the legacy and the target stack.
> This artifact is required reading first for any subsequent agent and for the coding agent.

## Legacy paradigm detected
- **Main paradigm**: <procedural | Classic OO | OO with DI | functional | event-driven | actor model | dataflow | hybrid: ...>
- **Confidence**: 🟢 CONFIRMED | 🟡 INFERRED | 🔴 GAP | ⚠️ AMBIGUOUS
- **Evidence**:
- <evidence 1, with reference to artifact from `reversa/sdd/`>
- <evidence 2>
- **Observed variations** (if hybrid):
- <component A: paradigm X, evidence>
- <component B: paradigm Y, evidence>

## Stack alvo declarada
- Language: <do migration_brief.md>
- Framework: <do migration_brief.md>
- Infra: <do migration_brief.md>

## Paradigma natural inferido
- **Paradigma**: <inferido via paradigm_catalog>
- **Justification**: <why this stack has this natural paradigm>
- **Viable alternatives**: <ex: OO with DI is also viable in Node, with cost X>

## Gap identified
- **Severity**: high | medium | bass | none
- **Concrete implications** (not in the abstract; with an example from the legacy system itself):
- <implication 1, citing affected legacy rule/flow>
- <implication 2>
- <implication 3>
- <implication 4>

## Options presented to the user
1. **Adotar paradigma natural da stack** (transformacional)
- Consequences: <list>
2. **Force legacy-like paradigm** (conservative)
- Consequences: <list>
3. **Hybrid** (balanced)
- Consequences: <list>

## User decision
- **Escolha**: <1 | 2 | 3>
- **User justification**: <free text>
- **Decidido em**: <ISO-8601>

## Apetite derivado
- `derived_appetite`: conservative | balanced | transformational

## Pending implications for upcoming agents
| Agent | Implication | How to honor |
|---|---|---|
| Curator | <implication> | <expected action> |
| Strategist | <implication> | <expected action> |
| Designer | <implication> | <expected action> |
| Inspector | <implication> | <expected action> |

## Notas
<Any additional points the coding agent needs to know about the target paradigm.>
