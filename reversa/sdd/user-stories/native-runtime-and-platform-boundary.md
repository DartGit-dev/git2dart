# User Stories — Native Runtime and Platform Boundary

> 🟢 **CONFIRMED** — Stories express the safety and portability substrate hidden beneath typed Git APIs.

## US-NP-01 — Avoid Raw FFI

🟢 **CONFIRMED** — As a package consumer, I want typed values and exceptions so that I do not manage pointers, C strings, integer masks, or native error codes.

## US-NP-02 — Preserve Native Performance Safely

🟢 **CONFIRMED** — As a maintainer, I want arena-scoped temporary allocation and explicit/finalizer persistent ownership so that native performance does not sacrifice lifecycle safety.

## US-NP-03 — Receive Actionable Native Errors

🟢 **CONFIRMED** — As a developer, I want negative libgit2 results translated immediately with native diagnostics so that failures are consistent and debuggable.

## US-NP-04 — Start Correctly on Mobile

🟢 **CONFIRMED** — As a Flutter application, I want one platform initialization entry point so that Android CA material and iOS static symbols are ready before Git operations.

## US-NP-05 — Upgrade Native Artifacts Deliberately

🟢 **CONFIRMED** — As a maintainer, I want generated API comparison and five-platform validation so that `git2dart_binaries` upgrades do not introduce silent ABI drift.

```gherkin
Dado a proposed git2dart_binaries upgrade
Quando public declarations differ
Então every affected adapter and platform artifact is reviewed and tested before compatibility is claimed
```

## Unresolved Persona Need

🔴 **GAP** — Exhaustive memory instrumentation, global/static concurrency, callback exceptions, repeated initialization, and ABI/load failure diagnostics need validation.

