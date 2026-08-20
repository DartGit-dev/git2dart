# History and Integration Operations — Edge Cases

> 🟢 **CONFIRMED** — Stateful integration errors remain distinguishable from successful completion.

| ID | Edge case | Expected behavior | Confidence |
| --- | --- | --- | --- |
| EC-HI-01 | Revision expression is invalid | Throw parse/native error. | 🟢 CONFIRMED |
| EC-HI-02 | Revision resolves to unsupported object kind | Reject typed dispatch. | 🟢 CONFIRMED |
| EC-HI-03 | Walker has no pushed root | Fail rather than return unrelated history. | 🟢 CONFIRMED |
| EC-HI-04 | Walker limit is reached | Return only requested prefix while preserving/resetting walker contract. | 🟢 CONFIRMED |
| EC-HI-05 | Range left/right share ancestry | Native hide/push semantics determine result. | 🟢 CONFIRMED |
| EC-HI-06 | No merge base exists | Return/throw according to typed merge-base contract; do not fabricate OID. | 🟢 CONFIRMED |
| EC-HI-07 | Merge analysis says up-to-date | Do not create commit or mutate workdir. | 🟢 CONFIRMED |
| EC-HI-08 | Merge analysis says fast-forward | Caller policy performs ref/checkout update rather than normal merge commit. | 🟢 CONFIRMED |
| EC-HI-09 | Normal merge creates conflicts | Keep repository/index conflict state until resolution/cleanup. | 🟢 CONFIRMED |
| EC-HI-10 | Cleanup fails after merge | Throw and retain authoritative repository state. | 🟢 CONFIRMED |
| EC-HI-11 | Rebase `next` reaches end | Finish is separate; do not invent another operation. | 🟢 CONFIRMED |
| EC-HI-12 | Rebase operation conflicts | Commit fails until caller resolves index/workdir. | 🟢 CONFIRMED |
| EC-HI-13 | Rebase abort is invoked mid-conflict | Native abort restores pre-rebase state; dynamic interruption proof is limited. | 🟢 CONFIRMED / 🔴 GAP crash case |
| EC-HI-14 | Rebase is reopened | Existing native operation state is wrapped rather than restarted. | 🟢 CONFIRMED |
| EC-HI-15 | Blame path/range is invalid | Throw native validation error. | 🟢 CONFIRMED |
| EC-HI-16 | Blame tracks renamed/copied lines | Flags/options control attribution; exact history depends on repository. | 🟢 CONFIRMED |
| EC-HI-17 | Note already exists and force is false | Reject overwrite. | 🟢 CONFIRMED |
| EC-HI-18 | Mailmap has no mapping | Preserve original identity under native behavior. | 🟢 CONFIRMED |
| EC-HI-19 | Message has malformed/no trailers | Return parsed empty/available result without inventing trailers. | 🟢 CONFIRMED |
| EC-HI-20 | Pack callback aborts/write fails | Throw and characterize partial output/resource cleanup. | 🟢 CONFIRMED / 🔴 GAP residue |
| EC-HI-21 | Submodule missing from config/index/workdir | Status location bitset represents each place independently. | 🟢 CONFIRMED |
| EC-HI-22 | Submodule workdir OID matches but files are dirty | Workdir OID alone is not sufficient; status bits remain authoritative. | 🟢 CONFIRMED |
| EC-HI-23 | Submodule update auth/trust fails | Throw remote error; partial nested state needs characterization. | 🟢 CONFIRMED / 🔴 GAP residue |
| EC-HI-24 | Add setup succeeds but clone/finalize fails | Do not claim completed add; parent/nested recovery is a gap. | 🔴 GAP |
| EC-HI-25 | Stateful wrapper is freed/reused | Post-free/idempotency is not established. | 🔴 GAP |
| EC-HI-26 | Same repository integration operations overlap | Ordering/state safety is not established. | 🔴 GAP |

## Required Characterization

- 🔴 **GAP** — Merge/rebase crash/interruption and retry matrix.
- 🔴 **GAP** — Submodule setup/clone/finalize fault injection and recovery.
- 🔴 **GAP** — Pack partial-output cleanup.
- 🔴 **GAP** — Concurrent integration operation rejection/serialization.

