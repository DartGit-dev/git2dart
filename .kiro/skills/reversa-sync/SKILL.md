---
name: reversa-sync
description: 'Reversa post-coding convergence: distills the feature delivered in an addendum in `reversa/sdd/addenda/`, maintaining the representative extraction between re-extractions, without touching the original artifacts. Optional forward cycle step after /reversa-coding.'
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: sync
---

You are the synchronizer. Between a delivery of the forward cycle and the next re-extraction `/reversa`, the extraction in `reversa/sdd/` is out of date: the code has already changed, but `architecture.md` and `domain.md` continue to describe the previous system. Your mission is to close this gap by creating an **addendum** per feature delivered in `reversa/sdd/addenda/`, so that whoever reads the extraction (human or agent) can see the system as it is today. The addendum is a bridge: it is valid until the next re-extraction, which will mark it as surpassed.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If absent, abort with message indicating `/reversa-requirements`
2. Check for the existence of `feature-dir/legacy-impact.md`
2.1. If missing, abort: "The active feature has not yet passed `/reversa-coding`, there is no delivery to converge. Run `/reversa-coding` first."
3. Detect delivery scenario:
3.1. **Legacy:** `reversa/sdd/` contains `architecture.md` AND `domain.md`
3.2. **Greenfield:** The header of `legacy-impact.md` records "Feature greenfield", or `reversa/sdd/` contains `prd.md` AND specs in `reversa/sdd/sdd/` (without the legacy anchor)
4. If `feature-dir/actions.md` still has `[ ]` shares open, present the menu before proceeding:

   ```
The active feature still has <N> action(s) open at actions.md.

[1] Partial synchronize: generates the addendum with what has already been delivered, a future re-execution complements it
[2] Wait: close now and return after /reversa-coding closes all actions
[3] Other: describe what you prefer to do
   ```

Wait for the choice. Don't decide alone.
5. Apply `before-sync` in the standard way

## Fontes de leitura

Read, skipping what doesn't exist:

1. `feature-dir/legacy-impact.md` (required, delta main source)
2. `feature-dir/regression-watch.md` (IDs of watch items created)
3. `feature-dir/requirements.md` (feature objective and requirements)
4. `feature-dir/progress.jsonl` (count of actions performed)
5. The extraction artifacts mentioned in `legacy-impact.md`, just to check section names when assembling the pointers

## Addendum generation

Path: `reversa/sdd/addenda/<feature-id>-<short-name>.md` (same name as the feature folder in `reversa/forward/`). Create the `addenda/` folder if it does not already exist.

File structure:

1. Header with title, feature identifier, ISO 8601 date, and scenario (`legacy` or `greenfield`)
2. Section `## Validity` containing, upon creation, a single line:

   ```
   Effective since YYYY-MM-DD.
   ```

The Reversa pipeline then adds `Superseded by the re-extraction of YYYY-MM-DD.` when `/reversa` runs again. An addendum is **effective** while no superseding line exists. Never create an already outdated addendum, and never write that second line yourself.
3. Section `## Delivery summary`: the feature objective in short prose (from `requirements.md`) and the count of completed actions
4. Section `## Impact by extraction artifact`: table `Artifact | Section | Impact type | Delta`
4.1. **Legacy scenario:** derive the lines from `legacy-impact.md`. Components point to `reversa/sdd/architecture.md#<section>`, business rules to `reversa/sdd/domain.md#<section>`. Reuse the English coding taxonomy: `rule-changed`, `rule-removed`, `rule-new`, `component-new`, `component-retired`, `data-delta`, `external-contract-delta`. Accept the legacy Portuguese values when reading existing artifacts.
4.2. **Greenfield scenario:** point to `reversa/sdd/prd.md` and the specs in `reversa/sdd/sdd/`, using type `component-new` and recording the implemented functional requirements
4.3. The `Delta` column describes in one sentence how the artifact should be read now (for example: "rule X now requires Y, see legacy-impact.md of the feature")
5. Section `## Rules under watch`: only the watch item IDs (`W001`, ...) with a pointer to `reversa/forward/<feature>/regression-watch.md`. Do not duplicate the content of watch items
6. Section `## Sources`: relative paths of the feature artifacts used as a base

Writing Policy:

- First run: creates the file (atomic write, tempfile plus rename, UTF-8 without BOM)
- Re-execution for the same feature (for example, after partial synchronization): add an `## Update YYYY-MM-DD` section at the end with the new delta. Never rewrite or delete previous addendum content.
- Never modify `architecture.md`, `domain.md`, `prd.md`, the specs in `sdd/` or any other extraction artifact. The addendum notes, does not correct

## Post-Execution Hooks

Apply `after-sync` in the standard way.

## Final report to the user

1. Absolute path of the created or updated addendum
2. Quantidade de impactos registrados na tabela, quebrados por tipo
3. Detected scenario (legacy or greenfield)
4. Explicit warning: the addendum keeps the extract readable until the next re-extraction. When running `/reversa` again, the regression check will mark this addendum as obsolete and the regenerated extract returns to single source

End with:

> Type **CONTINUE** to proceed with `/reversa-forward` (new feature) or type `/reversa` when you want complete re-extraction.

## Absolute rule

**Never delete, modify or overwrite pre-existing project files.**
This skill ONLY writes to `reversa/sdd/addenda/`. The original extraction artifacts and feature artifacts in `reversa/forward/` are read-only here.
