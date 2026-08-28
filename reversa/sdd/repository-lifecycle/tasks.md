# Repository Lifecycle — Reimplementation Tasks

> 🟢 **CONFIRMED** — This task sequence reconstructs the repository-lifecycle behavior documented in `requirements.md` and `design.md`. Each task cites the legacy source or test evidence from which its completion contract was derived.

## Preconditions

- [ ] **P-01 — Native dependency available.** 🟢 **CONFIRMED**
  - Evidence: `pubspec.yaml`, `reversa/sdd/adrs/001-separate-native-binaries-and-generated-declarations.md`.
  - Ready when: a declaration-compatible `git2dart_binaries` package and platform libgit2 artifacts are resolvable on every target platform.
- [ ] **P-02 — Shared FFI infrastructure available.** 🟢 **CONFIRMED**
  - Evidence: `lib/src/extensions.dart`, `lib/src/helpers/error_helper.dart`, `reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md`.
  - Ready when: arena allocation, UTF-8 conversion, native error translation, enum/flag conversion, and finalizer support can be reused by repository bindings.
- [ ] **P-03 — Collaborating typed components available.** 🟢 **CONFIRMED**
  - Evidence: `lib/src/repository.dart:451-566`.
  - Ready when: `Config`, `Index`, `Odb`, `Reference`, `Branch`, `Tag`, `Stash`, `Remote`, `Submodule`, `Commit`, `Signature`, `AnnotatedCommit`, and `PackBuilder` contracts can be referenced.
- [ ] **P-04 — Filesystem test fixture strategy available.** 🟢 **CONFIRMED**
  - Evidence: `test/helpers/util.dart`, `test/repository_test.dart`, `test/worktree_test.dart`.
  - Ready when: tests can create isolated temporary repositories without mutating developer repositories.
- [ ] **P-05 — No database migration required.** 🟢 **CONFIRMED**
  - Evidence: `reversa/sdd/inventory.md`, `reversa/sdd/architecture.md`.
  - Ready when: implementation planning treats Git storage and filesystem fixtures as native domain state rather than an application relational schema.

## Implementation Tasks

- [ ] **T-RL-01 — Establish the public wrapper and adapter boundary.**
  - Legacy origin: `lib/git2dart.dart`, `lib/src/repository.dart`, `lib/src/bindings/repository.dart`.
  - Work: expose `Repository`, `RepositoryCallback`, `Identity`, and `Worktree` through the typed package surface while keeping binding modules and raw pointers internal.
  - Done when: consumer code can import the typed API; generated declarations and binding modules are not exported through the public barrel.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-02 — Implement repository pointer ownership.**
  - Legacy origin: `lib/src/repository.dart:27-31`, `lib/src/repository.dart:438-445`, `lib/src/repository.dart:945-947`.
  - Work: store one owned native repository handle, attach a matching finalizer at wrapper construction, expose explicit `free()`, and detach the finalizer after manual release.
  - Done when: explicit release invokes the native repository destructor exactly once in the supported lifecycle, and an unreleased wrapper has fallback cleanup.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-03 — Implement basic and extended repository initialization.**
  - Legacy origin: `lib/src/repository.dart:65-108`, `lib/src/bindings/repository.dart`.
  - Work: initialize libgit2, bitwise-fold typed initialization flags, force the bare flag when `bare` is true, marshal optional mode/workdir/description/template/initial-head/origin values, and return an owned wrapper.
  - Done when: basic and extended initialization produce valid bare and non-bare repositories and invalid native inputs fail through the shared error model.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-04 — Implement repository open and discovery modes.**
  - Legacy origin: `lib/src/repository.dart:117-155`, `lib/src/repository.dart:220-222`, `test/repository_test.dart:37-74`, `test/repository_test.dart:119-132`.
  - Work: implement standard open, extended-search open, bare open, and discovery with optional ceiling directories.
  - Done when: each valid acquisition returns the expected repository/path and missing repositories produce translated failures without partial wrappers.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-05 — Implement clone acquisition and option composition.**
  - Legacy origin: `lib/src/repository.dart:181-203`, `lib/src/bindings/repository.dart`, `reversa/sdd/flowcharts/repository-lifecycle-clone.md`.
  - Work: compose clone, repository, remote, checkout, credential, certificate, progress, and transfer callbacks; marshal URL/local path; return the acquired owned repository.
  - Done when: valid local/controlled clone scenarios return a usable repository, callback options reach the native operation, and transport/callback failure unwinds temporary state and throws.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-06 — Implement repository metadata projection.**
  - Legacy origin: `lib/src/repository.dart:235-281`, `lib/src/repository.dart:333-414`.
  - Work: project path, common directory, namespace, bare/empty/detached/unborn/shallow/worktree state, object format, message, workdir, and active operation state to typed Dart values.
  - Done when: each property matches native state, enum decoding is exhaustive for supported values, and documented absence uses the expected empty/nullable representation.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-07 — Implement namespace, identity, message, and workdir mutation.**
  - Legacy origin: `lib/src/repository.dart:248-260`, `lib/src/repository.dart:343-351`, `lib/src/repository.dart:393-396`, `lib/src/repository.dart:414-435`.
  - Work: set/unset namespace, set/read repository identity, remove repository message, and set workdir with optional gitlink update.
  - Done when: valid mutations are observable on subsequent reads, null namespace removes it, and invalid paths/native state throw translated errors.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-08 — Implement HEAD selection and detachment.**
  - Legacy origin: `lib/src/repository.dart:279-333`, `test/repository_test.dart:165-246`.
  - Work: expose HEAD, dispatch `setHead` between `Oid` and `String`, support current-target detachment and annotated-commit detachment, and expose unborn/detached states.
  - Done when: symbolic, detached, and unborn flows match the requirements; unsupported target type throws `ArgumentError`; missing targets throw the native error type.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-09 — Implement repository subsystem accessors and replacement.**
  - Legacy origin: `lib/src/repository.dart:451-566`, `test/repository_test.dart:29-102`.
  - Work: acquire live/snapshot config, index, ODB, HEAD, linked-worktree HEAD, default signature, and list views for references, tags, branches, stashes, remotes, submodules, and worktrees; implement config/index/ODB replacement.
  - Done when: each accessor returns its typed wrapper/list with correct native ownership and replacement errors are translated.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-10 — Implement repository history traversal.**
  - Legacy origin: `lib/src/repository.dart:572-582`, `test/repository_test.dart:103-118`.
  - Work: construct a revision walker, configure sorting, push the supplied OID, materialize commits, and respect the revision-walk cleanup/reset contract.
  - Done when: history begins at the requested OID, ordering follows the supplied flags, and invalid roots fail explicitly.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-11 — Implement repository and file status decoding.**
  - Legacy origin: `lib/src/repository.dart:584-654`, `lib/src/bindings/status.dart`, `test/repository_test.dart:255-337`.
  - Work: acquire/free a native status list, choose head-to-index when available, select renamed/new versus old path, decode every non-zero status bit, and map native current/zero for one path to an empty set.
  - Done when: changed, renamed, and current paths produce the expected map/set; the native list is released; bare/invalid-path cases throw.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-12 — Implement repository operation-state cleanup.**
  - Legacy origin: `lib/src/repository.dart:393-409`, `test/repository_test.dart:302-324`, `reversa/sdd/state-machines.md`.
  - Work: decode `GitRepositoryState` and invoke native cleanup for supported active operation states.
  - Done when: successful cleanup returns the repository to `none` and native cleanup failure is visible to the caller.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-13 — Implement reset and default-reset flows.**
  - Legacy origin: `lib/src/repository.dart:674-723`, `lib/src/bindings/reset.dart`.
  - Work: resolve a reset OID to a temporary generic object, marshal reset/checkout/pathspec options, execute reset, release the object, and support nullable target for default reset.
  - Done when: typed reset modes mutate the intended projection, default reset supports null target, invalid targets fail, and temporary native objects are released on every supported path.
  - Confidence: 🟢 **CONFIRMED** for behavior; 🔴 **GAP** for a complete dynamic error-path allocation audit.

- [ ] **T-RL-14 — Implement attribute operations.**
  - Legacy origin: `lib/src/repository.dart:730-807`, `lib/src/bindings/attr.dart`, `test/repository_test.dart:349-439`.
  - Work: implement single/multiple/extended lookup, iteration, macro registration, and cache flush with typed flags and optional commit context.
  - Done when: attribute values, missing values, iteration entries, helper extensions, macros, and error cases match the legacy tests.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-15 — Implement graph, hashing, describe, and pack helpers.**
  - Legacy origin: `lib/src/repository.dart:359-373`, `lib/src/repository.dart:814-940`, `lib/src/bindings/graph.dart`, `lib/src/bindings/describe.dart`.
  - Work: return ahead/behind counts, hash a file in repository context, describe reachable names with formatting options, and build/write packs with optional object selection and thread count.
  - Done when: results match native behavior, invalid inputs throw, and describe/pack temporary or persistent resources follow their ownership contracts.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-16 — Implement worktree pointer ownership and acquisition.**
  - Legacy origin: `lib/src/worktree.dart:25-67`, `lib/src/worktree.dart:132-149`, `lib/src/bindings/worktree.dart`.
  - Work: create, lookup, and open linked worktrees; list their names; store the owned pointer; attach and detach the finalizer around explicit release.
  - Done when: valid create/lookup/open/list flows work, invalid names/paths fail, and owned handles have deterministic/fallback cleanup.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-17 — Implement worktree administration and validation.**
  - Legacy origin: `lib/src/worktree.dart:70-129`, `test/worktree_test.dart:101-178`, `test/worktree_test.dart:203-238`.
  - Work: expose name/path/lock/prune/valid state, implement lock/unlock/prune/validate, resolve linked HEAD state via repository APIs, and recover the associated repository.
  - Done when: state transitions and negative paths match worktree tests, and returned repository/reference wrappers have correct ownership.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-18 — Implement the commit-on-HEAD convenience extension.**
  - Legacy origin: `lib/src/extensions/repository.dart:6-37`.
  - Work: resolve the current HEAD commit, clear the index, stage each supplied file, write a tree, and create a commit that updates `HEAD` with one parent.
  - Done when: the new commit contains the requested files/message/signatures, points to the previous HEAD as its parent, and failure in staging/tree/commit creation aborts with the underlying error.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-19 — Apply centralized error and validation policy.**
  - Legacy origin: `lib/src/helpers/error_helper.dart`, `lib/src/repository.dart:300-313`, `reversa/sdd/adrs/004-centralize-native-error-translation.md`.
  - Work: route every negative native result through immediate native-error translation and use local argument validation only where failure is knowable before the call.
  - Done when: no native failure is returned as false success/null unless null is an explicit contract, and local invalid HEAD representation is distinguishable from native lookup failure.
  - Confidence: 🟢 **CONFIRMED**.

- [ ] **T-RL-20 — Document public ownership and destructive-operation semantics.**
  - Legacy origin: `lib/src/repository.dart`, `lib/src/worktree.dart`, `reversa/sdd/permissions.md`.
  - Work: document public symbols, explicit release, borrowed/owned child objects, force/reset/workdir consequences, and the embedding process's filesystem authority.
  - Done when: every public repository/worktree symbol has `///` documentation and destructive operations do not imply hidden safety guarantees.
  - Confidence: 🟢 **CONFIRMED**.

## Test Tasks

- [ ] **TT-RL-01 — Test initialization and open happy paths.**
  - Legacy origin: `test/repository_test.dart:37-64`.
  - Done when: basic, extended, and bare acquisition return repositories with expected metadata.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-02 — Test acquisition failures.**
  - Legacy origin: `test/repository_test.dart:65-74`, `test/repository_test.dart:119-132`.
  - Done when: missing repository discovery/open throws the expected translated native error and returns no wrapper.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-03 — Test HEAD states and invalid target types.**
  - Legacy origin: `test/repository_test.dart:165-246`.
  - Done when: symbolic, detached, unborn, annotated-detach, unknown target, and unsupported runtime type cases are covered.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-04 — Test status projection and cleanup.**
  - Legacy origin: `test/repository_test.dart:255-337`.
  - Done when: repository/file status, callbacks, current-zero handling, bare failure, and operation-state cleanup success/failure are covered.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-05 — Test subsystem access and replacement.**
  - Legacy origin: `test/repository_test.dart:29-102`.
  - Done when: config/snapshot/index/ODB getters and valid/invalid replacements are covered.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-06 — Test history, graph, attributes, hashing, describe, reset, and pack helpers.**
  - Legacy origin: `test/repository_test.dart:103-118`, `test/repository_test.dart:248-254`, `test/repository_test.dart:349-457`, and corresponding feature tests.
  - Done when: each helper has at least one positive and one invalid/error scenario where the public API permits failure.
  - Confidence: 🟢 **CONFIRMED** for existing principal cases; 🟡 **INFERRED** for full negative coverage of every helper.
- [ ] **TT-RL-07 — Test linked-worktree lifecycle.**
  - Legacy origin: `test/worktree_test.dart:32-238`.
  - Done when: create/reference create, lookup/open/list, linked HEAD, invalid inputs, lock/unlock, prune flags, associated repository, validate, release, and equality are covered.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-08 — Test explicit resource release.**
  - Legacy origin: `test/repository_test.dart:459-467`, `test/worktree_test.dart:185-202`.
  - Done when: repository and worktree manual release can be exercised without a second finalizer release in the supported lifecycle.
  - Confidence: 🟢 **CONFIRMED**.
- [ ] **TT-RL-09 — Test commit-on-HEAD composition.**
  - Legacy origin: `lib/src/extensions/repository.dart:6-37`; direct dedicated test evidence was not identified in the inspected repository test path.
  - Done when: staging, parent selection, tree creation, HEAD update, and an intermediate failure scenario are independently verified.
  - Confidence: 🔴 **GAP** for identified dedicated legacy test coverage.
- [ ] **TT-RL-10 — Add ownership failure-path tests.**
  - Legacy origin: `reversa/sdd/domain.md`, `reversa/sdd/architecture.md`.
  - Done when: instrumentation or a native test harness demonstrates no leak/double release across representative constructor, status, reset, describe, and worktree errors.
  - Confidence: 🔴 **GAP**.
- [ ] **TT-RL-11 — Add concurrency characterization tests.**
  - Legacy origin: `reversa/sdd/domain.md`, `reversa/sdd/repository-lifecycle/requirements.md`.
  - Done when: shared-wrapper and process-global behavior is either proven and documented or explicitly rejected with enforced constraints.
  - Confidence: 🔴 **GAP**.
- [ ] **TT-RL-12 — Run the cross-platform quality gate.**
  - Legacy origin: `.github/workflows/publish.yml`, `AGENTS.md`.
  - Done when: formatting, zero-warning analysis, and repository/worktree tests pass on the declared desktop and mobile targets; live-network evidence is reported separately.
  - Confidence: 🟢 **CONFIRMED** for the declared gate; 🔴 **GAP** until a fresh run is captured.

## Data Migration Tasks

- 🟢 **CONFIRMED** — No application database or schema migration task applies to this unit.
- 🟡 **INFERRED** — Compatibility testing against existing Git repository formats replaces traditional data migration testing for a reimplementation.

## Suggested Execution Order

1. 🟢 **CONFIRMED** — Complete P-01 through P-04, then T-RL-01 and T-RL-19 so every later operation shares the same API and failure boundary.
2. 🟢 **CONFIRMED** — Implement ownership first with T-RL-02, then repository acquisition with T-RL-03 through T-RL-05.
3. 🟢 **CONFIRMED** — Implement metadata, mutation, HEAD, and child access with T-RL-06 through T-RL-09.
4. 🟢 **CONFIRMED** — Implement operational behavior with T-RL-10 through T-RL-15 after collaborating object/index/reference types are available.
5. 🟢 **CONFIRMED** — Implement linked worktrees with T-RL-16 and T-RL-17 after repository acquisition and ownership are stable.
6. 🟢 **CONFIRMED** — Implement the convenience extension and public documentation with T-RL-18 and T-RL-20.
7. 🟢 **CONFIRMED** — Execute TT-RL-01 through TT-RL-09 alongside their implementation tasks, then run ownership, concurrency, and full-platform characterization tasks.

## Dependency Blocks

| Blocked task | Blocking dependency | Confidence |
| --- | --- | --- |
| T-RL-05 | References/remotes callbacks and native clone option adapters | 🟢 CONFIRMED |
| T-RL-08 | `Oid`, `Reference`, and `AnnotatedCommit` wrappers | 🟢 CONFIRMED |
| T-RL-09 | Config, Index, ODB, refs/remotes, submodule, and signature wrappers | 🟢 CONFIRMED |
| T-RL-10 | Revision-walk and commit wrappers | 🟢 CONFIRMED |
| T-RL-13 | Object lookup, reset bindings, and checkout/pathspec types | 🟢 CONFIRMED |
| T-RL-15 | Graph, object, describe, and packbuilder components | 🟢 CONFIRMED |
| T-RL-18 | Index, tree, commit, signature, and HEAD/reference behavior | 🟢 CONFIRMED |

## Pending Gaps

- [ ] **G-RL-01 — Define concurrency guarantees.** 🔴 **GAP**
  - Decision required: whether repository wrappers may be shared across isolates/threads and how process-global libgit2 state is serialized.
- [ ] **G-RL-02 — Define post-release behavior.** 🔴 **GAP**
  - Decision required: whether repeated `free()` and later method calls must be guarded, idempotent, or explicitly unsupported.
- [ ] **G-RL-03 — Establish object-format support.** 🔴 **GAP**
  - Decision required: which SHA-1/SHA-256 repository operations are release-supported end to end.
- [ ] **G-RL-04 — Establish live clone release evidence.** 🔴 **GAP**
  - Decision required: which HTTPS/SSH credential/trust combinations must pass on each supported platform before release.
- [ ] **G-RL-05 — Complete the allocation/free audit.** 🔴 **GAP**
  - Decision required: acceptable dynamic tooling and target platforms for native leak/double-release verification.

