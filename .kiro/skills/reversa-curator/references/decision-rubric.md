# Decision Rubric do Curator

Quick reference table for applying decision policy.

## Decision table

| Signal observed in the rule | Default decision | Notes |
|---|---|---|
| 🟢 CONFIRMED, compatible with target paradigm, without pain point | MIGRATE | without reservation |
| 🟡 INFERRED, compatible with target paradigm | MIGRATE | add note "validate in encoding agent" |
| 🔴 GAP | HUMAN DECISION | optional recommendation |
| ⚠️ AMBIGUOUS | HUMAN DECISION | mandatory list interpretations |
| Rule cited as pain point | HUMAN DECISION | default recommendation: replace with X in the new |
| Rule incompatible with brief (out of scope) | DISCARD | justification: "out of scope declared in migration_brief.md" |
| Rule incompatible with brief (technical) | DISCARD | justification: "technical restriction of the brief prevents" |
| Rule is a legacy paradigm mechanism, paradigm has changed | DISCARD (linked to paradigm) | indicate substitute in target paradigm |
| Rule is a mechanism of the legacy paradigm, paradigm is the same | MIGRATE | without reservation |

## List of typical paradigm mechanisms (disposable when paradigm changes)

### Procedural → event-driven
- Lock pessimista (`SELECT ... FOR UPDATE`)
- Entire ACID transaction around the flow
- Synchronous response to the user with inline side effect
- Retry implemented as `for` in the controller

### Classic OO → OO with DI
- Active Record that mixes persistence and domain
- Inheritance used for behavior reuse (prefer composition)
- Singleton manual (preferir scoped DI)

### Classic OO → functional
- Mutable encapsulation (prefer immutable types)
- Void methods with side effect (prefer return + pure function)

### OO with DI → event-driven
- Synchronous commands with immediate feedback (prefer event + ack)
- Centralized orchestration (prefer choreography)
- 2PC/distributed transaction (prefer saga)

### Synchronous → asynchronous in general
- Timeout configured in controller (goes to consumer retry policy)
- Error handling as a propagated exception (becomes DLQ)

## O que NUNCA descartar por paradigma

- Pure business rules (calculations, conditions, derivations).
- Regulatory rules.
- Domain invariants.
- Rights/permissions.

These rules change **place** in the new paradigm, but they do not disappear.
