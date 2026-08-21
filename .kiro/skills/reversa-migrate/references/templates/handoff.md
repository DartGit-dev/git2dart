---
schemaVersion: 1
generatedAt: <ISO-8601>
reversa:
  version: "x.y.z"
kind: handoff
producedBy: orchestrator
hash: "sha256:<body hash below front-matter>"
---

# Handoff to the Encoding Agent

> This document is the entry point for the coding agent (Claude Code, Codex, Cursor, Antigravity, etc.) that will write the new system based on the specs.

## ⚠️ Mandatory reading first

1. **`paradigm_decision.md`**, non-negotiable reading. The target paradigm shapes how all coding should happen.
2. **`topology_decision.md`**, non-negotiable reading. The chosen topology (preserve/modernize/hybrid) defines the folder tree and the boundary between modules.
3. **`screen_modernization_decision.md`**, non-negotiable reading when the legacy has UI. The chosen mode (literal / modernized / hybrid) defines how the encoder will materialize the screens.

## Ordem de leitura recomendada

1. `paradigm_decision.md` (required, first)
2. `topology_decision.md` (required, second)
3. `screen_modernization_decision.md` (required when there is UI; skip if Screen Translator ran in skipped mode)
4. `migration_brief.md`
5. `target_business_rules.md`
6. `migration_strategy.md`
7. `target_architecture.md`
8. `target_domain_model.md`
9. `target_data_model.md`
10. `data_migration_plan.md`
11. `target_screens.md` (when there is UI)
12. `parity_specs.md` + `parity_tests/`
13. `screen_deviation_log.md` (advisory, when there is UI)
14. `risk_register.md` + `cutover_plan.md`
15. `discard_log.md` (consultivo)
16. `ambiguity_log.md` (consultivo)

## Lista de artefatos produzidos

| Artefato | Produzido por | Status |
|---|---|---|
| migration_brief.md | orchestrator | criado |
| paradigm_decision.md | paradigm_advisor | criado |
| target_business_rules.md | curator | criado |
| discard_log.md | curator | criado |
| migration_strategy.md | strategist | criado |
| risk_register.md | strategist | criado |
| cutover_plan.md | strategist | criado |
| topology_decision.md | designer (Phase 1) | created |
| target_architecture.md | designer | criado |
| target_domain_model.md | designer | criado |
| target_data_model.md | designer | criado |
| data_migration_plan.md | designer | criado |
| screen_modernization_decision.md | screen_translator (Phase 1) | created / skipped |
| target_screens.md | screen_translator | criado / skipped |
| screen_deviation_log.md | screen_translator | criado / vazio |
| reversa/sdd/screens/inventory.json | screen_translator | criado / vazio |
| reversa/sdd/screens/golden/manifest.yaml | screen_translator | created / optional |
| parity_specs.md | inspector | criado |
| parity_tests/*.feature | inspector | <N> files |
| ambiguity_log.md | orchestrator | consolidado |

## Blockers to start implementation
> Items that need human decision before the coding agent starts.

- <AMB-XXX: short description + where to decide>
- <or: no blocker, proceed>

## Next steps for the encoding agent

1. **Read `paradigm_decision.md` and internalize**: target paradigm is <paradigm_decision>. Every code choice must honor this paradigm.
2. **Read `topology_decision.md` and internalize**: the chosen topology is <preserve | modernize | hybrid>. Use the tree outline recorded in this artifact as a basis for creating the folder structure of the new repository.
3. **Read `screen_modernization_decision.md` and internalize** (when there is UI): the screen translation mode is <literal | modernized | hybrid>. In literal terms, materialize byte-by-byte (or pixel-equivalent) what is in `target_screens.md`; in modernized, honor the hierarchy of components, tokens and the 4 states (idle, loading, error, success).
4. **Configure the new repository** with the stack declared in `migration_brief.md` and the topology decided.
5. **Implement bottom-up** following `target_architecture.md` and `target_domain_model.md`:
- infrastructure → data → domain → application → edges.
6. **Implement the screens** consuming `target_screens.md` as a literal contract. In literal mode with golden files present in `reversa/sdd/screens/golden/`, the result of the implementation must match the golden file within the `normalizationRules` declared in `manifest.yaml`.
7. **Write the tests** from `parity_specs.md` and `parity_tests/*.feature` from scratch. Honor the § Exceptions section, which reflects deviations approved in `screen_deviation_log.md`.
8. **For each component**, validate that it respects the chosen paradigm (explicit signals in `target_architecture.md § Alignment with the chosen paradigm`) and topology (explicit signals in `target_architecture.md § Alignment with the chosen topology`).
9. **For data migration**, follow `data_migration_plan.md`.
10. **For the cutover**, follow `cutover_plan.md` and the go/no-go criteria.

## Auto-decided items (only if run in --auto)
> List here items whose default was applied without human confirmation. It is recommended to review before cutover.

- <or: pipeline run in interactive mode, no self-decided items>

## Notas finais
<Orchestrator notes for encoding agent.>
