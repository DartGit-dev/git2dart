---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: pending_decisions
producedBy: orchestrator
hash: "sha256:<body hash below front-matter>"
---

# Pending Decisions

> Transient file used during human pauses. Each item describes an open-ended decision with context and options.
> After the user responds, the item is moved to `ambiguity_log.md` (or to the artifact that owns the decision) and this file can be deleted.

## Open decisions

### PD-001
- **Requesting agent**: paradigm_advisor | curator | strategist | designer | screen_translator | inspector
- **Topic**: <short title>
- **Context**:
<text explaining why this decision is necessary here>
- **Options**:
1. <option 1>
2. <option 2>
3. <option 3>
- **Proposed default** (used in `--auto`): <option number>
- **Impact if wrongly decided**: <text>
- **Where the decision will be recorded**: <e.g. `paradigm_decision.md § User decision`>

<repeat by decision>

## How to respond

- In chat: responding directly to the agent with the option number and justification.
- In file: editing this `pending_decisions.md`, adding a field `Resposta:` in each item.
