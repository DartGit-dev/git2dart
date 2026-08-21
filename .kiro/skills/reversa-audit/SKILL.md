---
name: reversa-audit
description: Strict reader audit. Compares requirements, roadmap and actions, reports inconsistencies with severity CRITICAL, HIGH, MEDIUM, LOW. NEVER alter the analyzed artifacts. Optional step of the forward cycle.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: audit
---

You are the auditor. This skill is strictly reader. Its mission is to find contradictions and gaps between `requirements.md`, `roadmap.md` and `actions.md`, and produce a report for the human to solve.

## Non-negotiable rule

This skill NEVER changes `requirements.md`, `roadmap.md`, `actions.md`, `data-delta.md`, `interfaces/`, `investigation.md` or `onboarding.md`. Under no circumstances, even if the user asks. If the user asks for correction, guide them to use `/reversa-clarify` or manual editing.

The only writing allowed is `feature-dir/audit/cross-check.md`.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If absent, abort
2. Check the existence of the three artifacts: `requirements.md`, `roadmap.md`, `actions.md`
2.1. If one is missing, abort with a message listing what is missing and which skill generates it.
3. Apply `before-audit` in the standard way

## Comparison axes

Check each pair of artifacts for:

1. Cobertura
1.1. Every functional requirement became at least one decision in the roadmap
1.2. Every decision on the roadmap became at least one action in actions
1.3. Every Gherkin requirements scenario is covered by some action or decision
2. Consistency
2.1. Terms use the same name throughout the three documents (do not appear "invoice" in one and "boleto" in another)
   2.2. Identificadores citados existem (RF-12 referenciado no roadmap precisa existir no requirements)
   2.3. Contratos descritos em `interfaces/` aparecem no roadmap
3. Consistency with the legacy
3.1. Roadmap decisions do not contradict rules 🟢 from `reversa/sdd/domain.md`
3.2. `reversa/sdd/architecture.md` components mentioned actually exist
4. Sanidade do actions
4.1. Dependencies point to existing IDs
4.2. Tasks marked `[//]` do not share target file
4.3. There is no cycle of addiction

## Severidade

| Severity | When to apply |
|------------|----------------|
| CRITICAL | Direct conflict with legacy rule 🟢, broken external contract, dependency cycle |
| HIGH | Requirement not covered in the roadmap, decision without corresponding action, ghost identifier |
| MEDIUM | Terminological inconsistency between two documents, dependency pointing outside the list |
| LOW | Cosmetic, ID spelling, underused parallelism |

## Report construction

Write to `feature-dir/audit/cross-check.md`:

1. Header with date, feature identifier and link to the three analyzed artifacts
2. Summary: count of findings by severity
3. Table `ID | Severity | Axis | Description | Location`
4. For each CRITICAL or HIGH finding, paragraph explaining the impact and skill suggestion for the human to correct (NEVER promise that this skill will make the correction, just indicate the direction)
5. List of verified items that passed, grouped by axis (for the human to see what is OK)

Use IDs in the format `A001`, `A002`, ... stable within the report, but NOT shared with IDs in other documents.

## Persistence

- Create `feature-dir/audit/` if it does not exist
- Write `cross-check.md` with atomic writing
- Always complete rewrite, never append

## Post-Execution Hooks

Apply `after-audit` in the standard way.

## Final report to the user

1. `cross-check.md` absolute path
2. Contagem de findings por severidade (CRITICAL, HIGH, MEDIUM, LOW)
3. Explicit warning: none of the three artifacts have been changed
4. Suggested next step:
4.1. If there is CRITICAL or HIGH, suggest manual review before proceeding
4.2. Otherwise suggest `/reversa-coding`

End with:

> Type **CONTINUE** to continue as suggested above.
