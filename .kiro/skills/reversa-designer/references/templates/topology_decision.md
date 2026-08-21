---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: topology_decision
producedBy: designer
hash: "sha256:<body hash below front-matter>"
---

# Topology Decision

> Conscious decision on how to organize the new system: preserve the legacy topology, adopt a modern topology or apply a hybrid.
> This artifact is mandatory reading by the Designer himself (to decompose bounded contexts) and by the coding agent (to create the folder tree).

## Legacy topology detected
- **Organizational pattern**: <package-by-layer | package-by-feature | feature-sliced ​​| modules per domain | DDD with bounded contexts | monorepo | monolith without clear borders | hybrid: ...>
- **Confidence**: 🟢 CONFIRMED | 🟡 INFERRED | 🔴 GAP | ⚠️ AMBIGUOUS
- **Evidence**:
- <evidence 1, with reference to `reversa/sdd/` artifact (architecture.md, inventory.md, dependencies.md)>
- <evidence 2>
- **Legacy tree map** (summarized):
  ```
<short tree with main folders/modules>
  ```

## Structural diagnosis
- **Coupling**: <high ​​| medium | low, with evidence>
- **Cohesion per module**: <high ​​| average | low, with evidence>
- **Orphaned/dead modules**: <list, or "none">
- **Redundant layers**: <list, or "none">
- **Border Violations**: <list, or "none">
- **Mix of paradigms/styles**: <description, or "homogeneous">
- **Overall assessment**: <healthy | problematic | partially problematic>

## Topologia moderna proposta
- **Pattern**: <hexagonal | vertical slices | feature-sliced ​​| DDD with bounded contexts | package-by-feature | modularization by capability | monorepo with pnpm/turborepo | ...>
- **Justification**: <why this pattern fits the target stack, domain, team size and chosen migration strategy>
- **Ganhos concretos esperados**:
  - <ganho 1: ex. testabilidade isolada por feature>
  - <ganho 2: ex. deploy independente por bounded context>
- <gain 3: e.g. faster onboarding>
- **Custo / risco**:
  - <custo 1: ex. curva de aprendizado da equipe>
- <cost 2: e.g. reorganization effort>
- **Sketch of the proposed tree**:
  ```
<short tree with folders/modules in modern pattern>
  ```

## Options presented to the user
1. **Preservar topologia legada** (conservador)
- Consequences: maintains mental map of the current team; perpetuates possible structural debts; reduces migration risk.
2. **Adotar topologia moderna proposta** (transformacional)
- Consequences: breaks with structural debt; requires learning; maximizes gains from the target stack.
3. **Hybrid** (balanced)
- Consequences: <describe which edges preserve the legacy and which adopt the modern, with justification per edge>

## User decision
- **Escolha**: <1 | 2 | 3>
- **User justification**: <free text>
- **Decidido em**: <ISO-8601>

## Legacy mapping → new
| Legacy module/folder | Bounded context new | Type | Observations |
|---|---|---|---|
| <legacy A> | <new X> | preserved | <obs> |
| <legacy B+C> | <new Y> | cast | <justification> |
| <legacy D> | <new Y1, Y2> | divided | <justification> |
| (empty) | <new Z> | new | <justification> |
| <legacy E> | (discarded) | removed | see `discard_log.md` |

## Pending implications for the Designer’s next steps
| Designer Stage | Implication | How to honor |
|---|---|---|
| Bound contexts | <implication> | <expected action> |
| target_architecture | <implication> | <expected action> |
| target_domain_model | <implication> | <expected action> |
| target_data_model | <implication> | <expected action> |

## Notas
<Any additional points that the encoding agent needs to know to create the folder tree and respect the chosen topology.>
