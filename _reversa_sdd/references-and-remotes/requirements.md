# References and Remotes Requirements

> 🟢 **CONFIRMED** — This unit specifies mutable references/branches/reflogs/refspecs and network-facing remote synchronization, credentials, callbacks, progress, and certificate trust.

## Responsibilities and Rules

- 🟢 **CONFIRMED** — Create/read/update/rename/delete direct and symbolic references.
- 🟢 **CONFIRMED** — Provide compare-and-set reference updates with representation-matched expected targets.
- 🟢 **CONFIRMED** — Manage branches, upstream configuration, reflogs, and refspec transforms.
- 🟢 **CONFIRMED** — List/connect/download/fetch/push/prune remotes with typed callbacks/options.
- 🟢 **CONFIRMED** — Project credentials, certificates, transfer progress, sideband, and update status without persisting secrets.

| ID | Rule | Confidence |
| --- | --- | --- |
| BR-RR-01 | OID target creates/updates a direct reference; String target creates/updates a symbolic reference. | 🟢 CONFIRMED |
| BR-RR-02 | `createMatching` requires desired and expected targets both OIDs or both Strings. | 🟢 CONFIRMED |
| BR-RR-03 | Symbolic resolution recursively reaches a direct OID or fails. | 🟢 CONFIRMED |
| BR-RR-04 | Peel supports commit/tree/blob/tag typed targets. | 🟢 CONFIRMED |
| BR-RR-05 | Clearing branch upstream is represented by null. | 🟢 CONFIRMED |
| BR-RR-06 | Remote listing connects in fetch direction and disconnects after advertisements are read. | 🟢 CONFIRMED |
| BR-RR-07 | Default certificate validation remains unless caller supplies the final decision callback. | 🟢 CONFIRMED |
| BR-RR-08 | Certificate/progress/reference callback views are borrowed and must not escape callback lifetime. | 🟢 CONFIRMED |
| BR-RR-09 | Credentials are typed as user/password, SSH key files, SSH agent, or in-memory keys. | 🟢 CONFIRMED |
| BR-RR-10 | Default tests skip network-tagged remote fetch scenarios. | 🟢 CONFIRMED |

## Functional Requirements

| ID | Requirement | Priority | Acceptance summary | Confidence |
| --- | --- | --- | --- | --- |
| FR-RR-01 | Create, lookup, list, resolve, normalize, rename, update, compare-and-set, and delete references. | Must | Direct/symbolic forms retain representation and stale expected targets fail atomically. | 🟢 CONFIRMED |
| FR-RR-02 | Peel references to supported object kinds. | Should | Correct typed wrapper is returned; unsupported kind fails. | 🟢 CONFIRMED |
| FR-RR-03 | Create/list/lookup/move/delete local/remote branches and manage upstream. | Must | HEAD/checked-out/upstream state matches repository config. | 🟢 CONFIRMED |
| FR-RR-04 | Read/write/append/drop/rename reflog entries preserving OIDs, signature, and message. | Should | Entry ordering and old/new targets persist. | 🟢 CONFIRMED |
| FR-RR-05 | Parse, match, and transform refspec source/destination patterns. | Must | Direction, force, match, and transform results match native rules. | 🟢 CONFIRMED |
| FR-RR-06 | Create/configure/list/delete/rename remotes and URL/refspec values. | Must | Repository config reflects requested remote metadata. | 🟢 CONFIRMED |
| FR-RR-07 | List advertised remote references with connection lifecycle cleanup. | Should | Typed advertisements return after disconnect; errors throw. | 🟢 CONFIRMED |
| FR-RR-08 | Fetch/download with refspec, prune, proxy, callbacks, reflog message, and update options. | Must | Objects/refs update and transfer progress is returned or failure throws. | 🟢 CONFIRMED |
| FR-RR-09 | Push with refspec, proxy, credentials, certificate, progress, and ref-status callbacks. | Must | Accepted updates reach remote; rejected refs/errors are reported. | 🟢 CONFIRMED |
| FR-RR-10 | Support typed credentials requested by allowed native credential mechanisms. | Must | Correct credential is returned without library-side secret persistence. | 🟢 CONFIRMED |
| FR-RR-11 | Expose certificate inspection and caller-controlled trust decision. | Must | Callback receives host/native validity/certificate and its bool controls acceptance. | 🟢 CONFIRMED |
| FR-RR-12 | Release remote/reference/reflog/refspec/certificate-related owned native resources. | Must | Owned pointers release once; borrowed callback data does not escape. | 🟢 CONFIRMED |

## Non-Functional Requirements

| Type | Requirement | Confidence |
| --- | --- | --- |
| Security | Never silently disable certificate validation; caller override is explicit and security-sensitive. | 🟢 CONFIRMED |
| Secret handling | Credentials are caller-supplied and not persisted in a library vault. | 🟢 CONFIRMED |
| Network correctness | Live interoperability must be evidenced separately from offline/default tests. | 🟢 CONFIRMED |
| Callback safety | Borrowed callback objects remain callback-scoped. | 🟢 CONFIRMED |
| Concurrency | Static callback bridge isolation under overlap is not established. | 🔴 GAP |

## Acceptance Criteria

🟢 **CONFIRMED**

```gherkin
Dado a reference with a known current Oid
Quando createMatching receives that Oid and a new direct target
Então the reference updates atomically, while a stale expected Oid fails
```

🟢 **CONFIRMED**

```gherkin
Dado a remote and caller callbacks
Quando fetch authenticates, validates the certificate, and transfers objects
Então tips are updated and TransferProgress is returned
```

🟢 **CONFIRMED**

```gherkin
Dado a certificate callback that rejects the presented host
Quando a remote operation validates the certificate
Então the operation aborts with an error and does not report successful transfer
```

## MoSCoW and Traceability

| Capability | Priority | Confidence |
| --- | --- | --- |
| Reference/branch integrity and remote fetch/push trust | Must | 🟢 CONFIRMED |
| Reflog/refspec/advertisement helpers | Should | 🟡 INFERRED |
| Specialized remote rename/prune/status helpers | Could | 🟡 INFERRED |

| Legacy area | Coverage | Confidence |
| --- | --- | --- |
| `reference.dart`, `branch.dart`, `reflog.dart`, `refspec.dart` and tests | local name/history/mapping contracts | 🟢 CONFIRMED |
| `remote.dart`, `callbacks.dart`, `credentials.dart`, `certificate.dart` and tests | network/trust/callback contracts | 🟢 CONFIRMED |
| corresponding binding files | native transport, marshalling, ownership | 🟢 CONFIRMED |

