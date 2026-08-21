# User Stories — References and Remotes

> 🟢 **CONFIRMED** — Stories preserve local reference integrity and caller-owned remote trust.

## US-RR-01 — Update Names Safely

🟢 **CONFIRMED** — As a concurrent Git client, I want direct/symbolic compare-and-set reference updates so that stale expected targets cannot overwrite newer state.

## US-RR-02 — Manage Branch History

🟢 **CONFIRMED** — As a repository tool, I want branches, upstreams, reflogs, and refspec mapping so that tracking and target transitions remain inspectable.

## US-RR-03 — Synchronize with Remotes

🟢 **CONFIRMED** — As an application, I want typed ls/fetch/push/prune operations and progress/update callbacks so that transfer outcomes are observable.

## US-RR-04 — Authenticate without a Library Vault

🟢 **CONFIRMED** — As a caller, I want to provide user/password, keyfile, agent, or in-memory SSH credentials only when requested and allowed.

## US-RR-05 — Own the Trust Decision Explicitly

🟢 **CONFIRMED** — As a security-sensitive caller, I want native-default certificate validation plus optional certificate inspection so that pinning/TOFU policy is explicit.

```gherkin
Dado a presented certificate and native validity result
Quando no callback is supplied or a callback rejects it
Então default validation is preserved or the connection is aborted respectively
```

## Unresolved Persona Need

🔴 **GAP** — Current live transport/platform evidence, callback overlap, exception cleanup, and consumer log redaction remain unverified.

