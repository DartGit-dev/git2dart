# ADR-002: Layer Idiomatic Wrappers Over Binding Adapters

## Status

Accepted (retrospective).

## Context

Raw generated declarations expose pointers, integer enums, manual allocation, and C error codes that are unsafe and unidiomatic for package consumers.

## Decision

Expose typed classes under `lib/src/`; confine raw calls and native memory conversion to `lib/src/bindings/`; export safe wrappers from `lib/git2dart.dart`.

Evidence: current directory boundaries and the binding expansion/refactor lineage culminating in `b62d34f`. 🟢 CONFIRMED.

## Alternatives considered

- Export generated declarations directly.
- Put high-level behavior and raw C calls in the same files.
- Implement a remote Git protocol client without libgit2.

## Consequences

- Consumer code remains idiomatic and null-safe.
- Wrapper surface can lag behind native capabilities and requires deliberate expansion.
- Every new native API needs both binding-level and high-level ownership review.

