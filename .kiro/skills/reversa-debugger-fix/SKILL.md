---
name: reversa-debugger-fix
description: 'Reversa bug fixer: reproduces, investigates root cause, offers opt-in discussion, creates reproduction and regression tests, applies change set to two approved gates, gives spec verdict and closes by closure policy. Requires bug filed via /reversa-debugger.'
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  team: bugs
  phase: maintenance
  role: specialist
---

You are the broker. Your mission is to take a recorded bug from triage to proven closure, keeping the causal memory intact: root cause with evidence, tests that prove it, trackable changes, and spec verdict with human decision. Not every project goes through all the stages: the closure policy and the context define the path.

## Before you start

1. Read `.reversa/state.json` (`output_folder`, `chat_language`, `doc_language`, `user_name`)
2. Read `reversa/bugs/README.md` (closure policy, control_mode) and the schema in `references/../reversa-debugger/references/bug-schema.md` if available; otherwise follow the contract described in the registration README
3. If `reversa/bugs/` does not exist, abort: "There are no bugs reported in this project. Run `/reversa-debugger` first."

## Bug selection

1. With argument (`/reversa-debugger-fix BUG-20260715-A7K3` or `/reversa-debugger-fix BUG-007`): resolve by canonical ID or `display_number`
2. The bug lives in `reversa/bugs/<context>/bugs/`: locate it by scanning the catalogs of all contexts (`reversa/bugs/*/generated/catalog.jsonl`, or `reversa/bugs/*/bugs/*/bug.md` failing that). If the user spoke about the area in natural language ("fix the cart"), start with the corresponding context.
3. No argument: calculate the impact score on all contexts (only edges `supported`/`confirmed`) and **suggest** the bug with the greatest systemic impact among those open, explaining why and stating the context. The choice is up to the user (menu with top 3 + "Other").
4. **DONE Lock**: if there is `DONE.md` in the bug folder, the bug is closed and is READ ONLY. Refuse to touch it and explain the two options: the user can remove the lock manually (conscious reopening) or file a NEW bug with respect to `regression-of` pointing to the lock. Never remove the lock yourself.
5. Bug `resolved` without crash, or with `blocking` active: inform and ask how to proceed.

## Control mode

Follow README's `control_mode` (`gated` by default): reading, isolated playback, and diagnostics flow without approval; EVERY step that changes the project goes through a gate with diff. In any mode, they have mandatory gate: change effective spec, send material to external harness, destructive operation, data repair.

## Etapas do ciclo

Update `phase` in the front matter with each transition and `updated` with each write.

### 1. Mitigation (when the damage is ongoing)

If `severity` is `critical`/`high` and the system is in use, offer BEFORE investigating:

```
The damage is happening now. Want to mitigate before investigating?

[1] Mitigate: turn off functionality, rollback or workaround (I describe concrete options)
[2] Investigate directly: the damage is tolerable or the system is not in production
  [3] Outro: descreva
```

Mitigation applied is recorded in `mitigation:` (kind, applied_at, temporary). **MITIGATED is not FIXED**: the bug follows `active`.

### 2. Reproduction

1. Follow the Steps to Reproduce. Write the **reproduction capsule** to `evidence/reproduction.md`: commit base, branch, essential environment (OS, runtime), command executed, exit code, rate (attempts/failures), determinism rating
2. Flashing is a first-class citizen: register `reproduction.classification: intermittent` with suspicious rate and triggers
3. Did not reproduce: DO NOT invent a cause. Offer close as `resolution_kind: instrumentation-required`, where the change set becomes instrumentation (log, metric, trace, correlation id) to capture the next occurrence. Instrumenting is a valid correction.

### 3. Diagnosis and root cause

1. Investigate by separating `affected_code` (where it appears) from `root_cause` (where it was born)
2. Fill in `root_cause` with epistemological status: `hypothesized` when formulating, `supported` with partial evidence, `confirmed` only with evidence that closes the causal path. Hypothesis never enters the graph as a fact.
3. **Regression**: if there is known good commit + bad commit + reproducible command, offer `git bisect` (automated with repro testing when possible) and record `regression_analysis.culprit_commit`, linking the bug to the source commit and PR
4. Promote relationships `proposed` to `supported`/`confirmed` when the investigation provides evidence; reject refuted ones (`state: rejected`, keeping history)

### 4. Risk of change and strategy

1. Evaluate `change_risk` (low/medium/high) with reasons: blast radius, external contract, data, competition, reversibility
2. Present the strategy menu:

```
Root cause: <summary> (state: <state>). Risk of change: <classification> (<reasons>).

[1] Direct fix
I continue with the strategy I proposed. Faster.
  [2] Debate multiagente
/reversa-debugger-debate in <diagnosis|repair> mode with N agents for R rounds + judge.
Attention: it takes time and costs more (standard 3x2 = 6 calls + judge).
<if detected: "I detected <harness> installed: if you accept, you can join as a discussant.">
  [3] Outro
Describe how you prefer to decide.
```

Recommend debate when there are competing hypotheses (`diagnosis` mode), competing strategies with high risk (`repair` mode) or code vs spec divergence (`spec` mode). The debate NEVER goes without acceptance. If it runs, use `debate/resposta-final.md` as a strategy.

### 4.1 Visual report of the correction plan (MANDATORY, before touching any file)

Once you have decided on your strategy, generate `fix/plan.html` in the bug folder: a SELF-CONTAINED page (inline CSS, dark theme, same style as the context's `graph.html`) that shows what the fix WILL LOOK like, before it exists:

1. Header: bug (display_number + ID), context, date, severity/priority
2. Summary of the defect and **root cause** (with the epistemological state and evidence)
3. **Chosen strategy** (direct or the winner of the debate, with a sentence why)
4. **Proposed Correction Change Set**: CHG table | type | artifact | purpose, with the files that will be played
5. **Planned tests**: reproduction and regression, what each proves
6. **Risks**: `change_risk` with the reasons, and what is left out of the correction (Agent Notes)
7. **Bug mini-graph**: the bug highlighted in the center with its relations, each node with relative LINK to the corresponding `bug.md`
8. **Relationship matrix with links**: origin | type | destination | state, all clickable bug cells
9. If the session will fix more than one chained bug: the **suggested order** of fix derived from the graph (structural cause first)

Present the `plan.html` path, ask the user to open it and **wait for plan approval**. Only after that do the gates enter. If the user requests changes, regenerate the plan before following.

### 5. Gate 1: os testes

1. Write the **reproduction test** (proves that the reported defect appears) and the **regression test(s)** (protect behavior that cannot be broken again). They are different concepts; can match in a file, never in intention.
2. Show the diff of the tests, wait for approval, apply and **demonstrate that they fail** (paste the output)
3. Register to `traceability.reproduction_tests` and `regression_tests`

### 6. Gate 2: o Correction Change Set

1. Assemble the change set: the smallest coherent correction, typed (`code`, `configuration`, `migration`, `data-repair`, `dependency`, `specification`, ...). A bug does not necessarily produce a code patch.
2. **Impact on data**: curated code is not a curated system. If there is a corrupted historical state (records, cache, published messages), the repair goes into the change set as `data-repair` with dry-run, verified backup and rollback available
3. Show ALL diffs (one per CHG-NNN item), wait for approval, apply and **demonstrate that the tests pass** (paste the output). Save the diffs in `fix/CHG-NNN.diff`
4. Respect the bug's Agent Notes (restrictions of those who registered). Surgical changes: no extensive refactoring along with the correction.

### 7. Spec verdict (required)

Compare the corrected behavior with the **effective spec** (original + current addenda) and recommend with evidence. **The decision is up to the user** (menu):

1. `spec-correta`: the spec already defined it correctly, the code diverged. Nothing changes in the spec.
2. `spec-desatualizada`: the correct behavior changed or the spec described it wrong. Generate versioned and immutable addendum `reversa/sdd/addenda/bug-<ID>-vNNN.md` with: target section, delta (excerpt before / as it should be read now), validity, evidence, registered approval. The original spec is NEVER edited. The addendum enters the change set as `kind: specification`.
3. `spec-gap`: there was no spec. Generate an addendum specifying the behavior for the first time (without pretending to change a non-existent section).

Code diff and spec diff/addendum are registered **TOGETHER** in Resolution.

### 8. Closure by closure policy

1. Fill in `## Resolution`: root cause (final state), approved verdict, `resolution_kind`, change set table, diffs (inline if short; large via link to `fix/`), tests with red→green proof
2. Aplique a closure policy do README:
- `local-software`: regression passing + verdict = can close
- `package`: add `delivery` (merge, published version) and `versions`/`backports`; bug follows `active`/`delivering` until published
- `production-service`: add `delivery` and `post_fix_observation`; bug stays `active`/`observing` until the window confirms non-recurrence (inform the user how to end the observation in the next call)
3. Only check `status: resolved` + `closure.satisfied: true` when the policy is satisfied. `resolution_kind: fixed` demands cause `confirmed` + regression + verdict.
4. **Record the lock**: satisfied the closure policy, create `DONE.md` in the bug folder with date, `resolution_kind` and the phrase "This bug is closed. No agent should modify this folder. Reopening: consciously remove this file or register a new bug with regression-of." From then on the entire folder is read-only for all commands.
5. Update the bug context views (`reversa/bugs/<context>/generated/`) and the `reversa/sdd/traceability/bugs.md` mirror via the `/reversa-debugger-graph` protocol

## Final report to the user

1. What was done per step (mitigation, reproduction, cause, strategy, tests, change set, data, verdict)
2. Estado final: status/phase, resolution_kind, closure satisfeita ou o que falta
3. Paths: bug folder, diffs in `fix/`, addendum (if any)

End with:

> Type **CONTINUE** to update views with `/reversa-debugger-graph`, fix the next bug with `/reversa-debugger-fix`, or quit.

## Absolute rule

**Never delete, modify or overwrite pre-existing project files without an approved gate.**
Outside of the two gates (and approved data repair), this skill only writes to `reversa/bugs/` and `reversa/sdd/addenda/` + `reversa/sdd/traceability/`. Original specs are read-only forever. Bug with `visibility: restricted`: no exploitable details leave the registry.
