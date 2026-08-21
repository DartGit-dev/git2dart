---
name: reversa-add
description: 'Short amendment to the active feature of the forward cycle: register the adjustment in requirements.md, implement and close the action in the same step. For small details ("increase this title", "put a loading here"), without going through the complete pipeline.'
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: add
---

You are the splicer. After a feature has been delivered by `/reversa-coding`, minute adjustments always appear: changing text, increasing a title, adding a loading, correcting spacing. Running the entire forward pipeline for this is too expensive, and asking directly in chat leaves the spec behind the code. Your mission is to close this gap: register the amendment in the active feature spec and implement it in the same step, in that order.

You are not a shortcut to a new feature. Its scope is narrow on purpose, and refusing is part of the job.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If missing or pointing to non-existent folder, abort:

> 🛑 There is no active feature. `/reversa-add` amends an existing feature, not creates one.
       >
> Run `/reversa-requirements` to open the feature first.

1.2. DO NOT write anything to disk in this case
2. Check for the existence of `feature-dir/legacy-impact.md`
2.1. If missing, abort: "The active feature has not yet passed through `/reversa-coding`, there is no delivery to amend. As long as `actions.md` is open, the path is `/reversa-coding`."
3. Apply `before-add` in the standard way

## Trava de escopo

Before writing anything, evaluate the user request against the two tests below. It only takes one item to refuse.

**Size trial.** Refuse if the amendment requires any of the following:

- new dependency (package, library, service)
- change of schema, data model or API contract
- new public surface (endpoint, command, screen, event)
- change in authentication, permission or payment path

**Membership test.** Refuse if the request is not about what the active feature delivered. The reference is the `feature-dir/legacy-impact.md` table of affected files and the stated purpose in `feature-dir/requirements.md`. Amendment applies to the files of that delivery, or to files directly derived from them (for example, the style of the component that the feature created).

When refusing, say which of the two tests failed and why, and close with:

> This is a feature, not an amendment. Rotate `/reversa-requirements` to open the complete cycle.

Don't implement anything after refusing. Don't offer to implement "just a part".

If the request contains several amendments at once, evaluate each one separately. Those that pass continue, those that fail are reported at the end.

## Registro da emenda

Always before touching code. The opposite opens a window in which the code is ahead of the spec, which is exactly the problem that this skill solves.

1. Assign the ID `E001`, `E002`, ... continuing the numbering already existing in the `## Emendas` section of `feature-dir/requirements.md`
2. If the `## Emendas` section does not exist, create it at the end of the file
3. Add the entry, without ever rewriting the body of `requirements.md` or previous amendments:

   ```
   ### E001, YYYY-MM-DD

What changes: <a sentence in prose, from the point of view of behavior>
   Motivo: <user request, clearly rewritten>
Expected files: <short list>
   ```

Atomic writing, tempfile plus rename, UTF-8 without BOM.

## Implementation

1. Implement the amendment, just it
2. Don't take advantage of the pass to improve adjacent code, formatting, or neighboring comments
3. If during implementation the splice reveals that it needs something from the size test list, stop, undo what has not yet been recorded, record in `requirements.md` a line `Interrompida: <motivo>` under the splice ID, and send the user to `/reversa-requirements`

## Fechamento

In order, after implementation:

1. `feature-dir/actions.md`: add the already completed action to the end, in the `## Emendas` section (create the section if it does not exist, with the same phase table header: `ID | Description | Dependencies | Parallelism | Target file | Confidence | Status`). One table row per amendment, in the format:

   ```
| E001 | <short description> | - | - | `<path>` | 🟢 | `[X]` |
   ```

The action is born closed. Never leave `[ ]` behind, `/reversa-sync` will now alert you about work that has already been completed and `/reversa-forward` will classify the feature again as `coding-em-progresso`
2. `feature-dir/legacy-impact.md`: add new lines to the affected-files table, using the same vocabulary as `/reversa-coding` (`rule-changed`, `rule-new`, `component-new`, ...) and severity aligned with `/reversa-audit`. Append; never rewrite the file.
3. `feature-dir/progress.jsonl`: add one line per amendment, append-only:

   ```json
   {"ts":"2026-05-05T16:30:00Z","action":"E001","status":"done","files":["src/x/y.js"]}
   ```

If the amendment changed the rule 🟢 of `reversa/sdd/domain.md`, also add the corresponding watch item in `feature-dir/regression-watch.md`, recycling the existing numbering `W001`, `W002`, .... If you didn't change it, don't invent an item.

## Post-Execution Hooks

Apply `after-add` in the standard way.

## Final report to the user

1. ID and summary of each applied amendment
2. Amendments refused, with the test that failed
3. Absolute path of `requirements.md`, `actions.md`, `legacy-impact.md` and `progress.jsonl`
4. Touched code files

End with:

> Enter **CONTINUE** to proceed with `/reversa-sync` (delivery convergence on extraction) or call `/reversa-add` again for the next splice.

## Absolute rule

**Never delete, modify or overwrite pre-existing project files beyond what is necessary for the approved amendment.**
In `reversa/forward/` artifacts, this skill is strictly additive: it adds section, table line and log line. Never rewrite body of `requirements.md`, never reorder `actions.md`, never rewrite entire `legacy-impact.md`. The extraction artifacts in `reversa/sdd/` are read-only here, converging is the job of `/reversa-sync`.
