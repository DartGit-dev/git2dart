# Guia de Metodologia — Spec-Driven Development

## What is SDD?

Spec-Driven Development is the practice of writing a detailed specification of behavior **before** writing any code. The spec responds to **what** the system should do — not **how** to implement it.

Not to be confused with:
- **TDD** (Test-Driven Development): writes tests before code — complementary to SDD
- **DDD** (Domain-Driven Design): architectural pattern — independent of SDD
- **BDD** (Behavior-Driven Development): focus on behaviors with Gherkin — a subset of SDD

---

## Fundamental Principles

### 1. Behavior, not Implementation

The spec describes the observable behavior, not the internal implementation.

❌ Bad: "The system must use Redis to cache sessions"
✅ Good: "The system must keep the user's session active for 30 days on devices where they have checked 'remember me'"

The implementation (Redis, JWT, database) is a technical decision for the implementer — not the spec.

### 2. Ambiguidade = Bug Futuro

Every ambiguity in the spec becomes a bug, an alignment meeting, or a PR discussion in the future. Make ambiguities explicit with `⚠️ ABERTO:` — a visible open item is better than a silent assumption.

### 3. Non-Goals are as important as Goals

"What we won't do" prevents scope creep, aligns expectations and accelerates decisions. A feature without non-goals tends to grow indefinitely.

### 4. The Spec is a Living Contract

The spec changes as understanding evolves — and that's healthy. What matters is that the changes are recorded (Decision Log) and that all stakeholders are aligned with the current version.

### 5. LLM-Readiness

A good modern spec should be readable by LLMs that will help implement it. This means:
- Numbered requirements (traceable IDs)
- Explicit, not implicit, behaviors
- Documented edge cases (LLMs don't guess edge cases)
- Business context included (the “why” helps you make good implementation decisions)

---

## O Ciclo SDD

```
Ideia/Problema
      ↓
  Entrevista  ←──────────────────────┐
      ↓                              │
  Rascunho da Spec                   │
      ↓                              │
Assessment (Score) │
      ↓                              │
  Score < 80? ──── Sim ──── Identificar gaps
↓ No
Spec Approved
      ↓
Implementation
      ↓
Spec vs. Code (final validation)
```

---

## When to Write the Spec

| Feature size | Recommendation |
|-------------------|--------------|
| Bug Fix | No spec needed |
| Small improvement (< 1 dev day) | Minimum spec: goals + main requirements |
| New Feature (1–5 days) | Spec complete but concise |
| Complex feature (> 5 days) | Spec complete + review by 2+ people |
| New system | Architecture spec + feature specs |

---

## Prioridades de Requisitos (MoSCoW)

| Priority | Meaning | Decision if it does not fit within the deadline |
|-----------|-------------|-------------------------------|
| **Must** | Mandatory — without it it won't launch | Blocks the launch |
| **Should** | Important — but there is workaround | Postpone to next version |
| **Could** | Nice-to-have | Discard if necessary |
| **Won't** | Consciously out of scope | Documents as Non-Goal |

---

## Common Antipatterns

### "Spec like a PRD de grande empresa"
50-page specs that no one reads. Prefer concise specs that cover the essentials clearly.

### "Spec as technical task list"
"Create users table, add POST /auth endpoint, integrate with OAuth..." — this is an implementation plan, not a spec. The spec talks about behavior.

### "Spec verbal / em Slack"
Decisions made in unrecorded conversations are lost and generate conflicts. Every spec must exist as a written document.

### "Spec que nunca muda"
Frozen specs that do not reflect the reality of what was implemented. The spec must be updated when the implementation intentionally diverges.

### "Open Questions silenciosas"
Assume answers to unanswered questions. Always use `⚠️ ABERTO:` and resolve before implementing.

---

## SDD Vocabulary

| Term | Definition |
|-------|-----------|
| **Spec** | Document that describes the expected behavior of a feature |
| **RF** | Functional Requirement — what the system must do |
| **RNF** | Non-Functional Requirement — how the system should behave (performance, security...) |
| **Goal** | Objective that the feature must achieve |
| **Non-Goal** | What is explicitly out of scope |
| **Edge Case** | Limit or non-obvious case that the system must handle correctly |
| **Happy Path** | The main and most common flow of use |
| **Acceptance Criteria** | Verifiable condition that defines when a requirement is implemented |
| **Open Question** | Unresolved question that could impact the design |
| **Decision Log** | Record of important decisions and why they were taken |
