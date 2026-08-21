# Working Tree and Index — Reimplementation Tasks

> 🟢 **CONFIRMED** — Tasks preserve the native mutable-state and conflict semantics identified in the legacy implementation.

## Implementation

- [ ] **T-WI-01 — Implement Index ownership and metadata.** Origin: `lib/src/index.dart`, index bindings. Done when path/version/capabilities/checksum/entries/conflict state and cleanup are typed. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-02 — Implement single-entry mutation.** Origin: `lib/src/index.dart:250-296`. Done when entry/path dispatch, addFromBuffer, update/remove, invalid type/path, and REUC transition match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-03 — Implement bulk pathspec mutation.** Origin: `lib/src/index.dart:311-365`, `436-454`. Done when addAll/updateAll/removeAll callbacks, flags, and arena arrays work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-04 — Implement index persistence and tree serialization.** Origin: `lib/src/index.dart:370-413`. Done when read/write/clear and owner/supplied-repo writeTree work and conflicts fail. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-05 — Implement conflict, NAME, and REUC APIs.** Origin: index conflict sections/bindings/tests. Done when nullable sides, iteration, add/remove/cleanup, rename metadata, and resolve-undo are preserved. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-06 — Implement checkout sources/options/callbacks.** Origin: `lib/src/checkout.dart`. Done when HEAD/index/tree/ref/commit checkout and strategy/path/callback options mutate only intended workdir state. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-07 — Implement diff constructors.** Origin: `lib/src/diff.dart`. Done when all supported endpoint pairs and buffer/blob constructors return owned diffs; both-null trees fail locally. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-08 — Implement diff projection and merge.** Origin: `lib/src/diff.dart`. Done when stats/deltas/files/patch IDs and diff merge preserve native results. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-09 — Implement similarity detection.** Origin: `lib/src/diff.dart:439-459`. Done when flags/default/custom thresholds and limit reach native options. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-10 — Implement check/apply flows.** Origin: `lib/src/diff.dart:338-382`, apply bindings. Done when check-only is non-mutating and full/hunk apply targets workdir/index/both/tree correctly. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-11 — Implement Patch/Hunk/Line.** Origin: `lib/src/patch.dart`. Done when constructors, stats, headers, origins, coordinates, content, and ownership match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-12 — Implement stash lifecycle.** Origin: `lib/src/stash.dart`. Done when save/list/apply/pop/drop and index/path/checkout/callback options match. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-13 — Implement ignore/attribute/filter helpers.** Origin: `ignore.dart`, `attr_options.dart`, `filter.dart`. Done when rules, directions, options, and binary/text outputs match native evaluation. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-14 — Implement Pathspec.** Origin: `lib/src/pathspec.dart`. Done when immutable compile and workdir/index/tree/diff/path matching plus failed patterns work. Confidence: 🟢 **CONFIRMED**.
- [ ] **T-WI-15 — Apply error, ownership, and destructive-policy documentation.** Origin: bindings, ADR-003/004, `permissions.md`. Done when no raw pointer leaks, cleanup is scoped, and forceful strategies are explicit. Confidence: 🟢 **CONFIRMED**.

## Tests

- [ ] **TT-WI-01** — Index positive/negative mutation, persistence, tree-write tests. Origin: `test/index_test.dart`. Done when conflicts and type/path errors are covered. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-WI-02** — Three-way conflict, NAME, REUC lifecycle. Origin: index tests. Done when every nullable side and resolution transition is verified. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-WI-03** — Checkout source/strategy/path/callback and bare/error cases. Origin: checkout tests. Done when destructive targets are isolated fixtures. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-WI-04** — Diff endpoint, stats, merge, similarity tests. Origin: diff tests. Done when default/custom thresholds and both-null rejection are covered. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-WI-05** — Applies/apply full/hunk/location tests. Origin: diff/apply tests. Done when check-only causes no mutation and failure is explicit. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-WI-06** — Patch/hunk/line binary/text/coordinate tests. Origin: patch tests. Done when projection and parent lifetime are verified. Confidence: 🟢 **CONFIRMED** / 🔴 **GAP** lifetime proof.
- [ ] **TT-WI-07** — Stash/pathspec/ignore/filter tests. Origin: corresponding test files. Done when positive and invalid cases pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-WI-08** — Fault-injected cleanup and interruption/rollback characterization. Origin: architecture gaps. Done when partial mutation/resource behavior is documented. Confidence: 🔴 **GAP**.
- [ ] **TT-WI-09** — Cross-platform full suite. Origin: CI. Done when fresh five-platform results are captured. Confidence: 🔴 **GAP** until run.

## Order and Gaps

1. 🟢 **CONFIRMED** — Build Index/conflict foundation (T-WI-01–05).
2. 🟢 **CONFIRMED** — Add checkout/diff/patch (T-WI-06–11).
3. 🟢 **CONFIRMED** — Add stash/matching/filter helpers (T-WI-12–14).
4. 🟢 **CONFIRMED** — Complete ownership/docs/tests (T-WI-15 and TT tasks).

- 🔴 **GAP** — Define transaction/rollback expectations for multi-file mutation.
- 🔴 **GAP** — Define callback concurrency and borrowed patch-view lifetimes.
- 🔴 **GAP** — Complete native allocation/free audit.

