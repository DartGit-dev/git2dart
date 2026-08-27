# Roadmap: Open Defects Remediation

> Identifier: `004-open-defects-remediation`
> Date: `2026-08-27`
> Requirements: `reversa/forward/004-open-defects-remediation/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Summary of the approach

This feature is a corrective delta over the existing hand-written binding
adapters and a small number of high-level wrappers. It remediates all twelve
records currently marked `open`, in risk-ordered batches: establish native
initializer/error safety and remote callback isolation, correct deterministic
ownership leaks, then run focused and full regression gates. No generated
declaration, public API, persistent Git data model, or external service
contract changes.

## 2. Applied principles

| Principle | Relationship | Status |
|---|---|---|
| I. Preserve the Safe Public Dart Facade | Repairs stay below public signatures. | respects |
| II. Keep Generated Artifacts in the Companion Boundary | No generated FFI files are regenerated or vendored. | respects |
| III. Preserve Native ABI and Memory Ownership Safety | Core purpose: explicit ownership and guaranteed cleanup. | respects |
| IV. Translate Native Failures at One Boundary | QWMA and L8WX route errors through the shared boundary. | respects |
| V. Keep Supported Platform Initialization Explicit | No platform-init behavior is removed or deferred. | respects |
| VI. Make Validation Evidence Match Its Scope | Local, CI, and live-remote evidence remain separately reported. | respects |

## 3. Technical decisions

| ID | Decision | Rationale | Rejected alternative | Confidence |
|---|---|---|---|---|
| D-01 | Check every fallible options initializer immediately with the shared error helper. | Prevents invalid ABI layouts reaching libgit2 (QWMA). | Per-call ad-hoc exceptions; using uninitialized structs. | 🟢 |
| D-02 | Make remote callback dispatch operation-local; if FFI callback payload isolation is unavailable, serialize overlapping operations at the public boundary. | Static callback fields violate FR-NP-08 (CIKD). | Keep shared fields and document races. | 🟡 |
| D-03 | Use `try/finally` or existing ownership abstractions around all temporary native outputs. | Ensures success, error, and partial-init cleanup. | Cleanup after only successful calls. | 🟢 |
| D-04 | Copy returned OID/string data into managed Dart storage before freeing transient native memory. | Preserves facade safety and avoids ownership ambiguity. | Expose/raw-retain temporary pointers. | 🟢 |
| D-05 | Preserve absence-vs-error semantics for repository identity. | Empty identity is not proof of native success (L8WX). | Return empty/partial output after native failure. | 🟢 |

## 4. Assumptions

| Assumption | Origin | Risk if wrong |
|---|---|---|
| The existing generated callbacks support operation-local payload context; otherwise serialization is the safe compatible fallback. | CIKD record, static inspection | Remote concurrency may need a documented behavioral restriction. |
| Native allocation instrumentation is available in CI or a controlled harness. | Acceptance criteria of ownership bugs | Tests can prove behavior but not allocation growth locally. |

## 5. Architectural delta

| Component | Source | Change | Summary |
|---|---|---|---|
| Native binding adapters | `reversa/sdd/architecture.md` | rule-altered | Add error checks and deterministic cleanup around temporary native structures. |
| References and remotes | `reversa/sdd/architecture.md` | rule-altered | Isolate or serialize remote callback dispatch and correct reference OID ownership. |
| Repository lifecycle | `reversa/sdd/architecture.md` | rule-altered | Propagate identity errors and release worktree temporaries. |
| Working tree and index | `reversa/sdd/architecture.md` | rule-altered | Guarantee checkout and OID-output cleanup. |
| History and integration operations | `reversa/sdd/architecture.md` | rule-altered | Release merge options and commit buffers. |

## 6. Data delta

No persistent Git schema or user-data migration. The lifecycle of ephemeral
native buffers, OIDs, handles, and option structures changes only. Detail:
`data-delta.md`.

## 7. External contracts

No HTTP, queue, gRPC, GraphQL, or file-format contract changes. Remote Git
transport remains the same; CIKD may impose internal serialization only if
operation-local callback payloads cannot be proven.

## 8. Implementation batches and dependencies

1. **B0 — evidence baseline:** register each record as active when work begins;
   capture focused reproductions and identify exact owners before edits.
2. **B1 — P1 safety boundary:** QWMA first, then CIKD. CIKD must not rely on
   static callback replacement. Gate: focused negative initializer tests and
   controlled-overlap tests.
3. **B2 — deterministic native cleanup:** K2RY, P5DB, X4AE, 3PON, 2TB4,
   N4FC, Q6JV, M2VF, and Y7GX. These may proceed in non-overlapping file
   groups after B1's error-path convention is established. Gate: success and
   failure cleanup tests plus instrumentation where available.
4. **B3 — error semantics:** L8WX after QWMA's shared error path is verified.
   Gate: distinguish no configured identity from a native lookup failure.
5. **B4 — delivery evidence:** run format, zero-warning analysis, targeted
   tests, full tests, supported CI matrix, specification verdict, merge and
   published release evidence. Only then mark records resolved under package
   closure policy.

## 9. Risks and mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Callback payload ABI lacks per-operation context | high | medium | Serialize entry to remote operations, add overlap regression test, record compatibility impact. |
| Cleanup is added on success but not thrown paths | high | medium | Require `finally`-based and negative-path tests per affected owner. |
| Generated declaration mismatch | high | low | Do not regenerate; validate against the installed companion API and platform artifacts. |
| Instrumentation unavailable locally | medium | high | Record local boundary and require CI/harness allocation evidence. |
| Concurrent source edits overlap | medium | medium | Batch by file ownership and rebase validation on current working tree. |

## 10. Done criteria

- [ ] All 12 included records have confirmed root cause and linked focused tests.
- [ ] B1–B3 changes pass formatting, zero-warning analysis, focused tests, and full suite.
- [ ] CI demonstrates the supported platform matrix; live remote behavior is reported separately.
- [ ] A specification verdict and regression-watch evidence are attached.
- [ ] Fixed package version is merged and published, with required backports.
- [ ] Only then are `resolution_kind`, `DONE.md`, and `resolved` status recorded.

## 11. Change history

| Date | Change | Author |
|---|---|---|
| 2026-08-27 | Initial remediation plan for the twelve currently open records. | reversa-plan |
