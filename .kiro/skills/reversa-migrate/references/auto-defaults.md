# `--auto` Defaults

When the user invokes `/reversa-migrate --auto`, the orchestrator skips human pauses and applies these defaults. Before starting, the user notice lists each of them. Each self-applied item is recorded in `ambiguity_log.md` with tag `auto-decidido` for later review.

## Paradigm Advisor
- Choose **option 1: adopt the natural paradigm of the target stack**.
- `derived_appetite` = `transformational`.

## Curator
- HUMAN DECISION items are marked as pending in `ambiguity_log.md` and do not block the pipeline.
- Items 🟡 INFERRED → MIGRATE (with note "validate in coding agent").
- Items 🔴 GAP and ⚠️ AMBIGUOUS → DISCARD with explicit note "self-discarded, requires review".

## Strategist
- Adopt the strategy marked as **recommended**.
- `critical` risks that would depend on a human owner use `owner = "to be defined"` in `risk_register.md`.

## Designer
- **Topology (Phase 1)**: accepts the proposed modern topology (option 2). Justification recorded in `topology_decision.md` is that of the Designer himself; in `ambiguity_log.md` there is the tag `auto-decidido` for later review. Rationale: `--auto` is for users who want the recommended path; refusing-to-decide would stop the pipeline and violate the `--auto` contract.
- **Architecture (Phase 2)**: approves the first proposal without iteration.
- Bounded contexts, events and ADRs are accepted as proposed.

## Screen Translator
- **Mode (Phase 1)**: adopts the mode recommended by the agent for the detected source→target pair (literal for textual pairs; modernized for platform changes; hybrid only with explicit list, therefore never in `--auto`).
- **Generation (Phase 2)**: accepts the generated `target_screens.md` and propagates deviations as `pendente`. `--auto` does not approve deviations alone; they remain in `ambiguity_log.md` as `auto-decidido` for later review, without blocking the handoff (exception to `--auto`: if a deviation is `tipo=correcao` in literal mode, the agent refuses and asks for human approval even in `--auto`, as changing text without approval breaks expectations).
- **Capture of golden files**: does not automate in `--auto` (oracle driver is OQ-02). Only issues `manifest.yaml` with suggested commands.
- **Legacy without UI**: marks `skipped` status automatically, without asking.
- **Discovery prerequisites missing** (`reversa/sdd/design-system/` or `reversa/sdd/ui/inventory.md`): creates minimum `tokens-derived.md` and builds inventory only from source code; alert on `ambiguity_log.md`.

## Inspector
- Uses parity criteria derived directly from the chosen paradigm (see `parity-coverage-matrix.md` in the agent).
- Does not negotiate “accepted parity” criteria with the user.

## Manual modifications detected
- Adopt **option (a)**: preserve the manually modified version and abort regeneration of this artifact. Never destroy human work.

## Mandatory notice

Always before starting `--auto`, present:

> "⚠️ `--auto` mode activated. The defaults below will be applied without pausing for confirmation:
> - Paradigm Advisor: adopt the target stack's natural paradigm (transformational).
> - Curator: items ⚠️/🔴 will be DISCARDED with a note; 🟡 will be MIGRATED with note.
> - Strategist: recommended strategy will be adopted.
> - Designer (topology): proposed modern topology will be adopted (option 2).
> - Designer (architecture): first architectural proposal will be accepted.
> - Screen Translator (mode): adopts the recommended mode for the source→target pair. Hybrid mode never in `--auto`. On legacy without UI, status `skipped`.
> - Screen Translator (generation): deviations are pending in `ambiguity_log.md` (not approved). Non-automated golden file capture (manifest only).
> - Inspector: parity criteria derived from the paradigm without interactive adjustment.
>
> The final `handoff.md` will highlight all auto-decided items for later review.
> Confirm? (y/N)"
