# Step 3, Organization of specs

This step happens immediately after the user chooses `doc_level` (Essential / Complete / Detailed) and before invoking the Archaeologist. This is the moment when Reversa decides and persists in which structure the specs will be generated.

## 1. Decide whether the menu should be displayed

Read, in this order, and merge key by key (full precedence for `config.user.toml`):

1. `.reversa/config.toml`, section `[specs]` (config managed by Reversa)
2. `.reversa/config.user.toml`, section `[specs]` (user manual override)

The merge is evaluated by key: each key present in `config.user.toml` replaces the corresponding one in `config.toml`. Missing keys keep coming from `config.toml`.

The section is considered **decided** when, after merging, `granularity` is filled with one of the valid values: `module`, `use-case`, `endpoint`, `hybrid`, `feature`, `custom`.

- **If decided:** skip this entire step. Go straight to the Archaeologist summon.
- **If not decided** (missing section, or empty `granularity`): display the menu (step 2 below).

### Special case, RF-18

If `granularity` is empty in `config.toml` (or the section has been removed) **and** section `[specs]` exists in `config.user.toml` with any key populated, warn the user before displaying the menu. Use exactly this format:

> "I detected that `.reversa/config.toml` has no spec organization decision, but `.reversa/config.user.toml` contains an override in `[specs]`. The override will remain active after your choice and can overwrite fields that you decide now.
>
> Override atual em `config.user.toml`:
> [listar chaves e valores]
>
> Do you want to continue with the menu anyway? (s/N)"

Wait for an explicit affirmative response before proceeding to the menu. Empty or negative response aborts without persisting anything.

## 2. Apresentar o menu

Read `.reversa/context/surface.json` → `organization_suggestion`. Use the `granularity` field to pre-mark the suggested option and the `rationale` field to show the reason.

If `surface.json` does not have `organization_suggestion` filled in (Scout did not run or failed), display the menu without default and ask the user to choose manually, according to EC-01 of the organization spec.

Use exactly this format (language following `chat_language` from `state.json`, example below in pt-br):

```
How do you want to organize the specs for this project?

Scout has analyzed the legacy and suggests: [suggested granularity translation].
Reason: [organization_suggestion.rationale]

[1] [marker] By code module
  [2] [marcador] Por caso de uso
  [3] [marcador] Por endpoint/contrato
[4] [marker] Hybrid (module at root, nested use cases)
  [5] [marcador] Por features (Scout lista as features descobertas)
  [6] [marcador] Customizada

Escolha (Enter aceita o sugerido):
```

Where `[marcador]` is `*` (asterisk) in the pre-marked option and space in the others. Add `(sugerido)` next to the pre-checked option.

Mapping the 6 options to the value of `granularity`:

| Option | `granularity` |
|-------|---------------|
| 1 | `module` |
| 2 | `use-case` |
| 3 | `endpoint` |
| 4 | `hybrid` |
| 5 | `feature` |
| 6 | `custom` |

### Accept input

- Enter without typing: accepts the pre-marked option.
- Number from 1 to 6: accepts the corresponding option.
- Any other input: ask again without persisting anything.
- Ctrl+C / ESC / cancel: abort the execution and do not persist anything (EC-02).

### Option 6, customized

If the user chooses 6, open the following prompt:

> "What are the names of the top-level folders? List separated by commas or one per line (minimum 1)."

Accept input, sanitize each name (remove characters prohibited by the OS file system, discard empty names). If the list is empty, repeat the prompt (EC-07). Names go to `custom_folders`.

## 3. Detect conflict with structure already on disk (RF-11)

Before persisting the decision, check if there is a spec structure already materialized in `<output_folder>/` (defined in `state.json`).

If the output folder has subfolders that correspond to a different granularity than the one chosen now (for example, chosen `endpoint` but the disk has folders that look like `module`), display warning comparing the two structures and ask for confirmation:

> "I detected that there are already specs generated with the **[old]** structure in `<output_folder>/`. You have now chosen **[new]**, which differs from the previous one.
>
> I will create the new structure in parallel, without touching the previous one. Existing specs are preserved.
>
> Confirm? (y/N)"

Wait for an explicit affirmative response. Denial aborts without persisting.

Detection is heuristic and best-effort: comparing top-level subfolder names with modules identified by Scout (`module`), with URIs/rotas (`endpoint`), with features (`feature`), etc. When the heuristic cannot decide clearly, **do not** display the warning (avoids false positives).

## 4. Persist the decision (RNF-03, atomic write)

Update `.reversa/config.toml`, section `[specs]`, with:

```toml
[specs]
layout = "feature-folder"
granularity = "<user choice>"
custom_folders = [<list>] # only when granularity == "custom", otherwise []
scout_suggestion = "<organization_suggestion.granularity do surface.json>"
decided_at = "<timestamp ISO 8601 UTC, example 2026-05-03T14:32:00Z>"
```

Rules:

- **Atomic write:** write to a temporary file in the same directory (`config.toml.tmp`) and do atomic rename to `config.toml`. Failure while writing cannot leave `config.toml` corrupted.
- **scout_suggestion is immutable** (RF-14): if the section `[specs]` already existed but had `granularity` empty and `scout_suggestion` filled, preserve `scout_suggestion`. On first run, copy the current value of `organization_suggestion.granularity` from `surface.json`.
- **Non-destructive:** preserve any chave/setion that you are not explicitly updating. Do not touch `[project]`, `[user]`, `[output]`, `[agents]`, `[engines]`, `[analysis]` or other sections.
- **Do not touch `.reversa/config.user.toml`.** This file belongs to the user.
- **IO failure** (disk full, no permission, EC-06): display clear error, do not create spec folders, do not consider the choice as confirmed. The user can try again on the next run.

## 5. Continuation of the flow

After successful persistence, proceed with invoking Archaeologist as per `plan.md`. The decision is available to all agents who write specs.

## 6. Manual Resubmission (RF-17)

There is no dedicated CLI flag to reconfigure. The user re-displays the menu by manually removing section `[specs]` from `.reversa/config.toml` (or emptying `granularity`). On the next run, this step detects the "undecided" state and runs again.

## Folder language (RF-10)

The names that Reversa uses for feature folders follow `doc_language` from `state.json`. Don't ask for language at this step. In a `pt-br` installation, the folders are output in pt-br; in `en`, in English.

## Checklist before moving forward

- [ ] Read `[specs]` from `config.toml` and merge with `config.user.toml` key by key
- [ ] If you have already decided, skip the step
- [ ] If there is override in `config.user.toml` but `config.toml` is empty, display warning RF-18
- [ ] Read `organization_suggestion` from `surface.json`
- [ ] Display menu with pre-marked suggestion
- [ ] Accept Enter, number 1 to 6, or cancel
- [ ] If option 6, collect `custom_folders`
- [ ] Detect conflict with disk structure and ask for confirmation
- [ ] Atomic write em `config.toml`
- [ ] Preserve `scout_suggestion` on re-runs with partial section
- [ ] Proceed to Archaeologist
