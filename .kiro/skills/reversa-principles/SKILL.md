---
name: reversa-principles
description: Creates or updates the project's lasting principles and propagates adjustment suggestions to dependent templates. Principles are rare, change little, and influence all artifacts. It can run even before the first feature.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: principles
---

You are the guardian of principles. This skill deals with lasting project rules, separate from the specific requirements of each feature. Principles change little and influence all other artifacts.

This skill is rare, typically less than once a month. It is NOT part of the `requirements`, `plan`, `to-do`, `coding` pipeline. It can run alone, even before the first feature.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Try reading `.reversa/principles.md`
1.1. If absent, mode is `criar`
1.2. If present, mode is `atualizar`
2. Apply `before-principles` in the standard way

## Create mode

1. Carregue `.reversa/templates/principles-template.md`
2. Ask the user for candidate principles, in batch or one by one
3. For each principle:
3.1. Assign sequential Roman numerals (I, II, III, ...)
3.2. Ask for short title, description and a concrete application example
3.3. Record creation date
4. List, in the "Impact" section, which templates will be affected when the principle changes (always `requirements-template.md`, `roadmap-template.md`, and potentially `actions-template.md`)
5. Start the "Change History" section with the initial entry

## Update mode

1. Present the user with the current list of numbered principles
2. Ask which operation he wants:
2.1. Add new (continues in the next roman numerals, never recycles)
2.2. Change text from an existing one (maintains numbering, records change in history)
2.3. Retire one (DO NOT delete, mark as `aposentado em YYYY-MM-DD` and move to the end of the document)
3. After operation:
3.1. Update the "Impact" section if necessary
3.2. Add entry to "Change History"

## Impact Propagation

1. For each template listed in the "Impact" section:
1.1. Read the template at `.reversa/templates/<name>`
1.2. Check if the template needs a new placeholder or section to reflect the principle
1.3. NEVER rewrite the entire template automatically, only generate an impact report in `.reversa/principles-impact-YYYYMMDD.md`
2. The report lists, by template, textual adjustment suggestions
3. Applying these suggestions is a human decision, this skill only suggests

## Persistence

- Write `.reversa/principles.md` with atomic writing
- Save the impact report to `.reversa/principles-impact-YYYYMMDD.md`
- Never overwrite old impact reports, each run creates a dated file

## Post-Execution Hooks

Apply `after-principles` in the standard way.

## Final report to the user

1. Absolute path of `principles.md`
2. List of active ingredients, with numbering and short title
3. List of retired principles, if any
4. Path of the generated impact report
5. Warning: new or changed principles will only be valid for features started after this date

End with:

> Type **CONTINUE** to proceed with the next desired action.
