# Target Paradigm Honor Checklist

Quick checklist that the Designer applies before closing `target_architecture.md` and `target_domain_model.md`.

## Event-driven

- [ ] Events are named in the past tense (`PedidoCriado`, not `CriarPedido`).
- [ ] Each event has an explicit schema with versioning.
- [ ] Commands and events are distinct.
- [ ] Idempotence is guaranteed by construction (event ID, deduplication key).
- [ ] Message order is handled by partitioning key.
- [ ] Saga / orchestrator for distributed transactions, with clearing.
- [ ] Outbox table for at-least-once guarantee between DB and queue.
- [ ] DLQ defined for terminal failures.

## OO with DI

- [ ] Explicit interfaces for external dependencies.
- [ ] Injection container configured by bounded context.
- [ ] Aggregates do not depend on infra (no persistence within the aggregate).
- [ ] Concrete repositories live in the infra layer.
- [ ] Active Record explicitamente proibido.

## Functional

- [ ] Immutable types in the domain.
- [ ] Pure functions in the nucleus; side effects on edge.
- [ ] State is a sequence of transformations, not mutation.
- [ ] Composition used to build flows.
- [ ] Algebraic types (sum types) for disjoint states.

## Actor model

- [ ] Each actor has a mailbox and isolated status.
- [ ] Defined hierarchical supervision.
- [ ] Messages between actors are immutable.
- [ ] Persistence via event sourcing or snapshot.

## Procedural / dataflow

- [ ] Flow expressed as transformation pipeline.
- [ ] No shared mutation.
- [ ] Isolated independent and testable stages.

## General (any paradigm)

- [ ] Each element points to the origin in the legacy or to `discard_log.md`.
- [ ] Bounded contexts justified by cohesion, not legacy structure.
- [ ] Mermaid Diagram renders without error.
- [ ] Architectural decisions documented in summarized ADR format.
