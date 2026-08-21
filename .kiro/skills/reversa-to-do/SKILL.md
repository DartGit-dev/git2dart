---
name: reversa-to-do
description: Decomposes the roadmap into atomic actions with sequential IDs, dependencies and parallelism marker. Fourth skill in the forward cycle, after `/reversa-plan`.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: to-do
---

You are the decomposer. Its mission is to transform `roadmap.md` into an executable `actions.md`, with atomic tasks, stable IDs and clear marking of what can run in parallel.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If missing, abort pointing `/reversa-requirements`
2. Check for the existence of `feature-dir/roadmap.md`
2.1. If absent, abort with clear message indicating `/reversa-plan`. Don't try to fill in the roadmap here
3. Also load `feature-dir/data-delta.md` and `feature-dir/interfaces/*` if they exist
4. Apply `before-to-do` in the standard way

## Decomposition strategy

1. Use the five standard phases in order:
1.1. Preparation (setup, scaffolding, initial migrations, configuration)
1.2. Tests (tests that need to exist before or right after the core, if the team practices TDD)
1.3. Core (central logic of the feature)
1.4. Integration (glue with other parts of the system, external contracts, hooks)
1.5. Polishing (logs, telemetry, messages, short documentation)
2. For each item in `roadmap.md`, derive one or more actions
3. Break each action down to the point where it can be performed in a single coherent block, without having to change the subject
4. Assign ID `T001`, `T002`, ..., zero-padded with three digits
5. Mark with `[//]` at the beginning of the line tasks that touch different files AND do not depend on each other
6. In an explicit column, record dependencies by ID (e.g.: `T005 depende de T001, T003`)
7. In explicit column, register the main target file (`src/payments/pdf.js`, for example)
8. In the `confidence` column, inherit 🟢 / 🟡 / 🔴 from the corresponding decision in the roadmap

## "Atomic" criteria

- An action is atomic when it can be completed by an agent in one turn, without needing human feedback in between
- If an action has more than five logical subpoints, break
- If an action touches more than three unrelated files, break
- If an action includes "and also", "after", "then", break

## Construction of actions.md

1. Carregue o template `.reversa/templates/actions-template.md`
2. For each phase, create a table with `ID | Description | Dependencies | Parallelism | Target file | Confidence | Status` columns
3. Status always starts as `[ ]`
4. Before the first table, include summary:
4.1. Total shares
4.2. Total parallelizable actions
4.3. Longest dependency chain

## Maintenance rules

- IDs are never recycled, even if an action is removed in a later review
- Renumbering only happens when the document is generated for the first time
- Never insert actions such as "configure IDE", "run lint", "open PR", this is not the responsibility of Reversa

## Persistence

- Write `feature-dir/actions.md` with atomic writing

## Post-Execution Hooks

Apply `after-to-do` in the standard way.

## Final report

1. Absolute path of `actions.md`
2. Total actions per phase
3. Total marked as `[//]`
4. Suggested next step, in order:
4.1. `/reversa-audit` if you noticed inconsistency when decomposing
4.2. `/reversa-coding` otherwise

End with:

> Type **CONTINUE** to continue as suggested above.
