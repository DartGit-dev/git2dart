# Native Runtime and Platform Boundary — Reimplementation Tasks

> 🟢 **CONFIRMED** — These tasks are prerequisites for every binding-backed feature.

## Implementation

- [ ] **T-NP-01 — Integrate compatible generated declarations/native artifacts.** Origin: `pubspec.yaml`, ADR-001. Done when dependency API comparison is reviewed and all target artifacts load. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-02 — Implement libgit2 lifecycle/version/features.** Origin: `libgit2.dart`. Done when init/shutdown/version/features return typed results. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-03 — Implement UTF-8/null/array/flag marshalling helpers.** Origin: `extensions.dart`, bindings. Done when native values are exact and arena-scoped. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-04 — Implement centralized error hierarchy/translation.** Origin: `error.dart`, `error_helper.dart`, ADR-004. Done when negative results immediately produce detailed `LibGit2Error` and local validation remains distinct. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-05 — Implement persistent wrapper finalizer pattern.** Origin: wrapper finalizers, ADR-003. Done when owned pointer has matching destructor, explicit detach, and no borrowed finalizer. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-06 — Implement native buffers/options/manual temporary cleanup.** Origin: binding files. Done when every successful/error path disposes matching resources. Confidence: 🟢 **CONFIRMED** goal / 🔴 **GAP** exhaustive proof.
- [ ] **T-NP-07 — Implement callback bridges and lifetime projection.** Origin: callback bindings. Done when typed closure data/results/errors and borrowed lifetimes work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-08 — Implement Android bootstrap.** Origin: `platform_specific.dart:12-23`. Done when native load, CA extraction, and SSL file configuration precede TLS use. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-09 — Implement iOS bootstrap.** Origin: `platform_specific.dart:25-34`. Done when static symbols/load initialize through version access. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-10 — Implement global filesystem/SSL/search options.** Origin: `libgit2.dart`. Done when nullable path semantics and required file-or-path validation match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-11 — Implement cache/mmap/safety/extension/owner options.** Origin: `libgit2.dart`. Done when typed setters/getters map to correct native options. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-12 — Implement pack safety limits and cached-memory projection.** Origin: `libgit2.dart`, commit `a725bac`. Done when non-negative validation and current/allowed bytes match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-NP-13 — Document pointer ownership, process-global effects, bootstrap, and ABI policy.** Origin: architecture/ADRs. Done when every public/native boundary is explicit. Confidence: 🟢 **CONFIRMED**.

## Tests

- [ ] **TT-NP-01** — Error translation and local validation tests. Done when native class/message and argument errors are distinct. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-NP-02** — Marshal round-trip tests for Unicode/null/arrays/enums/bitmasks. Done when bytes and cleanup are exact. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-NP-03** — Ownership instrumentation across success/error/transfer/borrow paths. Done when no leak/double free/use-after-free is observed. Confidence: 🔴 **GAP**.
- [ ] **TT-NP-04** — Android/iOS device bootstrap tests. Done when CA/static symbols and remote readiness are verified. Confidence: 🟢 **CONFIRMED** CI intent / 🔴 **GAP** fresh run.
- [ ] **TT-NP-05** — Desktop loader/ABI tests. Done when Linux/macOS/Windows current artifacts load and focused/full tests pass. Confidence: 🔴 **GAP** until run.
- [ ] **TT-NP-06** — Global option set/get/invalid/concurrency tests. Done when effects and serialization policy are documented. Confidence: 🟢 **CONFIRMED** baseline / 🔴 **GAP** concurrency.
- [ ] **TT-NP-07** — Callback overlap/exception tests. Done when isolation or explicit prohibition is proven. Confidence: 🔴 **GAP**.

## Order and Gaps

1. 🟢 **CONFIRMED** — ABI/runtime/error/marshal base (T-NP-01–04).
2. 🟢 **CONFIRMED** — Ownership/callbacks (T-NP-05–07).
3. 🟢 **CONFIRMED** — Platform bootstrap/options/docs (T-NP-08–13).
- 🔴 **GAP** — Complete native allocation/free proof.
- 🔴 **GAP** — Global/static concurrency policy.
- 🔴 **GAP** — Fresh five-platform ABI/runtime evidence.

