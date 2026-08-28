# References and Remotes Depth Inspection

## Feature Map

- Specs: the seven `references-and-remotes` artifacts plus architecture, domain, permissions, ADR-003, ADR-004, ADR-006, and ADR-007.
- Code: reference, branch, reflog, refspec, remote, callback, credential, and certificate wrappers and bindings.
- Tests: reference, branch, reflog, remote, credential, callback, and certificate coverage. Live `remote_fetch` cases are skipped by default.
- Data and integrations: Git refs/reflogs/config, HTTPS/SSH transports, credentials, certificates, proxies, borrowed remote data, and native callback/options storage.
- Existing bugs: the native runtime registry was searched before promotion.

## Dedupe Decisions

- SSH key allocation evidence was added to BUG-20260817-47ZS.
- Callback retention evidence was added to restricted BUG-20260817-O3B3.
- Callback overlap evidence was added to BUG-20260817-CIKD.
- Unchecked remote option initializer evidence was added to BUG-20260817-QWMA.
- Five distinct defects were registered as BUG-20260817-3FWN, BUG-20260817-VG7G, BUG-20260817-BVMB, BUG-20260817-VGYQ, and BUG-20260817-2TB4.

## Findings by Lens

| Lens | High-confidence promoted findings | Observations not promoted |
| --- | --- | --- |
| Specification conformity | Missing guaranteed disconnect; null lookup wrappers | Live support and cancellation policy remain open |
| Data flow | Fetch allocation leak; name-to-ID OID leak | Parent-borrowed wrapper lifetime needs dynamic proof |
| Contracts and integrations | Invalid index errors do not match public contracts | Five-platform HTTPS/SSH matrix remains absent |
| Error states and edge cases | Post-connect cleanup bypass; delayed null dereference | Partial fetch/push state and callback exceptions remain gaps |
| Test coverage | Five missing negative or ownership groups | Existing live-tagged tests were not run |
| Concurrency and consistency | Existing overlap bug reconfirmed and deduplicated | Serialization policy still requires product decision |

## Clusters

The strongest cluster is remote operation cleanup and native ownership. Fetch, credential, callback, transport, reference OID, refspec, and reflog paths all depend on explicit native lifetime rules. Existing canonical records were reused where the mechanism matched.

## Confidence

Formal extraction confidence remains 72.3 percent for this unit. Diagnostic confidence increased through five new canonical records and four deduplicated evidence updates. Live interoperability, callback exceptions, cancellation, partial mutation, and parent-borrowed post-free behavior remain gaps.

## Not Covered

- No live remote, proxy, credential, certificate, or mobile platform matrix was executed.
- Flutter and Dart tooling remained blocked by stale external cache locks.
- No source or test file was modified.
