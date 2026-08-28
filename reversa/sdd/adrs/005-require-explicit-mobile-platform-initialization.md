# ADR-005: Require Explicit Mobile Platform Initialization

## Status

Accepted (retrospective).

## Context

Android needs an accessible CA certificate file for libgit2 transports, while iOS links libgit2 statically and benefits from eager symbol initialization.

## Decision

Provide `PlatformSpecific.initialize()` for Flutter startup. Android initializes certificates through `AndroidSSLHelper`; iOS accesses `Libgit2.version` to load/initialize static symbols.

Evidence: Android lineage in `bbd2bd3`/0.4.0, iOS addition in `83ca090`, and current `platform_specific.dart`. 🟢 CONFIRMED.

## Alternatives considered

- Hide all setup in the first repository/remote call.
- Require each app to manage certificates and native loading manually.
- Support desktop platforms only.

## Consequences

- Startup is predictable and documented across mobile targets.
- Consumers must remember an async initialization step before Git operations.
- Platform helpers remain coupled to companion-package packaging behavior.

