# Exploration Plan — git2dart

> Created by Reversa on 2026-08-16
> Mark each task with ✅ when completed.
> You can edit this plan before starting: add, remove or reorder tasks as needed.

---

## Phase 1: Recognition 🔍

- [x] ✅ **Scout** — Mapeamento de estrutura de pastas e tecnologias
- [x] ✅ **Scout** — Dependency analysis and package managers
- [x] ✅ **Scout** — Identification of entry points, CI/CD and configurations

## Specs organization decision 🗂️

> Between the Scout and the Archaeologist, Reversa asks how you want to organize the specs (by module, use case, endpoint, hybrid, by features or custom). The choice is persisted in `.reversa/config.toml` in section `[specs]` and will not be asked again in future executions. To redisplay the menu, manually remove the section.

## Phase 2: Excavation 🏗️

> Reversa populates this section with the actual modules after the Scout completes reconnaissance.

- [x] ✅ **Archaeologist** — Analysis of module `repository-lifecycle`
- [x] ✅ **Archaeologist** — Analysis of module `git-objects-and-object-database`
- [x] ✅ **Archaeologist** — Analysis of module `working-tree-and-index`
- [x] ✅ **Archaeologist** — Analysis of module `references-and-remotes`
- [x] ✅ **Archaeologist** — Analysis of module `history-and-integration-operations`
- [x] ✅ **Archaeologist** — Analysis of module `native-runtime-and-platform-boundary`

## Phase 3: Interpretation 🧠

- [x] ✅ **Detective** — Git archaeology and retrospective ADRs
- [x] ✅ **Detective** — Implicit domain rules and state machines
- [x] ✅ **Detective** — Permissions and trust-boundary matrix
- [x] ✅ **Architect** — C4 diagrams (Context, Containers, Components)
- [x] ✅ **Architect** — Complete logical ERD and external integrations
- [x] ✅ **Architect** — Spec Impact Matrix

## Phase 4: Generation 📝

- [x] ✅ **Writer** — Feature-oriented SDD specifications
- [x] ✅ **Writer** — OpenAPI applicability assessed (not applicable: no HTTP/RPC API)
- [x] ✅ **Writer** — User Stories
- [x] ✅ **Writer** — Code/Spec Matrix

## Phase 5: Review ✅

- [x] ✅ **Reviewer** — Cross-spec consistency and matrix validation
- [x] ✅ **Reviewer** — Open gaps collected (12 unanswered validation questions)
- [x] ✅ **Reviewer** — Final confidence report

---

## Independent Agents

> Run these agents when resources are available — they can run at any stage.

- [ ] **Display** — Interface analysis via screenshots
- [ ] **Data Master** — Complete database analysis
- [ ] **Design System** — Extraction of design tokens
- [ ] **Tracer** — Dynamic analysis (requires accessible system)

---

## Next step

After the Discovery Team completes and `reversa/sdd/` is populated, you can trigger one of the following flows:

- `/reversa-migrate`: orchestrator of the **Migration Team** (Paradigm Advisor → Curator → Strategist → Designer → Screen Translator → Inspector). Generates the specs of the new system. Output in `reversa/sdd/migration/` and `reversa/sdd/screens/`.
- `/reversa-reconstructor`: generates bottom-up plan to reimplement the software from the legacy specs (one task per session).
