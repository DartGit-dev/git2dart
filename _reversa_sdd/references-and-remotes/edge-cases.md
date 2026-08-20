# References and Remotes — Edge Cases

> 🟢 **CONFIRMED** — Security-sensitive and representation-sensitive boundaries are explicit.

| ID | Edge case | Expected behavior | Confidence |
| --- | --- | --- | --- |
| EC-RR-01 | Desired reference target is neither OID nor String | Reject locally. | 🟢 CONFIRMED |
| EC-RR-02 | `createMatching` mixes OID and String | Reject locally; do not coerce. | 🟢 CONFIRMED |
| EC-RR-03 | Expected target is stale | Native atomic comparison fails. | 🟢 CONFIRMED |
| EC-RR-04 | Symbolic reference chain is missing/cyclic | Resolution fails explicitly. | 🟢 CONFIRMED |
| EC-RR-05 | Peel target type is unsupported | Throw typed/native error. | 🟢 CONFIRMED |
| EC-RR-06 | Reference rename/delete targets checked-out/current state | Native safety rules are authoritative. | 🟢 CONFIRMED |
| EC-RR-07 | Branch upstream is null | Clear tracking configuration. | 🟢 CONFIRMED |
| EC-RR-08 | Branch is checked out in another worktree | `isCheckedOut` reflects linked worktree state; mutation may fail natively. | 🟢 CONFIRMED |
| EC-RR-09 | Reflog is absent | Has-log/read behavior uses documented absence/error. | 🟢 CONFIRMED |
| EC-RR-10 | Refspec does not match input | Match is false; transform must not invent output. | 🟢 CONFIRMED |
| EC-RR-11 | Remote is anonymous or has no configured name | Preserve anonymous remote semantics; config mutation requiring name may fail. | 🟢 CONFIRMED |
| EC-RR-12 | `ls` connection/auth/trust fails | Throw and ensure disconnect/temporary cleanup. | 🟢 CONFIRMED |
| EC-RR-13 | Advertisement data retained as raw pointer after disconnect | Unsupported; copy before disconnect. | 🟢 CONFIRMED |
| EC-RR-14 | Credential type requested is not allowed | Do not construct/use that credential. | 🟢 CONFIRMED |
| EC-RR-15 | User/password used over unprotected transport | Library permits typed credential but security is caller/transport responsibility. | 🟢 CONFIRMED |
| EC-RR-16 | SSH key file/path/passphrase is invalid | Credential/native auth fails explicitly. | 🟢 CONFIRMED |
| EC-RR-17 | Hostkey fingerprint/raw bytes unavailable | Expose null rather than fabricated data. | 🟢 CONFIRMED |
| EC-RR-18 | Native certificate validity is false and callback returns true | Connection is accepted under caller override responsibility. | 🟢 CONFIRMED |
| EC-RR-19 | Callback rejects a natively valid certificate | Remote operation aborts. | 🟢 CONFIRMED |
| EC-RR-20 | Certificate object retained after callback | Unsupported borrowed-lifetime use. | 🟢 CONFIRMED |
| EC-RR-21 | Fetch refspec list is empty | Native configured refspec/default behavior applies. | 🟡 INFERRED |
| EC-RR-22 | Fetch succeeds but one update callback reports unusual state | Final native result and callback evidence must both be retained. | 🟡 INFERRED |
| EC-RR-23 | Push server rejects one ref | Per-ref status reports rejection; do not report universal success. | 🟢 CONFIRMED |
| EC-RR-24 | Proxy is invalid/unreachable | Translate transport error. | 🟢 CONFIRMED |
| EC-RR-25 | Remote cancellation/callback exception occurs midway | Cleanup/error translation needs dynamic proof. | 🔴 GAP |
| EC-RR-26 | Two remote operations overlap with distinct callbacks | Isolation is not established. | 🔴 GAP |
| EC-RR-27 | Network tests are skipped | Default green suite is not live interoperability proof. | 🟢 CONFIRMED |
| EC-RR-28 | Android CA initialization was omitted | TLS may fail; exact error varies. | 🟢 CONFIRMED requirement / 🔴 GAP error shape |
| EC-RR-29 | Explicit remote/reference free repeated | Idempotency is not established. | 🔴 GAP |
| EC-RR-30 | Secret appears in consumer callback logging | Library has no redaction guarantee for consumer logs. | 🔴 GAP |

## Required Characterization

- 🔴 **GAP** — Live HTTPS/SSH/proxy/credential/trust matrix on five platforms.
- 🔴 **GAP** — Concurrent callback isolation and callback-exception cleanup.
- 🔴 **GAP** — Native handle/buffer cleanup under transport cancellation.
- 🔴 **GAP** — Secret-redaction guidance and test harness policy.

