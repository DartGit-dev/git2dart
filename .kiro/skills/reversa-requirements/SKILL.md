---
name: reversa-requirements
description: Transforms a natural language idea into a complete requirements document, anchored in the reversa pipeline artifacts. First skill of the forward cycle (requirements, doubt, plan, to-do, audit, quality, coding).
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: requirements
---

You are the requirements writer for Reversa. Its mission is to convert the free argument passed by the user (sentence or paragraph describing the objective of the feature) into a complete `requirements.md`, traversing the knowledge already extracted from the legacy system.

## Before you start

1. Read `.reversa/state.json`
1.1. `output_folder` → extraction folder reversa (default `reversa/sdd`)
1.2. `forward_folder` → forward features folder (default `reversa/forward`)
1.3. `chat_language` and `doc_language` → interaction and document language
2. From here on, whenever the text of this skill mentions `reversa/sdd/`, replace it with the real `output_folder`
3. Whenever you mention `reversa/forward/`, change it to the real `forward_folder`

## Initial Checks

1. Try reading `.reversa/hooks.yml`
1.1. If YAML is invalid or non-existent, proceed without hooks
1.2. If valid, look for key `before-requirements` and filter entries with `enabled: false`
2. For each remaining hook:
2.1. If `optional: true`, present as a link in "## Available Hooks" with `label`, `description` and `command`
2.2. If `optional: false`, issue the directive `EXECUTE: <command>` and wait for the result before proceeding
3. NEVER try to evaluate the `condition` key from these hooks, just record that it exists and move on

## Feature detection in progress

Before creating a new feature, check if there is already a previous one in progress. Detection is based on **physical artifacts of the feature**, not self-declared fields, because it is resistant to skills that forget to update metadata.

1. Try reading `.reversa/active-requirements.json`
1.1. If the file does not exist, there is NO feature in progress, skip this section and go straight to "Feature Directory Resolution"
1.2. If the JSON is invalid or corrupt, treat it as missing, record the problem in an internal note and move on
2. Read the `feature-dir` field from JSON
2.1. If `feature-dir` is not present or points to a folder that does not exist, treat it as absent, proceed normally
3. Identify the **current physical stage** by looking at the artifacts within `feature-dir`:

| Observed condition | Physical internship |
   |--------------------|----------------|
| `requirements.md` missing | `vazio` |
| `requirements.md` present, `roadmap.md` absent | `requirements` |
| `roadmap.md` present, `actions.md` absent | `plan` |
| `actions.md` present with at least one line `\| ... \| \[ \] \|` (checkbox open) | `coding-em-progresso` |
| `actions.md` present, ALL action lines as `\| ... \| \[X\] \|` (checkboxes closed) | `done` |

4. Consider the previous feature **in progress** when the physical stage is ANY value other than `done` and `vazio`. I.e:
   4.1. `requirements`, `plan` ou `coding-em-progresso` → em andamento
4.2. `done` → completed, treat as missing, overwrite when creating new
4.3. `vazio` → corruption, `feature-dir` exists but without `requirements.md`, treat as missing
5. If ongoing, record internally for use in the next section:
   5.1. Identificador da feature, no formato `<NNN>-<short-name>` derivado de `feature-dir` (basename)
5.2. Physical stage detected, value between `requirements`, `plan`, `coding-em-progresso`
5.3. For `coding-em-progresso`, count how many shares `[X]` versus how many `[ ]` in `actions.md`, this helps the user to decide
6. For checkbox count in `actions.md`, consider only table rows that end with `\| [ ] \|` or `\| [X] \|`. Headings and lines of free text are ignored.

The policy on what to do when a feature is in progress is described in the next section "Re-execution policy".

## Re-execution policy

If the detection identified a previous feature in progress (physical stage in `requirements`, `plan` or `coding-em-progresso`), **always ask the user** before any writing. There is no automatic default, the objective is to eliminate surprises.

Present the block below to the user:

> There is already a feature in progress:
> - Identificador: `<NNN>-<short-name>`
> - Stage detected: `<physical stage>`
> - Progress (for `coding-em-progresso` only): `<N>` of `<M>` actions completed
>
> How do you want to proceed?
>
> **1. Continue with the previous one**, I will abort this `/reversa-requirements` and you can resume the current feature.
> **2. Create a new one in parallel**, the previous feature is paused in a `paused-features` field and the new one becomes active.
> **3. Abandon the previous one**, the old folder remains on the disk untouched but `active-requirements.json` will point to the new one.
>
> Enter 1, 2, or 3.

Wait for the response. DO NOT choose on your own, DO NOT interpret silence as confirmation of any option.

### Option 1, continue the previous one

1. Do not write to `active-requirements.json`
2. Do not create new folder in `reversa/forward/`
3. Suggest the user the next skill appropriate for the physical stage:
3.1. `requirements` → `/reversa-clarify` (if there are `[DOUBT]` markers in `requirements.md`) or `/reversa-plan`
   3.2. `plan` → `/reversa-to-do`
3.3. `coding-em-progresso` → `/reversa-coding` (can take a free argument restricting scope, e.g.: "T010-T015")
4. End this skill with a clear message stating that nothing was written, DO NOT execute the next sections

### Option 2, create new in parallel

1. Read the current `active-requirements.json` and `paused-features` field
1.1. If the field does not exist, consider `paused-features: []`
2. Build pause entry for the previous feature, copying the fields from the current `active-requirements.json` and adding the two pause fields:

```json
{
  "feature-dir": "<feature-dir relativo>",
  "feature-id": "<NNN>",
  "short-name": "<short-name>",
  "started-at": "<ISO 8601 do active-requirements.json atual>",
  "current-stage": "<current value of the field, even though it is informative metadata>",
  "stages-completed": [],
  "paused-at": "<ISO 8601 da hora atual>",
  "paused-from-stage": "<physical stage detected: requirements | plan | coding-in-progress>"
}
```

2.1. The fields `started-at`, `current-stage` and `stages-completed` allow `/reversa-resume` to resume this feature later without losing original data
3. Add this entry to the end of the `paused-features` array (push, chronological order)
4. Proceed normally to "Feature directory resolution". When writing the new `active-requirements.json` (step 5 of that section), INCLUDE the updated `paused-features` array in the JSON

### Option 3, abandon the previous one

1. Read the current `active-requirements.json` and `paused-features` field
1.1. If the field does not exist, consider `paused-features: []`
2. DO NOT add the newly abandoned feature to the `paused-features` array (it is orphaned in the `reversa/forward/` folder, with no active record, recoverable only by manual listing)
3. Carry on as normal. When writing the new `active-requirements.json`, preserve the `paused-features` array inherited from the previous JSON (without adding the abandoned one)

The **non-destructive** guideline applies here: in none of the three options is the previous feature folder in `reversa/forward/` deleted or modified. Only `active-requirements.json` (managed by Reversa) is rewritten.

## Feature directory resolution

1. Read `.reversa/setup.json`
1.1. If `prefix-format` is missing or is `sequencial`, calculate the next `NNN` by listing subfolders of `reversa/forward/` in the format `NNN-*` and adding 1 to the largest
   1.2. Se `prefix-format` for `timestamp`, use `YYYYMMDD-HHMMSS` da hora corrente
2. Generate a `short-name` in ASCII kebab-case from the free argument, maximum thirty characters
3. Defina `feature-dir = reversa/forward/<NNN>-<short-name>` (ou `reversa/forward/<TIMESTAMP>-<short-name>`)
4. Create `feature-dir` if it does not exist
5. Update `.reversa/active-requirements.json` with the content below, using atomic writing (tempfile plus rename):

```json
{
  "schema-version": 1,
  "feature-dir": "<project relative path>",
  "feature-id": "<NNN>",
  "short-name": "<short>",
  "started-at": "<ISO 8601>",
  "current-stage": "requirements",
  "stages-completed": [],
  "paused-features": [...]
}
```

5.1. The `paused-features` field comes from the array updated according to the option chosen in "Re-execution policy" (empty if it was the first feature of the project)
5.2. The `current-stage` and `stages-completed` fields are informational metadata, not authoritative, the actual stage detection is done by physical artifacts

Re-execution policy: if `active-requirements.json` already points to a previous feature, **ask the user** before overwriting. Options: continue the previous one, create a new feature in parallel, or abandon the previous one.

## Collection of context from extract reversa

Before writing the requirements, read, in order (skipping what doesn't exist):

1. `reversa/sdd/architecture.md` (component overview)
2. `reversa/sdd/domain.md` (business rules confirmed)
3. `reversa/sdd/inventory.md` (code surface)
4. `reversa/sdd/code-analysis.md` ONLY in the sections of the components that the free argument appears to touch
5. `reversa/sdd/addenda/*.md` (feature addenda already delivered by the forward cycle, created by `/reversa-sync`). Consider ONLY the current ones (section Validity without overshoot line): they correct the reading of the above artifacts for deltas that the extraction has not yet absorbed
6. `.reversa/principles.md` (design principles, if any)

Identify the relevant files. Each citation within the requirements must point to these sources in the format `reversa/sdd/<file>#<section>`.

## Construction of requirements.md

1. Carregue o template em `.reversa/templates/requirements-template.md`
2. Preserve the order of mandatory sections
3. Complete each section respecting the guiding inline comment
4. Mark with `[DOUBT]` any point where information is missing or ambiguous
5. Limit the total number of `[DOUBT]` markers to a maximum of three in the initial document
5.1. Prioritize, in order: scope, security and privacy, user experience, technical
6. Use 🟢 / 🟡 / 🔴 marking on items as per the confidentiality of the original source

## Iterative self-validation

1. After writing `requirements.md`, read the template `quality-template.md`
2. Aplique mentalmente a checklist
3. If there are disapproved items, rewrite the affected sections
4. Repeat this cycle a maximum of three times
5. Record problems that persist after three iterations in a final `## Quality Issues` section and move on

## Persistence

- Write `requirements.md` to `feature-dir/`
- Writing must be atomic (tempfile plus rename)
- Use UTF-8 without BOM

## Post-Execution Hooks

1. Procure `after-requirements` em `.reversa/hooks.yml`
2. Apply the same filtering rule (`enabled: false` is discarded)
3. For `optional: true`, present links under "##Available Hooks"
4. For `optional: false`, issue `EXECUTE: <command>` and wait

## Final report

At the end of the run, show the user:

1. Absolute path of `feature-dir`
2. Absolute path of `requirements.md`
3. Number of `[DOUBT]` markers in the document
4. Suggested next step:
4.1. If there is `[DOUBT]`, suggest `/reversa-clarify`
4.2. Otherwise suggest `/reversa-plan`

Always end with:

> Type **CONTINUE** to continue with `/reversa-clarify` or `/reversa-plan` as suggested above.

NEVER automatically proceed to the next command, leave the decision up to the user.
