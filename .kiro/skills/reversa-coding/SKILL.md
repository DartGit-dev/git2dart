---
name: reversa-coding
description: 'Executes actions.md in code: checks [X] checkboxes, writes progress.jsonl and generates legacy-impact.md and regression-watch.md. Works anchored in legacy (`reversa/sdd/`) or greenfield (`/reversa-new`). Last step of the forward cycle.'
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: coding
---

You are the executor. Your mission is to transform `actions.md` into real code, phase by phase, respecting parallelism and dependencies. When finished, leave two traces for future auditing: `legacy-impact.md` (what was changed in the legacy) and `regression-watch.md` (what needs to remain true in the next extractions).

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Context anchor: legacy or greenfield

This skill **REQUIRES** a context anchor in `reversa/sdd/`, otherwise the two central artifacts (`legacy-impact.md` and `regression-watch.md`) lose their value and the forward cycle becomes any generic framework. Two anchors are valid:

1. **Legacy:** `reversa/sdd/` contains `architecture.md` AND `domain.md` (Discovery Team extraction via `/reversa`). Classic behavior.
2. **Greenfield:** `reversa/sdd/` contains `prd.md` AND at least one spec in `reversa/sdd/sdd/` (artifacts from `/reversa-new`). New project is a valid case, the pipeline does not block due to lack of extraction. Skill artifacts adapt as described in the generation sections.

If two anchors exist (project that ran `/reversa` and `/reversa-new`), use the legacy one as the main one and the SDD specs as a complement.

The check remains strict when NO anchor exists: the skill aborts with a clear message, does NOT offer an option to continue anyway, does NOT write anything to disk.

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If absent, abort with message indicating `/reversa-requirements`
2. Check for the existence of `feature-dir/actions.md`
2.1. If absent, abort with message indicating `/reversa-to-do`
3. Check the context anchor:
3.1. **Legacy anchor:** `reversa/sdd/` exists AND contains `architecture.md` AND `domain.md`. If satisfied, register the scenario internally as **legacy** and go to step 4.
3.2. **Greenfield anchor:** `reversa/sdd/` exists AND contains `prd.md` AND at least one file `.md` in `reversa/sdd/sdd/`. If satisfied (and the legacy one is not), register the scenario as **greenfield**, inform the user ("Without legacy extraction, I will anchor it to the `/reversa-new` artifacts: `prd.md` and SDD specs.") and go to step 4.
3.3. If NONE of the two anchors are satisfied, abort with the message:

> 🛑 `/reversa-coding` requires a context anchor in `reversa/sdd/` and I didn't find one:
       >
> - **Legacy:** `architecture.md` + `domain.md` (manages with `/reversa`)
> - **Greenfield:** `prd.md` + specs in `sdd/` (manages with `/reversa-new`)
       >
> Without this context, `legacy-impact.md` and `regression-watch.md` would be left without an anchor and the forward cycle would lose its differential. Run one of the two pipelines and come back here.

3.4. In the case of step 3.3, DO NOT create `legacy-impact.md`, DO NOT create `regression-watch.md`, DO NOT touch `actions.md`, DO NOT write `progress.jsonl`. Just report and close.

4. Apply `before-coding` in the standard way

## Escopo da rodada

1. If the free argument indicates phase or range of IDs (e.g.: "only Core", "T001-T005"), restrict execution to that scope
2. Otherwise, execute in order all `[ ]` actions not yet completed

## Execution loop per phase

For each phase, in the order Preparation, Testing, Core, Integration, Polishing:

1. Select all phase actions with status `[ ]`
2. Calculate the independent set (actions without open dependency)
3. For the independent assembly, identify subassembly marked `[//]`
3.1. Execute this sub-set thinking of each action as a coherent block, but report separately
4. Perform the remaining actions in the set sequentially
5. After each action:
5.1. Update `feature-dir/actions.md` by changing `[ ]` to `[X]`
5.2. Write line in `feature-dir/progress.jsonl` with ISO 8601 timestamp, action ID, end status, played files
6. If an action fails:
6.1. Keep `[ ]` in actions
6.2. Register `status: failed` in progress
6.3. Stop the phase and report to the user

## Generation of legacy-impact.md

After executing (even partially):

**Greenfield scenario:** there is no legacy to impact. Generate the file anyway, with adaptations: map each created file to the corresponding component of the specs in `reversa/sdd/sdd/` (instead of `architecture.md`), use the impact type `componente-novo` for everything, and record in the header: "Greenfield feature, no pre-existing legacy. Anchor: prd.md + SDD specs." The "Preserved" and "Modified" sections are empty with this note. Skip steps 4 and 5 below.

**Legacy scenario:**

1. For each project file played, map it to the corresponding component in `reversa/sdd/architecture.md` when possible
2. For each affected component, classify the impact type as `rule-changed`, `rule-removed`, `rule-new`, `component-new`, `component-retired`, `data-delta`, or `external-contract-delta`.
3. Assign severity in line with `/reversa-audit` (CRITICAL, HIGH, MEDIUM, LOW)
4. List rules 🟢 from `reversa/sdd/domain.md` that remain intact (go to the "Preserved" section)
5. List rules 🟢 that have been changed or removed (go to the "Modified" section)

File structure:

1. Header with date and feature identifier
2. Table `Affected file | Component | Type | Severity | Rationale`
3. Diff conceitual por componente, em prosa
4. "Preserved" Section
5. "Modified" Section

Write to `feature-dir/legacy-impact.md` with atomic writing, full rewrite.

## Generation of regression-watch.md

**Greenfield scenario:** there are no rules 🟢 to watch (nothing has been extracted from existing code yet). Generate the file with the default structure, empty main watch, and record the implemented RFs (from SDD specs) in the "Observations" section, without regression weight. They gain weight when a future `/reversa` extraction on the new code confirms them as 🟢. Skip steps 1 to 4 below (step 5, stable IDs, applies to observations).

**Legacy scenario:**

1. For each rule in the "Modified" section of `legacy-impact.md`, generate a watch item
2. For explicitly removed rules, generate a watch item of type `absence`
3. For changed rules, generate a watch item of type `wording` or `presence`, as appropriate
4. For rules with lowered confidence, generate a watch item of type `confidence`
5. Assign stable ID `W001`, `W002`, ..., recycling old file IDs if already exists

Estrutura:

1. Header with feature identifier
2. Table `ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal`
3. "Re-extraction history" section initially empty, will be filled by the reverse agent when running `/reversa` again
4. "Archived" section initially empty

NEVER include rules that were originally 🟡 or 🔴 in the main watch, these go to an "Observations" section without regression weight.

Write to `feature-dir/regression-watch.md`. The first run creates the file; subsequent executions append to new item sections, never rewriting history or old IDs.

## Update progress.jsonl

Each line must have, at a minimum:

```json
{"ts":"2026-05-05T16:30:00Z","action":"T003","status":"done","files":["src/x/y.js"]}
```

Append-only. Never rewrite previous lines, even if you discover that they were wrong. To fix, add new line `status: corrected` with target ID.

## Post-Execution Hooks

Apply `after-coding` in the standard way.

## Final report to the user

1. How many actions performed successfully
2. Quantas falharam (se houver)
3. Absolute path of `actions.md`, `progress.jsonl`, `legacy-impact.md`, `regression-watch.md`
4. How many watch items were created in this round
5. Explicit warning: run `/reversa-sync` to converge the delivery on `reversa/sdd/addenda/` and keep on the radar to run `/reversa` (re-extraction) again at some point in the future to close the loop
6. If execution was partial, indicate the next phase or pending action

NEVER trigger re-extraction alone, this is the user's decision.

End with:

> Type **CONTINUE** to proceed with `/reversa-sync` (convergence of delivery in extraction) or other action that the user wants.
