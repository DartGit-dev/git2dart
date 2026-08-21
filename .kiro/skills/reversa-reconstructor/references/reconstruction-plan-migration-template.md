# Reconstruction Plan — {{PROJECT_NAME}}

**Source:** migration
**Target paradigm:** {{PARADIGM}}
**Topology:** {{TOPOLOGY}}
**Stack:** {{STACK}}
**Strategy:** {{STRATEGY}}
**Generated on:** {{DATE}}
**Status:** {{TOTAL}} tasks | {{DONE}} completed | {{PENDING}} pending

---

## Pre-flight alerts

> Review before starting. Items REFERRED TO CODING in `ambiguity_log.md` that affect specific tasks are marked.

{{#each PREFLIGHT_ALERTS}}
- ⚠️ **{{this.item}}** — affects Task {{this.task_number}} ({{this.task_name}}). Source: `reversa/sdd/migration/ambiguity_log.md`
{{/each}}

{{#if NO_ALERTS}}
No blocking items. You can start.
{{/if}}

---

## Tasks

### Task 01 — New Project Setup
**Status:** pending
**Reads:** `reversa/sdd/migration/topology_decision.md`, `reversa/sdd/migration/paradigm_decision.md`
**Builds:** initial folder/module structure, base configuration, minimal dependencies
**Ready when:** New repository skeleton matches the approved topology and chosen paradigm

---

### Task 02 — Target Bank Schema
**Status:** pending
**Reads:** `reversa/sdd/migration/target_data_model.md`
**Builds:** migrations, schema, ORM models (according to stack)
**Ready when:** All tables/collections of the target data model exist with correct types, constraints and relationships

---

### Task 03 — Data Migration Plan
**Status:** pending
**Reads:** `reversa/sdd/migration/data_migration_plan.md`, `reversa/sdd/migration/target_data_model.md`
**Builds:** scripts/jobs from ETL, health validations, rollback
**Ready when:** Migration scripts tested on representative volume, validations match plan
**Note:** Skip if the strategy in `migration_strategy.md` does not involve data migration (e.g. new system from scratch without legacy data)

---

### Task 04 — Target Domain Entities
**Status:** pending
**Reads:** `reversa/sdd/migration/target_domain_model.md`, `reversa/sdd/migration/target_business_rules.md`
**Constructs:** entities, value objects, aggregates, business rules
**Ready when:** Domain implemented according to the target model, business rules covered by tests

---

<!-- MODULE_TASKS_START -->
<!-- Reconstructor inserts here one task per module identified in target_architecture.md, in dependency order. -->
<!-- Example: -->

### Task 05 — [Module Name]
**Status:** pending
**Reads:** `reversa/sdd/migration/target_architecture.md` (section `[module]`), `reversa/sdd/migration/target_domain_model.md`, `reversa/sdd/migration/target_business_rules.md`
**Builds:** [module path according to approved topology]
**Ready when:** [parity criteria taken from parity_specs.md, if applicable; otherwise, criteria in target_architecture.md]
**Alert:** [if there is an item REFERRED TO CODIFICATION associated]

<!-- MODULE_TASKS_END -->

---

### Task {{CUTOVER_N}} — Cutover
**Status:** pending
**Reads:** `reversa/sdd/migration/cutover_plan.md`
**Builds:** scripts/checklists of cutover, traffic switch, executable rollback plan
**Ready when:** New system receives traffic as per plan and legacy can be shut down/frozen as decided

---

### Task {{PARITY_N}} — Parity Validation
**Status:** pending
**Reads:** `reversa/sdd/migration/parity_specs.md`, `reversa/sdd/migration/parity_tests/[.feature file list]`
**Builds:** parity test suite running against legacy and new, divergence report
**Ready when:** All critical flows defined in parity_specs.md pass both systems with equivalent results
