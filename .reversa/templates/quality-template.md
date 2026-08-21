<!--
Template de corpo do requirements-audit.md
Carregado por /reversa-quality.

COMPLETION RULES:
- Total between ten and thirty items. Less is shallow, more is noise.
- Each item has stable Q-NNN ID within this report.
- Allowed categories: Clarity, Completeness, Consistency, Coverage, EdgeCases, Jargon, Implicit Solution, Principles.
- Disapproved items get an extra line "> reason: ..." and, when applicable, "> suggestion: ...".
- THIS COMMAND EVALUATES WRITING QUALITY. Don't include implementation test items ("check if the button works", etc.).
-->

# Requirements Audit

> Identificador da feature: `<NNN>-<short-name>`
> Data: `YYYY-MM-DD`
> Audited document: `<feature-dir>/requirements.md`

## Summary

| Metric | Value |
|---------|-------|
| Total items | <NN> |
| Aprovados | <NN> |
| Reprovados | <NN> |
| Verdict | Approved / Approved with reservations / Failed |

## Items by category

### Clareza

- [ ] Q-001 | Clarity | Each requirements sentence has an explicit subject, verb and object
- [ ] Q-002 | Clarity | There are no sentences beginning with "maybe", "probably" or "if possible" without numerical qualification
- [ ] Q-003 | Clarity | Project glossary terms are defined on first occurrence

### Completude

- [ ] Q-004 | Completeness | All required sections of the template are filled with content, not placeholders
- [ ] Q-005 | Completeness | Each Functional Requirement has verifiable acceptance criteria
- [ ] Q-006 | Completeness | There are Gherkin scenarios for happy cases AND negative cases

### Consistency

- [ ] Q-007 | Consistency | Key domain terms appear with the same spelling in all sections
- [ ] Q-008 | Consistency | IDs cited in a section exist in the section that defines them
- [ ] Q-009 | Consistency | Confidence (🟢 / 🟡 / 🔴) consistent with the source cited from `reversa/sdd/`

### Cobertura

- [ ] Q-010 | Coverage | Every Functional Requirement has at least one Gherkin scenario
- [ ] Q-011 | Coverage | Every new or changed Business Rule cites the original `reversa/sdd/domain.md` rule when applicable

### EdgeCases

- [ ] Q-012 | EdgeCases | Relevant numerical limits have concrete value (not "many", "few")
- [ ] Q-013 | EdgeCases | Empty, null and initial states were considered
- [ ] Q-014 | EdgeCases | Competition, retry and timeout were considered when applicable

### Jargon

- [ ] Q-015 | Jargon | A new human on the team would understand the requirements without a glossary
- [ ] Q-016 | Jargon | Acronyms are expanded upon first occurrence

###Implicit Solution

- [ ] Q-017 | Implicit Solution | Requirements describe the what, not the how
- [ ] Q-018 | Implicit Solution | There is no name of a library, framework or commercial product in the document

### Principles

- [ ] Q-019 | Principles | Each Business Rule respects the active principles in `.reversa/principles.md`
- [ ] Q-020 | Principles | Conflicts with principles are explicitly recorded, not hidden

## Rejected items, detail

<!--
For each item marked [ ] after evaluation, repeat the ID and add reason + suggestion.
For items [X] do not write anything here.
-->

### Q-NNN

> reason: <objective reason, one to two sentences>
> suggestion: <short text that the author could apply>

## Veredito

<!--
Choose ONE of the three:
- Approved: zero disapprovals.
- Approved with reservations: up to three disapprovals, none CRITICAL.
- Failed: more than three failures OR at least one CRITICAL.

CRITICAL items: missing coverage, principle violated, internal contradiction between sections.
-->

**Approved / Approved with reservations / Failed**

## Change history

| Date | Amendment | Author |
|------|-----------|-------|
| YYYY-MM-DD | Auditoria gerada por `/reversa-quality` | reversa |
