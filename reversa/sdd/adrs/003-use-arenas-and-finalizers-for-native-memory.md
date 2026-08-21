# ADR-003: Use Arenas and Finalizers for Native Memory

## Status

Accepted (retrospective).

## Context

FFI calls allocate temporary strings/options and persistent libgit2 objects. Leaks, use-after-free, and double-free failures are difficult to diagnose across platforms.

## Decision

Use `using(Arena)` for call-scoped allocation, explicit native destructors for owned objects, and Dart finalizers as a safety net. Manual `free()` detaches the finalizer.

Evidence: `cc3efa9`, `37c3c41`, `f4d4a44`, and current wrapper/binding patterns. 🟢 CONFIRMED.

## Alternatives considered

- Manual `calloc/free` for every temporary allocation.
- Finalizers only, without deterministic release.
- Copy all native objects into Dart and immediately release pointers.

## Consequences

- Deterministic temporary cleanup and safer long-running applications.
- Borrowed versus owned pointer contracts must remain precisely documented.
- Finalizers are nondeterministic and do not replace explicit release for resource-heavy workloads.

