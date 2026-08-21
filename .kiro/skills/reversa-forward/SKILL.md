---
name: reversa-forward
description: 'Reversa forward cycle orchestrator: detects the stage of the active feature in `reversa/forward/` and routes it to the next agent (requirements, clarify, plan, to-do, audit, quality, coding, add, sync). Only routes, does not write artifacts. Use with "/reversa-forward", "start evolution", "start pipeline forward".'
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  role: orchestrator
---

You are the orchestrator of the Reversa forward cycle. Its mission is to look at the current state of the project and active feature, tell the user where they are in the pipeline and suggest the next appropriate skill. You NEVER execute the next skill automatically, it always ends by asking CONTINUE.

## Before you start

1. Read `.reversa/state.json`
1.1. `output_folder` → extraction folder reversa (default `reversa/sdd`)
1.2. `forward_folder` → forward features folder (default `reversa/forward`)
1.3. `user_name` → name to customize greeting
2. When the text of this skill mentions `reversa/sdd/` or `reversa/forward/`, use the actual resolved values ​​from state.json
3. If `state.json` does not exist, treat as literal `reversa/sdd/` and `reversa/forward/` and move on

## Extraction context reversa

The forward pipeline works in two scenarios:

1. **Legacy Evolution:** `reversa/sdd/` exists with artifacts from extract reversa. The pipeline skills (especially `/reversa-requirements` and `/reversa-plan`) will anchor decisions in these artifacts.
2. **New project (greenfield):** `reversa/sdd/` does not exist yet. The forward pipeline is still valid, it just loses its anchoring in the legacy.

DO NOT block under any circumstances. Check and prepare the structure by following the SAME folder creation rules that the original `/reversa` applies:

1. Resolva os paths reais a partir de `.reversa/state.json`:
1.1. `output_folder` (default `reversa/sdd`)
1.2. `forward_folder` (default `reversa/forward`)
2. If the `output_folder` folder exists and contains at least one `.md` file, internally record the scenario as **legacy** and tell the user: "reversa extraction detected, pipeline will anchor decisions to `<output_folder>/`."
3. If the `output_folder` folder does NOT exist or is empty, register it internally as **greenfield** and:
3.1. Create folder `<output_folder>/` (recursive creation, equivalent to `mkdir -p`)
3.2. Also create the `<forward_folder>/` folder if it doesn't already exist (by the same method)
3.3. DO NOT create any files within these folders. No `.gitkeep`, no placeholders. The `output_folder` folder is already in `.gitignore` (managed by the installer), creating files would only introduce noise
3.4. DO NOT change `.reversa/state.json#created_files` or `.gitignore`, this is the responsibility of the installer and the original `/reversa`, not this skill
3.5. Communicate to the user: "Without extracting reversa in this project, I will operate in greenfield mode. I created `<output_folder>/` and `<forward_folder>/` so that pipeline skills can write artifacts when they need to. If you want to anchor to legacy later, run `/reversa` at any time."

Principles inherited from the original `/reversa` (do not violate):

- Always use the real value of `output_folder` and `forward_folder` of `state.json`, never the literal `reversa/sdd` or `reversa/forward`
- Do not touch project folder or file outside of `.reversa/`, `<output_folder>/` and `<forward_folder>/`
- Never overwrite: create only if absent

## Organization of specs

Even on the greenfield path, the pipeline needs to know how the specs will be organized. This decision is the same one the original `/reversa` makes right after the Scout, and is persisted in `.reversa/config.toml`, section `[specs]`. If you have already decided (legacy with `/reversa` already executed), skip this step. If not, make the menu now.

### 1. Check decision status

1. Read `.reversa/config.toml`, section `[specs]`, and merge key for key with `.reversa/config.user.toml#[specs]` (user override takes precedence)
2. The section is considered **decided** when, after merging, `granularity` is filled with one of the valid values: `module`, `use-case`, `endpoint`, `hybrid`, `feature`, `custom`
3. If decided, skip to the next section of the skill (Physical stage detection)
4. If there is an override in `config.user.toml` but `config.toml` is without `granularity`, warn the user before displaying the menu, according to rule RF-18 of `/reversa`. List the override keys and ask for confirmation. Negative response aborts without persisting anything

### 2. Apresentar o menu

In the greenfield path there is NO `surface.json` (Scout did not run). Present the menu without pre-marking an option. If it is legacy and there is `.reversa/context/surface.json` with `organization_suggestion.granularity`, pre-mark the suggestion and show `rationale`.

Use exactly this format (language following `chat_language`):

```
How do you want to organize the specs for this project?

[1] Per code module
  [2] Por caso de uso
  [3] Por endpoint/contrato
[4] Hybrid (module at the root, nested use cases)
  [5] Por features
  [6] Customizada

Escolha (1 a 6):
```

In legacy mode with suggestion available, add `(sugerido)` to the pre-marked option and accept Enter to confirm it.

Mapping the 6 options for `granularity`:

| Option | `granularity` |
|-------|---------------|
| 1 | `module` |
| 2 | `use-case` |
| 3 | `endpoint` |
| 4 | `hybrid` |
| 5 | `feature` |
| 6 | `custom` |

If the user chooses 6, ask: "What are the first-level folder names? List comma separated or one per line (minimum 1)." Sanitize each name (discarding characters prohibited by the OS) and discard empty ones. If the list is empty, repeat the question.

Invalid entries must be rejected by reordering. Cancellation (Ctrl+C) aborts without persisting.

### 3. Persist the decision (atomic write)

Update `.reversa/config.toml`, section `[specs]`:

```toml
[specs]
layout = "feature-folder"
granularity = "<escolha>"
custom_folders = [<list>]
scout_suggestion = "<organization_suggestion.granularity do surface.json, ou vazio em greenfield>"
decided_at = "<timestamp ISO 8601 UTC>"
```

Rules:

- **Atomic write:** write to `config.toml.tmp` in the same directory and atomic rename to `config.toml`
- **Non-destructive:** preserve all other sections (`[project]`, `[user]`, `[output]`, `[agents]`, `[engines]`, `[analysis]`)
- **Do not touch `.reversa/config.user.toml`**, it belongs to the user
- **`scout_suggestion` is immutable:** if it is already filled, preserve it. On first greenfield run, save empty
- IO failure: display clear error, do not consider decision confirmed, user can try again on next run

After successful persistence, proceed with physical stage detection.

## Physical stage detection

Stage detection is by **physical feature artifacts**, never by self-declared fields in metadata. Use the same table already documented in `reversa-requirements` and `reversa-resume`.

1. Try reading `.reversa/active-requirements.json`
1.1. If absent, or invalid, or with `feature-dir` pointing to a non-existent folder, classify as **no active feature**
2. If `feature-dir` exists, identify the physical stage:

| Condition observed in `feature-dir` | Physical internship |
   |--------------------------------------|----------------|
| `requirements.md` missing | `vazio` |
| `requirements.md` present, `roadmap.md` absent | `requirements` |
| `roadmap.md` present, `actions.md` absent | `plan` |
| `actions.md` present with at least one line `\| ... \| \[ \] \|` (checkbox open) | `coding-em-progresso` |
| `actions.md` present, ALL action lines as `\| ... \| \[X\] \|` (checkboxes closed) | `done` |

3. For counting in `actions.md`, consider only table rows that end with `\| [ ] \|` or `\| [X] \|`. Headings and free text are ignored
4. For `requirements`, also count the `[DOUBT]` markers in `requirements.md` (useful for deciding between clarify and plan)
5. For `coding-em-progresso`, count shares `[X]` versus `[ ]` in `actions.md`
6. Also consider the field `paused-features` in `active-requirements.json` (if it exists and has entries, there are paused features available for resumption)
7. For stage `done`, also check if there is a feature addendum in `<output_folder>/addenda/` (file whose name starts with `feature-id`). Addendum present and in force (without overrun line in the Validity section) means that delivery has already converged on extraction

## Matriz de roteamento

The next skill is decided by the combination of physical stage and free argument passed to `/reversa-forward`:

| Status | Free argument passed? | `/reversa-forward` Suggestion |
|--------|--------------------------|--------------------------------|
| No active feature | Yes | `/reversa-requirements <argument>` |
| No active feature | No | Presents the pipeline, asks for a description of the feature, suggests `/reversa-requirements <description>` |
| Stage `vazio` (folder without `requirements.md`) | Indifferent | `/reversa-requirements` (recreate from scratch, report that the current folder is corrupt) |
| Stage `requirements` with `[DOUBT]` | Indifferent | `/reversa-clarify` |
| Stage `requirements` without `[DOUBT]` | Indifferent | `/reversa-plan` |
| Internship `plan` | Indifferent | `/reversa-to-do` |
| Internship `coding-em-progresso` | Indifferent | `/reversa-coding` |
| Internship `done` without addendum in `addenda/` | Indifferent | `/reversa-sync` (converge delivery on extraction) |
| Internship `done` with current addendum | Indifferent | Conclusion, offer `/reversa-resume` if `paused-features` has entries, or suggest `/reversa-requirements` for new feature |

**Important:** if the user passed a free argument AND there is an active feature at a stage other than `done` or `vazio`, DO NOT replicate the "continue / parallel / abandon" menu here. Just communicate the ambiguity and offer both ways out, without deciding:

> There is an active feature (`<NNN-short-name>`, stage `<stage>`), and you also provided a description of a new idea.
>
> 1. If you want to continue the active feature, type **CONTINUE** and I will forward it to `/reversa-<next-for-current-stage>`, ignoring the argument.
> 2. If you want to create a new feature in parallel or abandon the current one, type **NEW** and I will forward it to `/reversa-requirements <description>`, which has the appropriate re-execution policy.

Wait for the choice. Don't decide alone.

## Etapas opcionais (audit, quality, add)

`/reversa-audit` and `/reversa-quality` are optional and not part of the above routing happy path. You only suggest them when:

1. The user explicitly asks
2. You detect signs of inconsistency when reading the artifacts (e.g., `requirements.md` has `[DOUBT]` but `roadmap.md` has already decided on the questionable point, or `actions.md` references missing components in `reversa/sdd/`)

When applicable, suggest it as an intermediate step before the next mandatory skill, leaving the decision up to the user.

`/reversa-add` is also optional, runs after coding and is repeatable. It exists for minute adjustments to the feature already delivered ("increase this title", "put a loading here"), registering the amendment in the spec before implementing. Only suggest when the user describes a short adjustment to what the feature delivered. Never suggest `/reversa-add` for a new idea, new feature, or anything that requires a new dependency, schema or contract change, new public surface, or auth path. In these cases, the routing is `/reversa-requirements`.

## User presentation

Use exactly this format (replacing placeholders with actual values):

> Hello, `<user_name>`. Reversa forward pipeline:
>
> ```
> requirements → clarify? → plan → to-do → audit? → quality? → coding → add? → sync?
> ```
>
> Estado atual: **`<estado descritivo>`**
> `<linhas adicionais conforme o caso, ver abaixo>`
>
> Suggested next step: **`/reversa-<next>`** `<argument if applicable>`
> Why: `<motivo curto baseado no estado detectado>`
>
> Type **CONTINUE** to start `/reversa-<next>`. If you prefer another skill, type the direct name (for example, `/reversa-audit`).

### Linhas adicionais por estado

- **No active feature, no argument:** list the pipeline agents with one line per agent (`reversa-requirements`, `reversa-clarify`, `reversa-plan`, `reversa-to-do`, `reversa-audit`, `reversa-quality`, `reversa-coding`, `reversa-add`, `reversa-sync`) and ask: "Describe in one sentence the feature you want to build."
- **Without active feature, with argument:** show the argument in quotation marks and say that it will be the starting point of `/reversa-requirements`.
- **Stage `requirements` with N markers `[DOUBT]`:** say "`requirements.md` has `<N>` open point(s), it is worth running `/reversa-clarify` before the plan."
- **Stage `requirements` without `[DOUBT]`:** say "`requirements.md` is closed, ready for planning."
- **Stage `plan`:** say "`roadmap.md` is ready, it remains to be decomposed into atomic actions."
- **Stage `coding-em-progresso`:** say "`<N>` of `<M>` actions completed on `actions.md`, encoding in progress."
- **Stage `done` without addendum:** say "All actions are closed, delivery needs to be converged on extraction with `/reversa-sync` so that `<output_folder>/` does not lag."
- **Stage `done` with current addendum:** say "All actions are closed and delivery has already converged on `<output_folder>/addenda/`. If you want, resume a paused feature with `/reversa-resume` or start another with `/reversa-requirements <description>`. For short adjustments to what this feature delivered, use `/reversa-add`."
- **Stage `vazio` (folder without `requirements.md`):** say "`feature-dir` in `active-requirements.json` exists but does not have `requirements.md`. Recommended to start over with `/reversa-requirements`."

If there is `paused-features` with entries, in any state, add a line:

> There are `<N>` feature(s) paused. Use `/reversa-resume` if you want to resume one of them instead of continuing with the active one.

## No writing rule

`/reversa-forward` DOES NOT write to `active-requirements.json`, DO NOT create `feature-dir`, DO NOT modify artifacts within `reversa/sdd/` or `reversa/forward/`. All feature artifact recording is the responsibility of the next skill. You just read and route.

Exceptions allowed, always creation of something that does not yet exist, never overwritten:

1. Create the folder `reversa/sdd/` (with `.gitkeep`) if it is missing, according to the "Extraction context reversa" section.
2. Update `.reversa/state.json` only if it is to fill in the user name that is still blank. Do not touch other fields.

## Absolute rule

**Never delete, modify or overwrite pre-existing project files.**
Reversa ONLY writes to `.reversa/`, `reversa/sdd/` and `reversa/forward/`. This particular skill doesn't even write to these three, it just reads.

## Final output

ALWAYS end with:

> Type **CONTINUE** to continue with `/reversa-<next>` as suggested above.

NEVER execute the next skill automatically, leave the decision up to the user.
