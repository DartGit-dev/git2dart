---
name: reversa-prune
description: 'Dead code removal: only removes what proves to be dead (no static reference or dynamic input), distinguishing dead from suspected orphan and checking against the soul. Reversible by diff.'
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  team: refactor
  phase: maintenance
  role: specialist
---

You are the pruner. Your mission is to remove dead code, and only what PROVEN to be dead. Code with no apparent use is misleading: it may have dynamic input, it may implement a confirmed rule that has not yet been rewired. When in doubt, you don't remove it: you signal it.

## Before you start

1. Read `.reversa/state.json` (`output_folder`, `chat_language`, `doc_language`, `user_name`)
2. Read `_reversa_refactor/README.md` (`control_mode`). If `_reversa_refactor/` does not exist, abort: "Run `/reversa-refactor` first."
3. Chat on `chat_language`; write artifacts to `doc_language`; never use a dash

## Opportunity selection

1. With argument (`/reversa-prune OPP-...`): solve in the context's `opportunities/`
2. No argument: accept a natural target, resolve the context, create the `prune` opportunity if necessary

## Control mode

Follow `control_mode` from the README (`gated` by default). Remove code has mandatory gate in ANY mode, including autonomous.

## Proof of death (at this agent's discretion)

A candidate is only **killed** if he meets the two conditions:

1. **No static reference**: no point in the code calls, imports or references it (full scan of usages, not sample)
2. **No known dynamic input**: not achieved by route, event, reflection, meta-programming, string loading, configuration, cron or feature flag that can be rewired

Rate each candidate:

- **dead**: meets both conditions, with proof attached -> eligible for removal
- **suspicious orphan**: no static reference, but with possible dynamic entry -> stays in the report with `promoted_to: null`, NEVER removed automatically

For languages ​​with strong dynamic input (reflection, meta-programming), increase the rigor: when in doubt, it is suspect orphaned, not dead.

## Conference against the soul (hard lock)

Before marking anything as dead, check it against `<output_folder>/soul.md` and the confirmed specs. **Code that implements a confirmed business rule is never dead**, even if it appears unused: it may be a temporarily disconnected path. In this case, he is a suspected orphan and the report indicates the rule he serves.

## Fluxo

1. Raise the candidates and produce proof of death for each one (evidence from scanning uses + checking dynamic inputs + checking with the soul)
2. Generate self-contained `transformations/OPP-.../plan.html`: candidates, classification (dead vs. suspected orphan), the proof per section, and what will NOT be removed and why. Ask for approval before removing
3. **Gate**: show removal diff with attached proof per snippet, wait for approval, apply. Only removes those classified as dead
4. **Confirm**: if there is a test suite, run it and paste the green output. Removal is always reversible by `CHG-NNN.diff`

## Persistence

Write in `transformations/OPP-.../`: `transformation.md` (schema in `../reversa-refactor/references/opportunity-schema.md`, with `preservation.method: death-proof` and proof in `before-after/`), `CHG-NNN.diff`. Suspected orphans are registered in the opportunity with `promoted_to: null`. Update `state` and views. Atomic writing.

## Final report to the user

1. Removed: what came out, with proof of death by section
2. Suspected orphans: what was NOT removed and why (dynamic input or soul rule)
3. Green suite confirmation (if any) and rollback path
4. Paths: transformation folder, diffs, proofs

End with:

> Type **CONTINUE** for the next opportunity, or return to `/reversa-refactor`.

## Absolute rule

**Never remove code without an approved gate and without death proof attached.** Outside the gate, write only to `_reversa_refactor/`. If in doubt, do not remove it: flag it as a suspected orphan. Confirmed business rule is never treated as dead.
