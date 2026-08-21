# Reconstruction Plan — {{PROJECT_NAME}}

**Stack:** {{STACK}}
**Generated on:** {{DATE}}
**Status:** {{TOTAL}} tasks | {{DONE}} completed | {{PENDING}} pending

---

## Pre-flight alerts

> Review these points before starting. Gaps marked with ⚠️ block the associated task.

{{#each PREFLIGHT_ALERTS}}
- ⚠️ **{{this.gap}}** — blocks Task {{this.task_number}} ({{this.task_name}})
{{/each}}

{{#if NO_ALERTS}}
No critical gaps identified. You can start safely.
{{/if}}

---

## Tasks

### Task 01 — Database Schema
**Status:** pending
**Reads:** `reversa/sdd/erd-complete.md`, `reversa/sdd/data-dictionary.md`
**Builds:** migrations, schema, ORM models (according to stack detected)
**Ready when:** All ERD tables exist with correct types, constraints and foreign keys

---

### Task 02 — Domain Entities
**Status:** pending
**Reads:** `reversa/sdd/domain.md`, `reversa/sdd/data-dictionary.md`
**Builds:** entities, value objects, domain validations
**Ready when:** All entities implemented with the described business rules

---

### Task 03 — State Machines
**Status:** pending
**Reads:** `reversa/sdd/state-machines.md`
**Builds:** implementation of state flows for each entity
**Ready when:** All documented states and transitions are implemented
**Note:** Skip this task if `reversa/sdd/state-machines.md` does not exist

---

<!-- COMPONENT_TASKS_START -->
<!-- Reconstructor inserts one task per unit here, in the bottom-up order determined by dependencies.md -->
<!-- Unit task example: -->

### Task 04 — [Unit Name]
**Status:** pending
**Reads:** `reversa/sdd/[unit]/requirements.md`, `reversa/sdd/[unit]/design.md`, `reversa/sdd/[unit]/tasks.md`, `reversa/sdd/dependencies.md`
**Builds:** [module path according to stack]
**Ready when:** [acceptance criteria extracted from requirements.md, field "Given/When/Then"]
**Alert:** [if there is an associated gap, describe it here]

<!-- COMPONENT_TASKS_END -->

---

### Task {{API_N}} — API Layer
**Status:** pending
**Reads:** `reversa/sdd/openapi/[file list]`
**Builds:** endpoints, controllers, middleware, authentication
**Ready when:** All endpoints respond as per OpenAPI contracts

---

### Task {{STORIES_N}} — User Flows
**Status:** pending
**Reads:** `reversa/sdd/user-stories/[file list]`
**Builds:** end-to-end integration, complete user flows
**Ready when:** All user stories acceptance criteria are met
