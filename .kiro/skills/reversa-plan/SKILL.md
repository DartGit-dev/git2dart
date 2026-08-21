---
name: reversa-plan
description: Outlines the technical approach as a delta over the legacy, generating roadmap, investigation, data-delta, onboarding and active feature interfaces. Third skill in the forward cycle, after `/reversa-requirements` and (optionally) `/reversa-clarify`.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: plan
---

You are the evolution architect of Reversa. Its mission is to translate the `requirements.md` of the active feature into a concrete technical proposal, expressed as a delta over what already exists in the legacy.

## Before you start

1. Read `.reversa/state.json` to solve `output_folder` and `forward_folder`
2. Use actual values ​​where the text mentions `reversa/sdd/` or `reversa/forward/`

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If absent, abort with message pointing to `/reversa-requirements`
2. Carregue o `requirements.md` da `feature-dir`
2.1. If the document still has `[DOUBT]` markers, warn the user and ask if they would prefer to run `/reversa-clarify` first.
2.2. If the user confirms that they want to proceed despite having doubts, each `[DOUBT]` becomes an explicit premise in the `roadmap.md`, with a visible warning
3. Apply `before-plan` hooks in the standard way (same logic as skill `reversa-requirements`)

## Collecting technical context

Read the reversa pipeline artifacts in this order, ignoring any that don't exist:

1. `reversa/sdd/architecture.md` (components, internal dependencies)
2. `reversa/sdd/c4-context.md` (fronteiras externas)
3. `reversa/sdd/state-machines.md` (affected state machines)
4. `reversa/sdd/dependencies.md` (bibliotecas usadas)
5. `reversa/sdd/code-analysis.md`, but only the sections of the components mentioned in the requirements
6. `reversa/sdd/addenda/*.md` (current addenda of features already delivered, created by `/reversa-sync`, with deltas that the extraction has not yet absorbed)
7. `.reversa/principles.md` (mandatory principles)

Make a note of which files will be touched by the proposed change. This list will become part of `legacy-impact.md` when `/reversa-coding` runs later, so record it in a mental draft.

## Principles check

For each principle in `principles.md`:

1. Evaluate whether the feature respects the principle
2. If there is a conflict, write it in an `## Applied Principles` section of `roadmap.md`
3. NEVER rewrite or water down a principle here, that's `/reversa-principles`'s job

## Generation of artifacts

Load the template in `.reversa/templates/roadmap-template.md` and generate the files below in `feature-dir`:

| Archive | Expected content |
|---------|-------------------|
| `roadmap.md` | summary of the approach, applied principles, technical decisions, architectural delta, data delta, contract delta, migration plan, risks, ready criteria |
| `investigation.md` | background research, evaluated alternatives, links to external sources, applicable standards |
| `data-delta.md` | conceptual diff on model extracted in `reversa/sdd/`, new fields, removed fields, migrations required |
| `onboarding.md` | executable step-by-step guide for a human who is going to test the feature for the first time |
| `interfaces/<name>.md` | a file per affected external contract (HTTP, queue, gRPC, GraphQL), describes request, response, errors, idempotence, timeouts |

When the feature does not touch external contracts, omit the `interfaces/` directory.

## Writing rules

- Write `roadmap.md` in delta form, never rewrite the entire legacy architecture
- Quote `reversa/sdd/` components by literal name and source file
- Mark each technical decision with 🟢 / 🟡 / 🔴 depending on the confidence about the source
- If a decision depends on an accepted `[DOUBT]` premise, use 🟡

## Persistence

- Engrave all artifacts with atomic writing
- Create `feature-dir/interfaces/` only if there is at least one file inside

## Post-Execution Hooks

Apply `after-plan` in the standard way.

## Final report

1. Absolute paths of generated artifacts
2. List of conflicting principles, if any
3. List of assumptions adopted from unresolved `[DOUBT]` markers
4. Suggested next step: `/reversa-to-do` (or `/reversa-audit` if there is suspicion)

End with:

> Type **CONTINUE** to continue as suggested above.
