# History and Integration Operations — Reimplementation Tasks

> 🟢 **CONFIRMED** — Tasks preserve graph order, integration state, conflict gates, and nested-repository boundaries.

## Implementation

- [ ] **T-HI-01 — Implement revision parsing and object dispatch.** Origin: `revparse.dart`. Done when single/ext/range expressions and invalid/unsupported kinds match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-02 — Implement revision walker ownership/configuration.** Origin: `revwalk.dart`. Done when sort/push/hide/range/glob/ref/head/reset and release work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-03 — Implement walk materialization/exhaustion.** Origin: `revwalk.dart:55+`. Done when limits/order/root requirement and automatic reset are verified. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-04 — Implement merge bases and analysis.** Origin: `merge.dart`. Done when base/many-base and result/preference bitsets are typed. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-05 — Implement merge/cherry-pick/revert mutation.** Origin: `merge.dart` and bindings. Done when options, conflicts, index/workdir effects, commit path, and cleanup contract match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-06 — Implement rebase initialization/open and operation projection.** Origin: `rebase.dart`. Done when branches/upstream/onto/options and operation list/current index match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-07 — Implement rebase next/commit/finish/abort.** Origin: `rebase.dart:90-158`. Done when sequencing, conflict gate, signatures/message, final ref/state, and abort restoration match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-08 — Implement blame.** Origin: `blame.dart`. Done when file/buffer options and hunk line/commit/signature/path projection work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-09 — Implement notes.** Origin: `note.dart`. Done when create/read/list/remove, namespace, force, signatures/message/OIDs match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-10 — Implement mailmap and message helpers.** Origin: `mailmap.dart`, `message.dart`. Done when identity resolution, add entries, prettify, and trailer parse match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-11 — Implement packbuilder.** Origin: `packbuilder.dart`. Done when insert/walk/recur/write/foreach/progress/threads/count/name and cleanup work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-12 — Implement submodule metadata/status.** Origin: `submodule.dart`. Done when list/lookup/name/path/url/branch/OIDs/location/status bitsets match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-13 — Implement submodule add/open/init/sync/reload/update.** Origin: `submodule.dart`. Done when setup-clone-finalize and callback-bearing update preserve parent/nested state. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-HI-14 — Apply ownership/state/error documentation.** Origin: ADR-003/004, state machines, permissions. Done when cleanup, borrowed callbacks, conflicts, partial state, and network trust are explicit. Confidence: 🟢 **CONFIRMED**.

## Tests

- [ ] **TT-HI-01** — Revision expression and walker root/hide/order/reset tests. Origin: revparse/revwalk tests. Done when valid and invalid graph cases pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-HI-02** — Merge base/analysis result matrix. Origin: merge tests. Done when up-to-date/fast-forward/unborn/normal/preference are covered. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-HI-03** — Merge conflict/commit/cleanup and cherry-pick/revert tests. Origin: merge tests. Done when state transitions are explicit. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-HI-04** — Rebase clean/conflict/finish/abort/reopen tests. Origin: rebase tests. Done when operation sequencing and recovery match. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-HI-05** — Blame/note/mailmap/message/pack tests. Origin: corresponding tests. Done when positive/negative values and ownership pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-HI-06** — Submodule setup/update/status/open/error tests. Origin: submodule tests. Done when parent/nested repo and callbacks are covered. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-HI-07** — Interruption/idempotency fault injection. Origin: architecture gap. Done when merge/rebase/submodule residual state is characterized. Confidence: 🔴 **GAP**.
- [ ] **TT-HI-08** — Live submodule transport and concurrent callback matrix. Origin: network gap. Done when current five-platform evidence is captured. Confidence: 🔴 **GAP**.

## Order and Gaps

1. 🟢 **CONFIRMED** — Revision foundation, then merge/rebase, then metadata/pack/submodule.
2. 🟢 **CONFIRMED** — Tests run alongside stateful operations with isolated repositories.
- 🔴 **GAP** — Define crash/interruption recovery and retry/idempotency promises.
- 🔴 **GAP** — Define live submodule and concurrent callback support.
- 🔴 **GAP** — Complete stateful-resource error-path audit.

