---
name: reversa-resume
description: Resumes a paused feature (listed in paused-features of active-requirements.json) and makes it active. It DOES NOT create new features, it just swaps the active one for the chosen one and (when it makes sense) moves the current active one to paused-features.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: resume
---

You are the taker. Your mission is to exchange the active feature for one of those in `paused-features`, without losing the work of either one.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If absent, abort with message:

> 🛑 `/reversa-resume` requires an active feature to make the switch. `active-requirements.json` does not exist.
       >
> Use `/reversa-requirements` to create the first feature of the project.

2. Check the `paused-features` field
2.1. If missing or empty array, abort with message:

> 🛑 There are no paused features to resume. The `paused-features` array is empty.
       >
> Features are paused when you run `/reversa-requirements` on an active feature in progress and choose option 2 (create parallel).

3. Apply `before-resume` hooks in the standard way (reads `.reversa/hooks.yml`, filters `enabled: false`, same logic as other skills in the forward cycle)

## List of pauses

For each entry in `paused-features`:

1. Check if `feature-dir` still exists on disk
1.1. If it does NOT exist, mark it as `ausente` (the folder was manually deleted, the entry became trash)
2. If it exists, detect the **current physical stage** with the same logic as `/reversa-requirements`:

| Condition observed in `feature-dir` | Physical internship |
   |--------------------------------------|----------------|
| `requirements.md` missing | `vazio` |
| `requirements.md` present, `roadmap.md` absent | `requirements` |
| `roadmap.md` present, `actions.md` absent | `plan` |
| `actions.md` present with at least one line `\| ... \| \[ \] \|` | `coding-em-progresso` |
| `actions.md` present, all shares as `\| ... \| \[X\] \|` | `done` |

3. For `coding-em-progresso`, count shares `[X]` versus `[ ]`

Present a numbered list to the user:

```
Features pausadas:

1. <NNN-short-name> · stage: <physical> · paused at <YYYY-MM-DD> [· N of M actions]
2. <NNN-short-name> · stage: <physical> · paused at <YYYY-MM-DD>
3. <NNN-short-name> · stage: missing · paused at <YYYY-MM-DD> (folder deleted, entry orphaned)
```

For entries `ausente`, visually mark that they are orphaned.

## User choice

Ask:

> Which feature do you want to return to? Enter the list number, or `0` to cancel.

Wait for the response. DO NOT choose on your own.

## Orphan entry handling

If the user chose an entry with stage `ausente`:

1. DO NOT swap
2. Ask: "The folder for this feature has been deleted. Do you want to remove this entry from `paused-features`? (yes / no)"
3. If yes, remove just this entry from the array, write updated `active-requirements.json` (atomically), close the skill.
4. If not, close without changing anything.

## Detection of the state of the currently active feature

For the feature in `active-requirements.json#feature-dir`, detect the physical stage using the same table above. This value decides whether it will be paused or discarded in the exchange.

## Swap

1. Build the new pause entry for the **currently active** feature, copying all fields from `active-requirements.json` except `paused-features`, and adding:
   - `paused-at`: ISO 8601 da hora atual
- `paused-from-stage`: physical stage detected of the current active
2. Decide the destination of the currently active feature:
- 2.1. If physical stage is `requirements`, `plan` or `coding-em-progresso`: **pause**, i.e. push the constructed entry into the `paused-features` array
- 2.2. If physical stage is `done`: **active discard**, DO NOT push (the feature is completed, it is not worth taking up space in paused-features). Her folder remains untouched at `reversa/forward/`
- 2.3. If physical stage is `vazio`: **active discard**, DO NOT push (corruption, folder without `requirements.md`)
3. Remove the chosen feature from the `paused-features` array
4. Build the new `active-requirements.json`:

```json
{
  "schema-version": 1,
  "feature-dir": "<feature-dir da escolhida>",
  "feature-id": "<feature-id da escolhida>",
  "short-name": "<short-name da escolhida>",
  "started-at": "<started-at original da escolhida>",
  "current-stage": "<original current-stage of the chosen one, or detected physical stage>",
  "stages-completed": [<copied from the chosen one, or [] if absent>],
  "paused-features": [<array atualizado>]
}
```

4.1. If the chosen one did not have `started-at`/`current-stage`/`stages-completed` (old version entry, before the rich schema), use the physical stage detected for `current-stage` and the current time as `started-at` (record this fallback in a message to the user)

5. Write JSON atomically (tempfile plus rename)

## Post-Execution Hooks

Apply `after-resume` in the standard way.

## Final report to the user

1. Feature retomada: identificador `<NNN-short-name>`
2. Detected physical stage of this feature: value between `requirements` / `plan` / `coding-em-progresso`
3. For `coding-em-progresso`, show `N of M actions completed`
4. Destination of the previously active feature:
   4.1. "pausada" (se foi push pra paused-features)
   4.2. "descartada do ativo (estado: done)" ou "descartada do ativo (estado: vazio)"
5. Suggestion for the next skill according to the stage of the resumed feature:
5.1. `requirements` → suggest `/reversa-clarify` (if there is `[DOUBT]`) or `/reversa-plan`
   5.2. `plan` → sugerir `/reversa-to-do`
5.3. `coding-em-progresso` → suggest `/reversa-coding` (with optional argument to restrict scope)

Always end with:

> Type **CONTINUE** to continue as suggested above.

DO NOT execute the next skill automatically, leave the decision up to the user.
