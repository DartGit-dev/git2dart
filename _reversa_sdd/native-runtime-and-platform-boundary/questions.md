# Native Runtime and Platform Boundary — Open Questions

> 🟢 **CONFIRMED** — These questions define the remaining safety and compatibility proof obligations.

| ID | Question | Interim rule | Confidence |
| --- | --- | --- | --- |
| Q-NP-01 | Are process-global libgit2 options synchronized/snapshot-restorable? | Serialize changes and restore caller policy explicitly. | 🔴 GAP |
| Q-NP-02 | Are static callback bridges safe under overlap? | Serialize callback-bearing operations. | 🔴 GAP |
| Q-NP-03 | How are callback exceptions mapped to native error codes and Dart errors? | Treat as failure and verify cleanup before claiming contract. | 🔴 GAP |
| Q-NP-04 | What if `git_error_last()` is null after a negative result? | Provide safe fallback diagnostic; validate legacy/native behavior. | 🔴 GAP |
| Q-NP-05 | Must every wrapper guard repeated/post-free access? | Treat free as terminal until a uniform guard policy exists. | 🔴 GAP |
| Q-NP-06 | Which sanitizer/leak tooling and platforms gate releases? | Do not infer memory safety solely from unit tests. | 🔴 GAP |
| Q-NP-07 | What exact ABI compatibility evidence is required on dependency upgrade? | Run public declaration diff plus platform load/test matrix. | 🟢 CONFIRMED process; 🔴 GAP formal threshold |
| Q-NP-08 | Is platform initialization idempotent and safe when called repeatedly/concurrently? | Call once during startup. | 🔴 GAP |

## Evidence Needed

- 🔴 **GAP** — ASan/Valgrind/platform-equivalent resource runs with fault injection.
- 🔴 **GAP** — Global option and callback concurrency tests.
- 🔴 **GAP** — Missing/null native error and load/ABI failure tests.
- 🔴 **GAP** — Repeated platform initialization and wrapper release characterization.

## Resolved Facts

- 🟢 **CONFIRMED** — Generated declarations/binaries are external to the high-level package.
- 🟢 **CONFIRMED** — Negative native results use centralized translation.
- 🟢 **CONFIRMED** — Arenas and finalizers serve different lifetimes.
- 🟢 **CONFIRMED** — Android and iOS have explicit startup behavior.
- 🟢 **CONFIRMED** — Pack object size rejects negative input.

