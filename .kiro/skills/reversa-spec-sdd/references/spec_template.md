# Spec Template — Pragmatic RFC

> Instructions for use: replace all text between `[colchetes]` with the actual content.
> Remove instructions in italics when finished.
> Mark open items with `⚠️ ABERTO:` so you don't forget to resolve them.

---

# Spec: [Nome da Feature]

**Version:** 1.0
**Status:** Draft | Under Review | Approved | Implemented
**Autor:** [Nome]
**Data:** [YYYY-MM-DD]
**Reviewers:** [Nomes ou "N/A"]

---

## 1. Summary

> *1–3 sentences. What is this feature and why does it exist? Read this and you already understand the objective.*

[Concise description of the feature and its purpose.]

---

## 2. Context and Motivation

> *Why are we building this now? What problem or opportunity motivated the decision?*

**Problema:**
[Describe the problem that exists today. Be specific — include real examples if possible.]

**Evidence:**
[Data, feedback, metrics or observations that justify the priority.]

**Por que agora:**
[O que mudou que torna isso urgente ou oportuno.]

---

## 3. Goals (Objetivos)

> *What does this feature need to deliver to be considered a success?*
> *Each goal must be verifiable — if you can't measure it, reformulate it.*

- [ ] G-01: [Objective 1]
- [ ] G-02: [Objective 2]
- [ ] G-03: [Objective 3]

**Success metrics:**
| Metric | Current baseline | Target | Deadline |
|---------|---------------|--------|-------|
| [Ex: Conversion rate] | [X%] | [Y%] | [date] |

---

## 4. Non-Goals (Fora do Escopo)

> *Explicit is better than implicit. Tell us what will NOT be done in this version.*
> *Isso previne scope creep e alinha expectativas.*

- NG-01: [What will not be done]
- NG-02: [What will not be done]
- NG-03: [Future versions may include X, but not now]

---

## 5. Users and Personas

> *Who will use this? What is their context?*

**Primary user:** [Description — e.g. "User logged in with Pro plan, familiar with the platform"]
**Secondary user:** [If any — e.g. "Admin who sets permissions"]

**Current journey (without the feature):**
[Describe in 2–4 steps what the user does today to solve the same problem, or why they can't.]

**Future journey (with the feature):**
[Describe in 2–4 steps what the user will do with the finished feature.]

---

## 6. Functional Requirements

> *The heart of the spec. Each requirement must be: atomic, testable and unambiguous.*
> *Format: RF-XX — [The system / user] must [concrete verb] [complement].*

### 6.1 Requisitos Principais

| ID | Requirement | Priority | Acceptance Criteria |
|----|-----------|-----------|-------------------|
| RF-01 | [The system must...] | Must | [How to test that this is working] |
| RF-02 | [User must be able to...] | Must | [Verifiable condition] |
| RF-03 | [The system must...] | Should | [Verifiable condition] |
| RF-04 | [The system must...] | Could | [Verifiable condition] |

> Priorities: **Must** (required in MVP) / **Should** (important, but negotiable) / **Could** (nice-to-have)

### 6.2 Main Flow (Happy Path)

> *Descreva o fluxo mais comum, passo a passo.*

1. The user [action 1]
2. The system [answer 1]
3. The user [action 2]
4. The system [answer 2]
5. Result: [end state]

### 6.3 Fluxos Alternativos

> *Variations of the main flow that should also work.*

**Fluxo Alternativo A — [Nome]:**
1. [Divergent step from the main flow]
2. [Specific behavior]

---

## 7. Non-Functional Requirements

| ID | Requirement | Target value | Note |
|----|-----------|-----------|------------|
| RNF-01 | Performance | [ex: P95 < 300ms] | [context] |
| RNF-02 | Availability | [ex: 99.9% uptime] | [context] |
| RNF-03 | Security | [ex: mandatory authentication] | [context] |
| RNF-04 | Accessibility | [ex: WCAG 2.1 AA] | [context] |

---

## 8. Design e Interface

> *Describe the behavior of the UI/UX, not the look. Wireframes can be referenced.*

**Affected components:** [List of screens, components or endpoints touched]

**Comportamento esperado:**
[Describe what the user sees and how elements respond to actions.]

**Estados da UI:**
- Empty state: [what to show when there is no data]
- Estado de carregamento: [o que mostrar enquanto processa]
- Error state: [what to show in case of failure]
- Success status: [what to show after completing]

---

## 9. Data Model

> *Only if the feature creates or modifies persisted data.*

**Entidades novas ou modificadas:**

```
[NomeEntidade] {
  campo_1: tipo        // description
  campo_2: tipo        // description
}
```

**Required migrations:** [Yes / No — if yes, describe the impact]

---

## 10. Integrations and Dependencies

| Dependency | Type | Impact if unavailable |
|-------------|------|------------------------|
| [External API / Service / Library] | [Mandatory / Optional] | [Fallback behavior] |

---

## 11. Edge Cases e Tratamento de Erros

> *This section is where specs usually fail. Think about the hard cases.*

| Scenario | Trigger | Expected behavior |
|---------|---------|----------------------|
| EC-01: [edge case name] | [What causes this scenario] | [What the system should do] |
| EC-02: [Invalid input] | [Condition] | [Error/fallback message] |
| EC-03: [Timeout / external fault] | [Condition] | [Retry/degradation/clear error] |
| EC-04: [Rate/quota limit reached] | [Condition] | [Behavior] |

---

## 12. Security and Privacy

- **Authentication:** [Who can access this feature?]
- **Authorization:** [What permissions are required?]
- **Sensitive data:** [Does the feature process PII, financial or confidential data? How are they protected?]
- **Audit:** [Is audit log necessary? What should be logged in?]

---

## 13. Plano de Rollout

- **Strategy:** [Big bang / Feature flag / Gradual rollout / Canary]
- **How ​​to rollback:** [Steps to undo if something goes wrong]
- **Post-deploy monitoring:** [What to watch for in the first 24–48h]

---

## 14. Open Questions

> *Questions not yet resolved that may impact the design. Each item must have an owner and deadline.*

| # | Question | Impact | Owner | Deadline |
|---|---------|---------|------|-------|
| OQ-01 | [Open question] | [High/Medium/Low] | [Name] | [date] |

---

## 15. Decisions Made (Decision Log)

> *Record important decisions and rationale — useful for future reviews.*

| Decision | Alternatives considered | Rational |
|---------|--------------------------|---------|
| [What was decided] | [What was discarded] | [Why this option] |

---

## Appendix

### References
- [Links to docs, tickets, designs, related searches]

### Revision History
| Version | Date | Author | Changes |
|--------|------|-------|---------|
| 1.0 | [date] | [author] | Initial creation |
