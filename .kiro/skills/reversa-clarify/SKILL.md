---
name: reversa-clarify
description: Generates up to five questions aimed at resolving ambiguous points in the requirements and integrates the answers into the document. Optional step of the forward cycle, between `/reversa-requirements` and `/reversa-plan`.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  phase: forward
  stage: clarify
---

You are the enlightener. Your mission is to discover what remains to be known before the plan and return the answers to `requirements.md` of the active feature.

## Before you start

1. Read `.reversa/state.json` to resolve `output_folder` (reversa extraction) and `forward_folder` (features forward)
2. When the text of this skill mentions `reversa/sdd/` or `reversa/forward/`, use the actual values ​​from state.json

## Initial Checks

1. Read `.reversa/active-requirements.json`
1.1. If the file does not exist, abort with a clear message pointing the user to `/reversa-requirements`
2. Carregue o `requirements.md` da `feature-dir` indicada
3. Apply the default hook rule `before-clarify` read from `.reversa/hooks.yml` (same logic as skill `reversa-requirements`)

## Generation of questions

1. Examine o `requirements.md` em busca de:
1.1. Explicit `[DOUBT]` markers
1.2. Vague phrases ("probably", "maybe", "if possible", "some")
1.3. Open terms without definition (numeric limits, user profiles, expected formats)
1.4. Obvious coverage gaps (missing negative scenario, implicit edge case)
2. Cross-reference the internal taxonomy below to choose candidates
3. Select a maximum of five questions, ranked by impact on the plan
4. Each question must be either multiple choice or short answer, never open without options

### Taxonomy to prioritize

1. Functional scope and behavior
2. Domain and data model
3. Interaction and experience flow
4. Non-functional attributes (performance, security, observability)
5. Integrations and external dependencies
6. Permissions and authentication
7. Data persistence and migration
8. Auditoria, log e telemetria
9. Internationalization and localization
10. Failures and recovery
11. Compatibility with legacy mapped in `reversa/sdd/`

## User presentation

Present questions in the format:

```
1. <question>
a) <option>
b) <option>
c) <option>
d) <option>
e) Free response

2. ...
```

If a question expects a short answer, omit the option block and use `Expected answer: <value-type hint>`.

Wait for the user to respond. If he only answers a few, continue with just those answered.

## Integration in requirements.md

1. Find or create the `## Esclarecimentos` section
2. Inside it, create or update `### Session YYYY-MM-DD` (also recognize legacy `Sessão` headings when reading)
3. For each answered question:
3.1. Add an item in the format `- **Q:** <question>` plus `**A:** <answer>`
3.2. Locate the part of the requirements where the question lived
3.3. Rewrite the in-place snippet, removing the corresponding `[DOUBT]`
4. Update the `## Lacunas` section by removing resolved entries and keeping unresolved ones

## Persistence

- Write the modified `requirements.md` atomically
- The `## Esclarecimentos` section must be right before `## Lacunas`

## Post-Execution Hooks

Apply the default rule for `after-clarify` (same logic as skill `reversa-requirements`).

## Final report

1. `requirements.md` absolute path
2. Number of doubts resolved in this session
3. Number of remaining `[DOUBT]` markers
4. Suggested next step:
4.1. If there is still `[DOUBT]`, suggest re-executing `/reversa-clarify`
   4.2. Se zerou, sugerir `/reversa-plan`

End with:

> Type **CONTINUE** to continue as suggested above.
