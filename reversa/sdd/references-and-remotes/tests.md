# References and Remotes — Test Specification

> 🟢 **CONFIRMED** — Offline/local reference tests and controlled live-network tests are separate evidence classes.

## Coverage Matrix

| Area | Positive | Negative/security | Confidence |
| --- | --- | --- | --- |
| Reference | direct/symbolic/createMatching/resolve/peel/update/rename/delete | mixed type, stale target, missing/cyclic/unsupported target | 🟢 CONFIRMED |
| Branch/Reflog/Refspec | create/list/upstream/log/transform | checked-out/missing/invalid pattern/index | 🟢 CONFIRMED |
| Remote config | create/lookup/rename/delete/URL/refspec | duplicate/missing/anonymous constraints | 🟢 CONFIRMED |
| Advertisement | connect/list/copy/disconnect | auth/trust/network error and borrowed lifetime | 🟢 CONFIRMED / 🔴 GAP live |
| Credentials | userpass/keyfile/agent/memory | disallowed type/invalid secret/path | 🟢 CONFIRMED |
| Certificate | default valid, hostkey fields, callback accept/reject | invalid override, unavailable fingerprints, retained view | 🟢 CONFIRMED |
| Fetch/Push | progress, tips, prune, ref status | rejected refs, proxy, interruption, partial state | 🔴 GAP live/current |
| Concurrency | serialized baseline | overlapping callback states/exceptions | 🔴 GAP |

## Acceptance Scenarios

🟢 **CONFIRMED**

```gherkin
Dado a direct reference and its current Oid
Quando createMatching supplies the current and a new Oid
Então the update succeeds once and a repeated stale update fails
```

🟢 **CONFIRMED**

```gherkin
Dado a certificate callback and a borrowed hostkey certificate
Quando the callback rejects the host
Então the remote operation fails and the certificate view is not retained
```

🔴 **GAP**

```gherkin
Dado a disposable HTTPS or SSH remote on each supported platform
Quando fetch and push run with each supported credential and trust policy
Então live results, progress, ref updates, and errors are captured independently from offline tests
```

## Required Live Matrix

| Dimension | Values | Confidence |
| --- | --- | --- |
| Platform | Android, iOS, Linux, macOS, Windows | 🔴 GAP |
| Transport | HTTPS, SSH | 🔴 GAP |
| Credential | user/password/token, key files, SSH agent, in-memory keys | 🔴 GAP |
| Trust | native valid, native invalid/reject, explicit pin/accept | 🔴 GAP |
| Operation | ls, clone, download/fetch/prune, push, submodule update | 🔴 GAP |
| Failure | DNS/connect/proxy/auth/cert/server ref rejection/callback exception | 🔴 GAP |

## Additional Tests

- 🔴 **GAP** — Two overlapping operations with distinct credentials/certificate/progress closures.
- 🔴 **GAP** — Callback exception/cancellation with native resource instrumentation.
- 🔴 **GAP** — Secret scan of captured logs/output.
- 🔴 **GAP** — Advertisement/certificate borrowed-view access after callback/disconnect must be rejected or documented unsafe.
- 🔴 **GAP** — Partial fetch/push ref/object state after failure.

## Gate

- 🟢 **CONFIRMED** — Existing local and mocked/callback tests are the static baseline.
- 🟢 **CONFIRMED** — `remote_fetch` is skipped by default and must never be counted as executed without explicit run evidence.
- 🔴 **GAP** — No fresh live network execution occurred during Writer generation.

