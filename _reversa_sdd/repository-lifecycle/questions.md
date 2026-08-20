# Repository Lifecycle — Open Questions

> 🟢 **CONFIRMED** — These questions record unresolved contracts found during static extraction. They do not block documentation generation, but a reimplementation must not silently choose answers and label them legacy-compatible.

## Priority Questions

| ID | Question | Why it matters | Current evidence | Default until answered | Confidence |
| --- | --- | --- | --- | --- | --- |
| Q-RL-01 | May one `Repository` wrapper be used concurrently by multiple isolates or native-thread callbacks? | Determines synchronization, callback isolation, and ownership rules. | No centralized thread-safety contract; callback/global state risks are documented. | Treat shared concurrent mutation as unsupported. | 🔴 GAP |
| Q-RL-02 | Must `Repository.free()` and `Worktree.free()` be idempotent? | Determines double-free protection and post-release API design. | Explicit free detaches a finalizer, but no repeated-call guard is documented. | Call exactly once; do not use the wrapper afterward. | 🔴 GAP |
| Q-RL-03 | May a child wrapper outlive its originating repository wrapper? | Affects native parent/child lifetime and use-after-free safety. | Child APIs return separately wrapped native pointers, but no universal lifetime statement exists. | Keep the repository alive until child ownership is verified. | 🔴 GAP |
| Q-RL-04 | Which SHA-256 repository operations are release-supported? | Affects open, OID lookup, status, reset, history, describe, pack, and remote compatibility. | `oidType` and SHA-256-aware validation exist; end-to-end proof does not. | Claim only behavior covered by fresh object-format tests. | 🔴 GAP |
| Q-RL-05 | Which clone transports, credentials, and trust policies must pass on each platform? | Defines the live interoperability release gate. | Default tests skip `remote_fetch`; platform initialization and certificate callback exist. | Separate static/offline success from live HTTPS/SSH proof. | 🔴 GAP |
| Q-RL-06 | Should `createCommitOnHead` be atomic from the caller's perspective? | It clears/stages the index before tree/commit creation, so later failure may leave partial state. | The convenience method has no explicit rollback. | Document partial mutation and require caller recovery. | 🔴 GAP |
| Q-RL-07 | What path case/separator normalization is contractual across platforms? | Affects discover/open/status/worktree behavior and portable tests. | Behavior is largely delegated to OS/libgit2. | Preserve native platform semantics; normalize only test expectations. | 🔴 GAP |
| Q-RL-08 | Is finalizer-only cleanup acceptable for long-lived/high-volume repository usage? | Nondeterministic cleanup may retain native resources. | ADR-003 describes finalizers as a fallback. | Require explicit release for resource-heavy workloads. | 🟢 CONFIRMED design rule; 🔴 GAP for usage threshold |

## Validation Requests

### Ownership and concurrency

- 🔴 **GAP** — Run instrumented repeated-release and post-release calls to define supported failure behavior.
- 🔴 **GAP** — Run overlapping status/reset/clone operations with distinct callbacks to detect shared-state interference.
- 🔴 **GAP** — Trace repository and child-wrapper destruction order under explicit release and garbage collection.

### Compatibility

- 🔴 **GAP** — Execute an operation matrix against SHA-1 and SHA-256 repositories.
- 🔴 **GAP** — Execute clone/open/status/worktree tests on Android, iOS, Linux, macOS, and Windows with the current binary package.
- 🔴 **GAP** — Capture live HTTPS and SSH clone evidence for each supported credential and certificate mode.

### Convenience semantics

- 🔴 **GAP** — Add dedicated tests for `headCommit` and `createCommitOnHead`, including unborn HEAD, empty file list, staging failure, and commit failure.
- 🔴 **GAP** — Decide whether convenience-flow rollback is required or partial index mutation is an accepted documented consequence.

## Non-Questions Resolved by Evidence

- 🟢 **CONFIRMED** — `setHead` distinguishes `Oid` from `String` and rejects other runtime types.
- 🟢 **CONFIRMED** — Bare repositories do not support workdir-dependent status.
- 🟢 **CONFIRMED** — Native `current` status is numeric zero and maps to an empty Dart status set.
- 🟢 **CONFIRMED** — Successful manual release detaches the matching finalizer.
- 🟢 **CONFIRMED** — Missing repository/worktree acquisition is an exception, not nullable success.

