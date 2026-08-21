# Checklist do `handoff.md`

Before closing the pipeline, the orchestrator validates that `handoff.md` meets all items.

## Mandatory checklist

- [ ] `paradigm_decision.md` appears as the **first item** in the "Required Reading" section and the "Recommended Reading Order".
- [ ] `topology_decision.md` appears as the **second item** in the "Required Reading" section.
- [ ] `screen_modernization_decision.md` appears as **third item** when there is UI; in legacy without UI (Screen Translator skipped), the entry is omitted with explicit note "Screen Translator skipped, legacy without UI".
- [ ] List of produced artifacts is complete and reflects actual `reversa/sdd/migration/` and `reversa/sdd/screens/`.
- [ ] Pending deviations in `screen_deviation_log.md` appear as blockers; approved deviations are reflected in `parity_specs.md § Exceptions`.
- [ ] Items REFERRED TO THE CODING of `ambiguity_log.md` appear in a dedicated section of `handoff.md`.
- [ ] Blockers listed or "no blockers, continue" line.
- [ ] Next steps for the coding agent are specific and actionable (not generic).
- [ ] In `--auto`: auto-decided items listed explicitly.
- [ ] Style consistent with the installed engine (adapted format, e.g. compatible front-matter).

## Minimum structure

1. Must-read banner for `paradigm_decision.md`, `topology_decision.md` and (if there is UI) `screen_modernization_decision.md`.
2. Ordem de leitura recomendada.
3. Lista de artefatos.
4. Bloqueadores.
5. Next steps for the encoding agent.
6. Auto-decided items (only if `--auto`).
7. Notas finais.

## Strong signaling to the encoding agent

The first sentence of `handoff.md` should convey immediate clarity. Suggested pattern:

> "New system to be built in paradigm <X>, topology <Y>, screens in mode <Z>. Before any line of code, read `paradigm_decision.md`, `topology_decision.md` and `screen_modernization_decision.md`."

In legacy without UI (Screen Translator skipped), replace the screens section with: "telas: none (system without UI)".
