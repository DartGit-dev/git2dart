# ADR-007: Isolate Network-Dependent Tests

## Status

Accepted with known coverage gap (retrospective).

## Context

Remote fetch, credentials, and submodule tests depend on network and previously encountered read-only/environment-specific failures.

## Decision

Tag relevant tests `remote_fetch` and skip that tag in the default Dart test configuration with the reason `Requires network`.

Evidence: `13a11d7`, `da99657`, and `dart_test.yaml`. 🟢 CONFIRMED.

## Alternatives considered

- Run all live-network tests in every local/CI invocation.
- Remove remote integration tests.
- Replace all remote tests with mocks.

## Consequences

- Default tests are more deterministic and offline-friendly.
- Passing default CI does not prove current live network interoperability.
- A separate controlled network suite is desirable but not visible in this repository. 🔴 GAP.

