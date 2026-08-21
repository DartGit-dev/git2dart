# Specs Evaluation Rubric

Used by `scripts/spec_scorer.py` and as a manual review guide.

Score total: **0–100 pontos**

---

## Dimension 1: Completeness (30 points)

Assess whether all essential sections are present and completed.

| Criterion | Points | How to check |
|----------|--------|----------------|
| Sections 1–6 all present and completed (not just headers) | 10 | Each section has ≥ 2 sentences or 1 list item |
| Functional Requirements with IDs (RF-XX) | 8 | At least 3 numbered requirements |
| Acceptance criteria defined for each RF Must | 7 | "Acceptance Criteria" column filled in |
| Explicit Non-Goals (section 4) | 5 | At least 2 non-goals listed |

**Penalidades:**
- Mandatory section completely missing: -5 per section
- Section with unfilled placeholder (`[colchetes]`): -2 per occurrence

---

## Dimension 2: Testability (25 points)

Evaluates whether a QA can write tests from the spec without asking questions.

| Criterion | Points | How to check |
|----------|--------|----------------|
| Requirements use concrete and measurable verbs | 10 | Absence of "it must be good", "it must be fast", "it must be intuitive" |
| Main flow (happy path) described step by step | 8 | Section 6.2 with ≥ 3 steps |
| Success metrics with numerical values ​​| 7 | Section 3 has at least 1 metric with numeric target |

**Penalidades:**
- Untestable requirement ("the system must be easy to use"): -3 per occurrence
- Missing happy path: -8

---

## Dimension 3: Clarity (20 points)

Evaluates whether the language is precise and unambiguous.

| Criterion | Points | How to check |
|----------|--------|----------------|
| Absence of vague terms without definition | 8 | "quickly", "soon", "many", "some" worthless — -2 each |
| Open Questions marked with ⚠️ or in section 14 | 6 | Ambiguities are explicit, not silent |
| Clear subject in each requirement ("the system", "the user") | 6 | There are no requirements without an identified subject |

**Penalidades:**
- Contradiction between requirements: -5 per contradiction
- Technical term without definition for non-technical audience: -2 per occurrence

---

## Dimension 4: Scope (15 points)

Evaluates whether the feature limits are clear.

| Criterion | Points | How to check |
|----------|--------|----------------|
| Clear and useful Non-Goals section (4) | 7 | At least 2 non-goals that prevent real scope creep |
| Mapped dependencies and integrations (section 10) | 5 | All external dependencies are listed |
| Present rollout/rollback plan (section 13) | 3 | Strategy and how to reverse defined |

**Penalidades:**
- Vague non-goals ("future features"): -2 per occurrence
- Unmapped critical dependency: -3

---

## Dimension 5: Edge Cases (10 points)

Evaluates whether difficult cases were anticipated.

| Criterion | Points | How to check |
|----------|--------|----------------|
| At least 3 edge cases listed (section 11) | 5 | Table with ≥ 3 filled lines |
| Error handling with defined message/behavior | 3 | Each error has expected behavior |
| External dependency failure cases covered | 2 | At least 1 EC for timeout/unavailability |

**Penalidades:**
- Zero edge cases: -10 (this section resets)
- Edge case without defined behavior: -1 per occurrence

---

## Classification by Score

| Score | Classification | Meaning |
|-------|--------------|-------------|
| 90–100 | ⭐ Excellent | Ready for immediate implementation |
| 80–89 | ✅ Good | Ready with minor adjustments |
| 65–79 | ⚠️ Adequate | Implementable but with risks |
| 50–64 | 🔶 Incomplete | Needs review before implementing |
| < 50 | ❌ Insufficient | Back to interview/draft |

---

## Quick Review Checklist

Before marking a spec as "Approved", confirm:

- [ ] Can any dev implement it without asking anything?
- [ ] Can any QA write tests without asking anything?
- [ ] Are non-goals as clear as goals?
- [ ] Does every error case have a defined behavior?
- [ ] Do all requirements have traceable IDs?
- [ ] Are there no contradictions between requirements?
- [ ] Are open questions documented (not silent)?
- [ ] Are success metrics numerical and verifiable?
