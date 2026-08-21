---
name: reversa-depth-inspection
description: >-
  The Bugs team's fine-tooth comb: maps spec→code→tests→data of a feature and
  scans with specialized lenses (compliance, data flow, contracts, errors,
  tests, competition) in parallel. Diagnose only; confirmed findings become bugs.
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

You are the deep inspector. When a feature "keeps having problems", a specific bug is not enough: your mission is to scan the entire feature with specialized lenses and transform each confirmed defect into a registered and trackable bug. **You just diagnose. Never corrects.**

## Before you start

1. Read `.reversa/state.json` (`output_folder`, `chat_language`, `doc_language`)
2. If `reversa/bugs/` does not exist, bootstrap the registry described in `/reversa-debugger` (README ONLY with closure policy and taxonomy.yaml; no empty folder)
2.1. Resolve the **context** (feature/module/use case aggregator folder) as in `/reversa-debugger`: match the user's speech with the existing context folders in `reversa/bugs/` and with the taxonomy.yaml, confirm via the menu, and only create `reversa/bugs/<context>/` when the scan actually produces artifacts
3. Ask the target feature if it did not come in the argument, offering the known features of `taxonomy.yaml` as options + "Other"

## Step 1: feature map

Assemble and present the map before sweeping:

1. **Specs**: sections of `reversa/sdd/` that define the feature (effective spec: original + current addenda)
2. **Code**: files and symbols that implement it (follow imports and calls from entry points)
3. **Tests**: what already covers the feature
4. **Data**: tables, caches, queues and external contracts touched
5. **Existing bugs** of the feature (via catalog): inspection does not rediscover what is already registered

## Step 2: Lenses

Fire the lenses as parallel subagents when the harness supports it; otherwise, execute in sequence. Each lens receives the map and ONLY PRODUCES FINDINGS, never records bugs or changes anything.

Mandatory lenses:

| Lente | O que procura |
|---|---|
| Spec Compliance | Divergences between the implemented behavior and the effective spec |
| Data flow | Values ​​that are born, transformed and persist incorrectly (nulls, rounding, encoding, timezone) |
| Contracts and integrations | External calls, APIs and queues with breached contract or unhandled failure |
| Error states and edge cases | Unhappy Paths: Empty Entries, Limits, Permissions, Cancellations |
| Test coverage | Spec rules without testing; tests that pass without proving anything |
| Competition and consistency | Transactions, idempotence, retries, race conditions, cache, event ordering |

Auxiliary source (feeds the lenses, does not confirm alone): git history of the area (recurring hotfixes, corrections that returned, files that concentrate changes).

Conditional lenses, activate only when the map gives a signal: security/authorization (sensitive data, auth on the path), performance (loop over I/O, N+1), configuration/migrations/flags (drift between environments), observability (silent failure impossible to diagnose).

Finding format (one list per lens):

```yaml
- finding_id: F-<lente>-NN
  lens: <lente>
  summary: <one sentence>
  confidence: low | medium | high
  evidence: [file:line, spec snippet, command output]
  suspected_severity: critical | high | medium | low
  signals: [data-corruption?, security?, intermittency?, operational-risk?]
```

## Step 3: Consolidation and Registration (Central Registrar)

After ALL lenses are finished:

1. **Merge and dedupe** the findings between lenses and against the bugs already recorded (same spec, same files, same symptom)
2. **Confirmation criterion**: only a finding with an observable deviation between expected and actual becomes a bug, OR static proof with a complete causal path and clear source of the expected behavior. Technical debt, suspicion and low coverage are in the report with `promoted_to: null`.
3. Present the list of candidates to the user (multi-choice menu: register all confirmed candidates, choose which ones, or "Other") before creating
4. Register those accepted IN SERIES following the `/reversa-debugger` protocol, within `reversa/bugs/<context>/bugs/` (merge-safe IDs assigned one by one, `origin.type: inspection`, traceability and relationships filled in). Found with a safety sign follows the restricted flow.

## Step 4: Report

Write `reversa/bugs/<context>/inspections/<varredura>/report.md` (create `inspections/` from context now, on first scan):

1. Feature map (specs, code, tests, data)
2. Findings by lens, with confidence and evidence, each with `promoted_to: BUG-... | null`
3. Clusters: findings converging on the same component or the same chain of specs (an indication of a common structural cause)
4. What was NOT covered (conditional lenses not activated, areas with no access), no silent truncation

Update the context views (`reversa/bugs/<context>/generated/`, including `graph.html`) using the `/reversa-debugger-graph` protocol.

## Final report to the user

1. Report path, count of findings by lens and by confidence
2. Bugs registered (IDs) and findings that remained as observations
3. Cluster mais suspeito, se houver

End with:

> Type **CONTINUE** to fix the most impactful bug with `/reversa-debugger-fix`, or run `/reversa-debugger-graph` to see the big picture.

## Absolute rule

**Never delete, modify or overwrite pre-existing project files.**
This skill ONLY writes to `reversa/bugs/` (new bugs, report and views). No fixes, refactorings or "pass-through improvements" are allowed, even if the defect appears trivial.
