# Git Objects and Object Database — Reimplementation Tasks

> 🟢 **CONFIRMED** — Every task cites the legacy behavior needed to reconstruct this feature without exposing raw native APIs.

## Preconditions

- [ ] **P-OBJ-01** — Repository ownership, shared error translation, arena conversion, and generated declarations are available. Source: `repository.dart`, `error_helper.dart`, `extensions.dart`. Confidence: 🟢 **CONFIRMED**.
- [ ] **P-OBJ-02** — Tests can create isolated repositories and binary fixtures. Source: `test/helpers/util.dart`. Confidence: 🟢 **CONFIRMED**.

## Implementation Tasks

- [ ] **T-OBJ-01 — Implement OID validation and ownership.**
  - Legacy origin: `lib/src/oid.dart`, `lib/src/bindings/oid.dart`.
  - Done when: full/prefix parsing, lookup, copy, comparison, shortening, string conversion, invalid/ambiguous errors, and release match the legacy contract.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-02 — Implement signatures.**
  - Legacy origin: `lib/src/signature.dart`, signature bindings/tests.
  - Done when: name, email, timestamp, timezone offset/sign, default identity, equality, and cleanup round-trip correctly.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-03 — Implement commit lookup and projection.**
  - Legacy origin: `lib/src/commit.dart`.
  - Done when: OID, message variants, author/committer, tree, ordered parents, ancestry lookup, and release are typed and tested.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-04 — Implement commit creation and buffer serialization.**
  - Legacy origin: `lib/src/commit.dart:65-132`, commit bindings/tests.
  - Done when: root/normal/merge parent counts and order are preserved, optional reference updates work, and buffer creation has no ODB write side effect.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-05 — Implement commit amendment.**
  - Legacy origin: `lib/src/commit.dart:133-189`.
  - Done when: only non-null fields change, existing parents remain, and a new OID is returned.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-06 — Implement tree and tree-entry access.**
  - Legacy origin: `lib/src/tree.dart`.
  - Done when: index/name/path selection, entry metadata, supported target conversion, traversal, and invalid selector/type behavior match tests.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-07 — Implement immutable tree updates.**
  - Legacy origin: `lib/src/tree.dart:63-90`.
  - Done when: null-OID removal and non-null upsert with file mode produce the expected new tree.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-08 — Implement TreeBuilder.**
  - Legacy origin: `lib/src/treebuilder.dart` and bindings/tests.
  - Done when: source-tree initialization, insert/get/remove/clear/filter/write, duplicate replacement, errors, and ownership are covered.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-09 — Implement blob creation and projection.**
  - Legacy origin: `lib/src/blob.dart` and bindings/tests.
  - Done when: bytes/text, binary heuristic, disk/workdir/buffer creation, filtering where exposed, OID, size, and release match behavior.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-10 — Implement streaming blob writes.**
  - Legacy origin: `lib/src/writestream.dart`, blob stream bindings/tests, commit `f4d4a44`.
  - Done when: bytes/text writes, commit-to-OID, abort/free, ownership transfer, and finalizer detachment prevent double release.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-11 — Implement tag lifecycle and target dispatch.**
  - Legacy origin: `lib/src/tag.dart`, tag bindings/tests.
  - Done when: lightweight/annotated create, duplicate force policy, lookup/list/delete/peel, tagger/message, supported targets, and errors match.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-12 — Implement ODB read/write/hash and validation.**
  - Legacy origin: `lib/src/odb.dart:120-170` and ODB bindings/tests.
  - Done when: concrete types round-trip raw bytes and pseudo/delta types are rejected before native write/hash.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-13 — Implement ODB enumeration, backends, refresh, and object wrappers.**
  - Legacy origin: `lib/src/odb.dart`.
  - Done when: exists/prefix/read/header/foreach/backend/refresh behavior and borrowed callback lifetimes are correct.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-14 — Implement annotated commits and commit graph.**
  - Legacy origin: `lib/src/annotated.dart`, `lib/src/commit_graph.dart` and tests.
  - Done when: reference/fetchhead/revspec/lookup construction and graph reachability answers match libgit2.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **T-OBJ-15 — Apply ownership and error policy across every object adapter.**
  - Legacy origin: `lib/src/bindings/*`, ADR-003, ADR-004.
  - Done when: temporary buffers unwind, owned pointers have one destructor path, borrowed entries are copied/limited, and native errors are translated immediately.
  - Confidence: 🟢 **CONFIRMED** behavior; 🔴 **GAP** exhaustive dynamic proof.
- [ ] **T-OBJ-16 — Document all public object symbols.**
  - Legacy origin: public wrapper files and `AGENTS.md`.
  - Done when: ownership, repository affinity, mutation/new-OID semantics, binary/text behavior, and error contracts have `///` documentation.
  - Confidence: 🟢 **CONFIRMED**.

## Test Tasks

- [ ] **TT-OBJ-01** — OID valid/invalid/full/prefix/ambiguous/shorten/equality tests. Origin: `test/oid_test.dart`. Done when positive and negative cases pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-OBJ-02** — Root, normal, merge, buffer, amend, and cross-repository commit tests. Origin: `test/commit_test.dart`. Done when content and parent order are verified. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-OBJ-03** — Tree selection/update/builder/object-dispatch tests. Origin: tree/treebuilder tests. Done when removal/upsert and invalid paths/types pass. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-OBJ-04** — Binary/text/disk/workdir/stream blob tests. Origin: blob/write-stream tests. Done when bytes and ownership are verified. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-OBJ-05** — Tag create/force/lookup/peel/delete tests. Origin: `test/tag_test.dart`. Done when all supported target types and duplicates are covered. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-OBJ-06** — ODB concrete/pseudo type, raw bytes, prefix, foreach, and backend tests. Origin: ODB tests. Done when invalid types fail locally. Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-OBJ-07** — Explicit/finalizer/error-path native ownership tests. Origin: manual release tests and ADR-003. Done when instrumentation finds no leak/double release. Confidence: 🔴 **GAP**.
- [ ] **TT-OBJ-08** — SHA-1/SHA-256 operation matrix. Origin: architecture gap. Done when every public object operation has a recorded verdict per format. Confidence: 🔴 **GAP**.
- [ ] **TT-OBJ-09** — Cross-platform formatting, analysis, and focused/full tests. Origin: CI workflow. Done when fresh results are captured separately from historical logs. Confidence: 🔴 **GAP** until run.

## Order

1. 🟢 **CONFIRMED** — Implement T-OBJ-01/02 and shared T-OBJ-15 first.
2. 🟢 **CONFIRMED** — Implement immutable core T-OBJ-03 through T-OBJ-08.
3. 🟢 **CONFIRMED** — Implement blob/stream/tag/ODB T-OBJ-09 through T-OBJ-13.
4. 🟢 **CONFIRMED** — Add integration helpers and documentation T-OBJ-14/16.
5. 🟢 **CONFIRMED** — Run matching tests alongside each task, then ownership/hash-format/platform characterization.

## Pending Gaps

- 🔴 **GAP** — Define complete SHA-256 support.
- 🔴 **GAP** — Define shared-wrapper/thread safety.
- 🔴 **GAP** — Prove all success/error ownership paths dynamically.
- 🔴 **GAP** — Define post-free behavior and borrowed-entry lifetime guarantees.

