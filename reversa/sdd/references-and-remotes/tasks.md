# References and Remotes — Reimplementation Tasks

> 🟢 **CONFIRMED** — Tasks preserve local name integrity and explicit remote authentication/trust boundaries.

## Implementation

- [ ] **T-RR-01 — Implement reference ownership and direct/symbolic creation.** Origin: `reference.dart` and binding/tests. Done when lookup/list/create/type/target/name/release match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-02 — Implement atomic `createMatching`.** Origin: `reference.dart:85-116`. Done when matched OID/String forms update and mixed/stale forms fail. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-03 — Implement resolve, peel, target update, rename, normalize, delete.** Origin: `reference.dart`. Done when recursion/object dispatch/errors preserve native semantics. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-04 — Implement branch lifecycle and upstream configuration.** Origin: `branch.dart`. Done when local/remote list/create/lookup/move/delete and HEAD/checked-out/upstream values match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-05 — Implement reflog lifecycle.** Origin: `reflog.dart`. Done when ordered entries, append/drop/write/rename, signatures/messages/OIDs, and cleanup work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-06 — Implement refspec parse/match/transform.** Origin: `refspec.dart`. Done when direction/force/source/destination and forward/reverse transforms match native patterns. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-07 — Implement remote configuration lifecycle.** Origin: `remote.dart`. Done when create/anonymous/createWithFetchspec/list/lookup/rename/delete/URLs/refspecs persist correctly. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-08 — Implement credential types and allowed-type selection.** Origin: `credentials.dart`, callback bindings. Done when plaintext/keyfile/agent/memory key credentials are built only when allowed and secrets are not persisted. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-09 — Implement certificate wrappers and trust callback.** Origin: `certificate.dart`, `callbacks.dart`, ADR-006. Done when host/native validity/type/fingerprints/raw hostkey are projected within callback lifetime and bool controls acceptance. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-10 — Implement callback bridge.** Origin: `callbacks.dart` and bindings. Done when sideband/credentials/certificate/transfer/update/push callbacks carry typed data and abort/error semantics. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-11 — Implement remote advertisement listing.** Origin: `remote.dart:250-282`. Done when fetch-direction connect/read/copy/disconnect returns typed refs or throws. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-12 — Implement download/fetch/prune.** Origin: `remote.dart`, remote bindings. Done when refspec/prune/proxy/callback/reflog options and returned stats/update effects match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-13 — Implement push.** Origin: `remote.dart`, push bindings. Done when objects/ref updates and push progress/status errors match native behavior. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-RR-14 — Apply ownership/security documentation.** Origin: `permissions.md`, ADR-003/006/007. Done when borrowed lifetimes, secret/trust responsibility, live-test gap, and release contracts are public. Confidence: 🟢 **CONFIRMED**.

## Tests

- [ ] **TT-RR-01** — Direct/symbolic/matching/stale/mixed reference tests. Origin: reference tests. Done when type and atomicity pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RR-02** — Branch/upstream/reflog/refspec tests. Origin: corresponding test files. Done when positive and invalid states pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RR-03** — Remote config and advertisement lifecycle tests. Origin: remote tests. Done when disconnect and copied-data lifetime are verified. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RR-04** — Credential type/allowed-mask tests. Origin: credential/callback tests. Done when disallowed types fail without secret retention. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RR-05** — Certificate valid/invalid/override/hostkey projection tests. Origin: certificate callback tests. Done when default and caller decisions differ explicitly. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RR-06** — Controlled live fetch/push HTTPS/SSH matrix. Origin: skipped `remote_fetch` tests. Done when current platform/binary results are captured. Confidence: 🔴 **GAP**.
- [ ] **TT-RR-07** — Overlapping callback isolation/exception tests. Origin: architecture gap. Done when static bridge does not cross-contaminate or concurrency is forbidden. Confidence: 🔴 **GAP**.
- [ ] **TT-RR-08** — Native cleanup and secret-log audit. Origin: permissions/ownership gaps. Done when no leak/double release/secret logging is found. Confidence: 🔴 **GAP**.

## Order and Gaps

1. 🟢 **CONFIRMED** — Local refs/branches/reflogs/refspecs first (T-RR-01–06).
2. 🟢 **CONFIRMED** — Remote config, credentials, certificates, callbacks (T-RR-07–10).
3. 🟢 **CONFIRMED** — Network operations and documentation (T-RR-11–14).
4. 🟢 **CONFIRMED** — Offline tests, then controlled live/concurrency/security characterization.

- 🔴 **GAP** — Define callback concurrency policy.
- 🔴 **GAP** — Define live platform/transport release matrix.
- 🔴 **GAP** — Define required secret-redaction guidance and trust policy examples.

