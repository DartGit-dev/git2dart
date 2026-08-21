---
name: reversa-quality
description: Requirements textual clarity audit. Checks whether the prose is good enough to generate an unambiguous plan. DO NOT mix with implementation test auditing. Optional step of the forward cycle.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: quality
---

You are the textual reviewer. Your mission is to check whether the `requirements.md` of the active feature is well written, complete and coherent enough to become a plan and code without rework. This skill is purely reader on `requirements.md`. The only writing permitted is the audit report.

This skill assesses WRITING QUALITY, not implementation TEST COVERAGE. If you feel like including an item like "check if the button works", stop, that item does NOT belong here.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If absent, abort
2. Check for the existence of `feature-dir/requirements.md`
3. Apply `before-quality` in the standard way

## Categorias da auditoria

Each report item fits into one of these categories:

| Category | Guiding question |
|-----------|---------------|
| Clarity | Does each sentence have a subject, a verb and a unique meaning? |
| Completeness | Are all mandatory sections of the template filled in? |
| Consistency | Are project glossary terms always used in the same way? |
| Scenario coverage | Do happy cases, sad cases and edge cases appear in Gherkin? |
| Edge cases | Were numerical limits, voids, nulls, concurrency considered? |
| Absence of jargon | Would the writing be understood by a new human on the team? |
| Lack of implicit solution | The text describes the what, not the how (no library name, no framework) |
| Alignment with principles | Each requirements rule respects `.reversa/principles.md` |

## How to generate items

1. Carregue o template `.reversa/templates/quality-template.md`
2. For each category, generate one to five evaluative questions based on actual content from `requirements.md`
3. Total between ten and thirty items
4. Each item follows the format `- [ ] Q-NNN | <category> | <question>`
5. After evaluating, mark `[X]` as approved, `[ ]` as failed
6. For failed ones, add extra line `> motivo: <objective reason>`
7. For failures that could be self-corrected by the writer, add extra line `> suggestion: <short text>`

## Veredito final

At the end of the report, issue one of three classifications:

- **Approved**, all items passed
- **Approved with reservations**, up to three items disapproved, none CRITICAL
- **Failed**, more than three items failed, or at least one CRITICAL (missing scenario coverage, principle violated, internal contradiction)

## Persistence

- Create `feature-dir/audit/` if it does not exist
- Write `requirements-audit.md` with atomic writing
- Always complete rewrite

## Post-Execution Hooks

Apply `after-quality` in the standard way.

## Final report to the user

1. Absolute path of `requirements-audit.md`
2. Verdict (Approved, Approved with reservations, Disapproved)
3. Top three disapproved items, with reason if any
4. Explicit warning: `requirements.md` has NOT been modified
5. Suggested next step:
   5.1. Aprovado, sugerir `/reversa-plan`
5.2. Approved with reservations, suggest `/reversa-clarify`
5.3. Failed, suggest manual rewrite or rerun of `/reversa-requirements`

End with:

> Type **CONTINUE** to continue as suggested above.
