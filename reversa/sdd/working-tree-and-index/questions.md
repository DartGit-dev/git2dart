# Working Tree and Index — Open Questions

> 🟢 **CONFIRMED** — These questions isolate unverified mutation, callback, and lifetime contracts.

| ID | Question | Interim rule | Confidence |
| --- | --- | --- | --- |
| Q-WI-01 | Are checkout/apply/stash operations expected to be atomic on failure? | Assume native partial-state semantics; require caller inspection/recovery. | 🔴 GAP |
| Q-WI-02 | May one index/workdir be mutated concurrently? | Do not claim safety; serialize mutations. | 🔴 GAP |
| Q-WI-03 | May patch/hunk/line views outlive the parent patch/diff? | Copy data or keep the parent alive. | 🔴 GAP |
| Q-WI-04 | What empty-pathspec behavior is contractual per operation? | Preserve current native/wrapper behavior and test each endpoint. | 🔴 GAP |
| Q-WI-05 | Should similarity thresholds be locally range-validated? | Preserve native validation; do not invent clamping. | 🟡 INFERRED |
| Q-WI-06 | What is the required behavior after explicit free? | Treat wrapper as terminally released. | 🔴 GAP |
| Q-WI-07 | Which platform path/symlink/executable semantics are guaranteed? | Report platform-native behavior until normalized contract is approved. | 🔴 GAP |
| Q-WI-08 | Must stash pop retain the entry on every apply failure? | Verify native behavior before documenting a guarantee. | 🔴 GAP |

## Evidence Needed

- 🔴 **GAP** — Inject failure after each checkout/apply/stash mutation stage and capture residual state.
- 🔴 **GAP** — Add callback concurrency and abort tests.
- 🔴 **GAP** — Add parent-release/borrowed-view tests for patch structures.
- 🔴 **GAP** — Run cross-platform path/mode/symlink fixtures.
- 🔴 **GAP** — Instrument native option/list/resource cleanup.

## Resolved Facts

- 🟢 **CONFIRMED** — Conflicted indexes cannot write trees.
- 🟢 **CONFIRMED** — Check-only apply is non-mutating by contract.
- 🟢 **CONFIRMED** — Both-null tree diff is invalid.
- 🟢 **CONFIRMED** — Conflict sides are independently nullable.
- 🟢 **CONFIRMED** — Destructive checkout strategy is an explicit caller choice.

