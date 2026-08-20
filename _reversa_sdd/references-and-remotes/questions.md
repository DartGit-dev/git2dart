# References and Remotes — Open Questions

> 🟢 **CONFIRMED** — These questions define the remaining live-network, concurrency, and security evidence gap.

| ID | Question | Interim rule | Confidence |
| --- | --- | --- | --- |
| Q-RR-01 | Are callback bridges safe for overlapping operations? | Serialize remote operations unless isolation is proven. | 🔴 GAP |
| Q-RR-02 | Which HTTPS/SSH credential combinations are release-supported per platform? | Report only combinations with fresh live evidence. | 🔴 GAP |
| Q-RR-03 | What certificate-pinning/TOFU examples are officially recommended? | Preserve default validation; treat override as caller security code. | 🔴 GAP |
| Q-RR-04 | How are Dart callback exceptions translated and cleaned up? | Treat exception as operation failure; verify native cleanup. | 🔴 GAP |
| Q-RR-05 | Must the library redact secrets passed to callbacks? | Never log secrets internally; consumer logs remain caller responsibility. | 🔴 GAP |
| Q-RR-06 | What cancellation/timeouts are contractually supported? | Do not invent retry/timeout semantics absent evidence. | 🔴 GAP |
| Q-RR-07 | Are partial fetch/push updates possible on failure and how are they reported? | Inspect repository/remote result and callbacks; do not infer rollback. | 🔴 GAP |
| Q-RR-08 | What post-free behavior is supported for remote/reference wrappers? | Treat explicit free as terminal. | 🔴 GAP |

## Evidence Needed

- 🔴 **GAP** — Controlled disposable remote matrix for five platforms, protocols, credentials, proxy, native-valid/invalid certificates.
- 🔴 **GAP** — Concurrent distinct-callback and exception/cancellation tests.
- 🔴 **GAP** — Secret scanning of library-owned diagnostics and documented consumer callback guidance.
- 🔴 **GAP** — Partial ref-update behavior capture for fetch/push failure.

## Resolved Facts

- 🟢 **CONFIRMED** — Direct and symbolic targets are distinct representations.
- 🟢 **CONFIRMED** — `createMatching` provides expected-value atomicity.
- 🟢 **CONFIRMED** — Default certificate validation is preserved without a callback.
- 🟢 **CONFIRMED** — Callback certificate/advertisement views are borrowed.
- 🟢 **CONFIRMED** — The normal test configuration skips network-tagged cases.

