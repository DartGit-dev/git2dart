# History and Integration Operations — Open Questions

> 🟢 **CONFIRMED** — These questions isolate recovery, concurrency, and live nested-repository contracts.

| ID | Question | Interim rule | Confidence |
| --- | --- | --- | --- |
| Q-HI-01 | What crash/interruption recovery is guaranteed for merge/rebase? | Use libgit2 repository state and require explicit inspection/cleanup. | 🔴 GAP |
| Q-HI-02 | Are retries idempotent after partial integration mutation? | Do not retry blindly; inspect state/index first. | 🔴 GAP |
| Q-HI-03 | May merge/rebase/cherry-pick overlap on one repository? | Serialize stateful integration operations. | 🔴 GAP |
| Q-HI-04 | What rebase operation kinds, including exec, are fully supported? | Claim only wrappers and tests currently present. | 🔴 GAP |
| Q-HI-05 | What parent/nested recovery is required after submodule add failure? | Treat setup/clone/finalize as potentially partial. | 🔴 GAP |
| Q-HI-06 | Which live submodule protocols/credentials/platforms are release-supported? | Require fresh controlled network evidence. | 🔴 GAP |
| Q-HI-07 | How should partial pack files/callback output be handled on failure? | Do not claim automatic cleanup beyond observed native behavior. | 🔴 GAP |
| Q-HI-08 | Are blame/mailmap/message encodings normalized? | Preserve native decoded values; validate non-UTF8 cases. | 🔴 GAP |

## Evidence Needed

- 🔴 **GAP** — Process interruption/fault injection at every merge/rebase transition.
- 🔴 **GAP** — Submodule setup/clone/finalize/update recovery matrix.
- 🔴 **GAP** — Live nested remote matrix and callback isolation.
- 🔴 **GAP** — Pack output failure and resource cleanup instrumentation.

## Resolved Facts

- 🟢 **CONFIRMED** — Merge analysis precedes policy selection.
- 🟢 **CONFIRMED** — Rebase conflicts block current operation commit.
- 🟢 **CONFIRMED** — Rebase abort and finish are distinct terminal paths.
- 🟢 **CONFIRMED** — Submodule dirty state cannot be inferred from workdir OID alone.

