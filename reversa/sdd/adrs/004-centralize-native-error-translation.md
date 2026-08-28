# ADR-004: Centralize Native Error Translation

## Status

Accepted (retrospective).

## Context

libgit2 reports failures as negative integers with details in thread-local/native error state. Repeating checks in every binding caused inconsistency.

## Decision

Route negative return codes through `checkErrorAndThrow`, which constructs `LibGit2Error` from `git_error_last()`. Use Dart argument/range errors for validation that can be decided before calling native code.

Evidence: centralized helper and the May 2025 refactor series including `cc3efa9`, `3317267`, `be47e9b`, and `c1273b0`. 🟢 CONFIRMED.

## Alternatives considered

- Return nullable values or status integers to consumers.
- Throw one generic Dart exception without native detail.
- Inline error checks in every binding.

## Consequences

- Consistent failure behavior and preserved libgit2 diagnostics.
- APIs returning meaningful non-negative status values still require operation-specific interpretation.
- Correctness depends on reading native error state immediately after failure.

