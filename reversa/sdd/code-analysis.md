# Consolidated Code Analysis

> Archaeologist extraction for documentation level **Detailed**. Generated documents are in English; confidence labels reflect evidence strength.

## Architectural Baseline

The package exposes a public Dart barrel (`lib/git2dart.dart`), implements safe object-oriented wrappers in `lib/src/`, and delegates all C calls and native allocation details to `lib/src/bindings/`. Wrapper objects generally own a libgit2 pointer, attach a Dart `Finalizer`, expose an explicit `free()` method, and detach the finalizer after manual release.

## Feature 1: Repository Lifecycle

### Purpose and boundaries

`Repository` is the aggregate root for most operations. It initializes libgit2 before opening, creating, or cloning a repository and exposes owned views over configuration, index, object database, references, remotes, submodules, and worktrees. `Worktree` manages linked working trees. `RepositoryExtension.createCommitOnHead` is a convenience composition over the core primitives.

Primary evidence: `lib/src/repository.dart`, `lib/src/worktree.dart`, `lib/src/extensions/repository.dart`, `lib/src/bindings/repository.dart`, and their corresponding tests.

### Main control flows

1. **Initialize/open/clone**: call `git_libgit2_init`, delegate to the binding constructor, retain the returned `git_repository*`, and attach a finalizer.
2. **Set HEAD**: dispatch by runtime type. `Oid` creates a detached HEAD; `String` names a symbolic reference; any other value raises `ArgumentError`.
3. **Enumerate status**: allocate a native status list, iterate entries, prefer `head_to_index` when present, choose old/new path according to rename flags, decode all non-zero status bits, then release the list.
4. **Walk history**: create a `RevWalk`, apply sort flags, push the starting OID, and materialize commits.
5. **Reset**: resolve the supplied OID to a generic libgit2 object, pass reset and checkout options to the native boundary, then free the temporary object.
6. **Worktree lifecycle**: create/lookup/open, inspect lock and prune state, perform lock/unlock/prune, validate, and explicitly or finally free the native pointer.

### Confirmed rules

- 🟢 Every repository constructor initializes libgit2 before acquiring a repository pointer (`lib/src/repository.dart:65-203`).
- 🟢 Initialization flags are bitwise-combined; `bare = true` additionally forces `GitRepositoryInit.bare` (`lib/src/repository.dart:78-82`).
- 🟢 `setHead` accepts only `Oid` or `String`; another runtime type is rejected (`lib/src/repository.dart:300-313`).
- 🟢 Status decoding intentionally skips `GitStatus.current` because its numeric zero would otherwise be a false bitwise match (`lib/src/repository.dart:592-624`).
- 🟢 A hard reset may include checkout strategy, alternate checkout directory, and pathspec; a default reset accepts null OID to remove matching index entries (`lib/src/repository.dart:674-723`).
- 🟢 Native repository and worktree resources support both finalizer cleanup and explicit `free()`.

### Error model

Most native failures are translated by binding helpers into specific `LibGit2Error`-family exceptions. High-level validation uses Dart argument errors where the invalid state is knowable without calling libgit2. Negative tests cover missing repositories, invalid clone callbacks, invalid worktree names/paths, bad HEAD targets, invalid reset inputs, and bare-repository restrictions.

### Complexity

**High**. `Repository` is a broad façade with lifecycle, graph, status, attribute, reset, packing, and dependency access responsibilities. Native ownership and callback setup are the dominant risks.

## Feature 2: Git Objects and Object Database

### Purpose and boundaries

This feature models immutable Git objects and their storage: `Oid`, `Blob`, `Commit`, `Tree`, `TreeEntry`, `TreeBuilder`, `Tag`, `Odb`, `OdbObject`, `Signature`, `AnnotatedCommit`, `CommitGraph`, and `BlobWriteStream`. The wrappers translate typed Dart values to libgit2 objects and preserve explicit ownership at every native boundary.

Primary evidence: the corresponding files under `lib/src/`, their `lib/src/bindings/` peers, and type-specific tests under `test/`.

### Main control flows and algorithms

1. **Object lookup**: accept an `Oid` or prefix, call the type-specific lookup binding, attach a finalizer, and expose typed getters.
2. **Commit creation**: collect author, committer, message, tree, and parent pointers; native creation serializes and writes the commit, returning its OID. Buffer creation uses the same inputs without writing to ODB.
3. **Commit amendment**: preserve every null field from the existing commit, replace only supplied values, keep the original parent list, and optionally update a reference.
4. **Tree update**: translate each `TreeUpdate` into remove or upsert based on whether `oid` is null, convert file mode, then ask libgit2 to create the new immutable tree.
5. **Tree polymorphism**: indexed access accepts integer position, slash-containing path, or filename; conversion maps the target type to `Commit`, `Tree`, `Blob`, or `Tag` and rejects unsupported types.
6. **ODB validation**: writes and hashes accept only concrete writable Git object types; `any`, `invalid`, and delta pseudo-types are rejected before native execution.
7. **Streaming blob writes**: write bytes or UTF-8 text to a libgit2 stream, then commit the stream to obtain an OID; ownership may be detached when transferred.
8. **OID parsing**: validate SHA-1 or SHA-256 syntax, choose full lookup versus prefix lookup, and support unique-prefix shortening.

### Confirmed rules

- 🟢 A commit tree and every parent must belong to the supplied repository (`lib/src/commit.dart:65-99`, documented contract).
- 🟢 A root commit is represented by an empty parent list (`lib/src/commit.dart:70-98`).
- 🟢 Amendment replaces only non-null inputs and does not mutate the existing commit object (`lib/src/commit.dart:133-189`).
- 🟢 A `TreeUpdate` with null OID is removal; a non-null OID is upsert (`lib/src/tree.dart:63-89`).
- 🟢 ODB write/hash rejects abstract and delta object types (`lib/src/odb.dart:140-147`).
- 🟢 Tag and tree target conversion is closed over commit, tree, blob, and tag; unexpected native types become `ArgumentError` (`lib/src/tag.dart:92-133`, `lib/src/tree.dart:278-296`).
- 🟢 Object wrappers consistently pair finalizers with explicit manual release where ownership is held.

### Error model

Native lookup, creation, write, peel, and graph errors are surfaced as libgit2-specific exceptions. Local format or type violations become `ArgumentError`. Tests exercise invalid OIDs, unavailable prefixes, invalid object kinds, nonexistent parents, duplicate tag policy, invalid tag names, stream behavior, and manual cleanup.

### Complexity

**High**. The data model is broad, immutable object relationships are strongly typed, and correctness depends on repository ownership, parent ordering, object-kind dispatch, and native memory lifetime.

## Feature 3: Working Tree and Index

### Purpose and boundaries

This feature models the mutable projection around immutable Git objects: checkout, index staging and conflicts, diff calculation and application, patch/hunk/line inspection, stash operations, ignore and attribute evaluation, content filtering, and pathspec matching.

Primary evidence: `lib/src/index.dart`, `checkout.dart`, `diff.dart`, `patch.dart`, `stash.dart`, `ignore.dart`, `attr_options.dart`, `filter.dart`, `pathspec.dart`, their native binding peers, and associated tests.

### Main control flows and algorithms

1. **Index mutation**: dispatch `Index.add` by runtime type (`IndexEntry` versus path string); bulk operations convert Dart pathspecs into arena-scoped `git_strarray` values and call native callbacks.
2. **Index-to-tree**: ensure the index can be serialized, choose the owning repository or an explicitly supplied repository, recursively write tree objects, and return the root tree OID. Conflicted indexes are rejected by libgit2.
3. **Conflict model**: expose ancestor/ours/theirs entries as nullable sides, support add/remove/cleanup, and retain rename-conflict and resolve-undo metadata in NAME/REUC entries.
4. **Diff construction**: calculate differences between index, workdir, tree, tree pair, or index pair. Tree-to-tree rejects the meaningless case where both inputs are null.
5. **Diff application**: optionally check applicability without mutation, apply the full diff or one hunk to workdir/index/both, or produce an in-memory index by applying to a tree.
6. **Similarity detection**: initialize native find options, bitwise-combine flags, assign rename/copy/rewrite thresholds and limit, execute in-place detection, and free the options buffer.
7. **Patch projection**: materialize patch statistics, hunks, and per-line origin/coordinates/content from a diff entry or buffer/blob pair.
8. **Pathspec matching**: compile immutable patterns, combine match flags, and match against workdir, index, tree, diff, or a single path; optionally retain failures.
9. **Stash lifecycle**: create a stash snapshot, apply it with checkout flags and optional path restrictions, then drop or pop by index.

### Confirmed rules

- 🟢 `Index.add` accepts either an `IndexEntry` or a path string; another runtime value fails at the cast boundary (`lib/src/index.dart:263-271`).
- 🟢 `addFromBuffer` forces content into the index without consulting ignore rules and moves prior conflict data to REUC (`lib/src/index.dart:274-296`).
- 🟢 `Index.writeTree` cannot serialize unresolved conflicts and chooses `writeTreeTo` only when an explicit repository is supplied (`lib/src/index.dart:391-413`).
- 🟢 Diffing two null trees is rejected locally (`lib/src/diff.dart:198-218`).
- 🟢 `Diff.applies` uses the same native application engine with check-only mode (`lib/src/diff.dart:362-382`).
- 🟢 Similarity thresholds default to rename 50, copy 50, rename-from-rewrite 50, break-rewrite 60, and limit 200 (`lib/src/diff.dart:439-459`).
- 🟢 Bulk index path arrays are arena-scoped, so temporary native strings are released when the call completes (`lib/src/index.dart:311-365`, `436-454`).

### Error model

The high-level layer prevents structurally meaningless diff input and delegates filesystem, index-conflict, invalid-pathspec, bad stash index, bare repository, and patch failures to native exception translation. The test surface includes positive and negative cases for every principal constructor and mutator.

### Complexity

**High**. This is the package's densest mutable state boundary: index stages, three-way conflict sides, working-directory I/O, callbacks, patch coordinates, and multiple application targets interact.

## Feature 4: References and Remotes

### Purpose and boundaries

This feature owns mutable names over Git objects and all network-facing synchronization: direct and symbolic references, branches, reflogs, refspec transformation, remote discovery/fetch/push/prune, authentication, transfer callbacks, and certificate inspection.

Primary evidence: `lib/src/reference.dart`, `branch.dart`, `reflog.dart`, `refspec.dart`, `remote.dart`, `callbacks.dart`, `credentials.dart`, `certificate.dart`, their binding peers, and corresponding tests.

### Main control flows and algorithms

1. **Reference creation**: dispatch by target type. An `Oid` creates a direct reference; a `String` creates a symbolic reference. Unsupported runtime types are rejected locally.
2. **Compare-and-set reference update**: `createMatching` requires target and current target to be the same representation (both OIDs or both strings), then delegates an atomic expected-value check to libgit2.
3. **Reference resolution and peeling**: symbolic targets resolve recursively to a direct OID; peel maps the resulting native object to `Commit`, `Tree`, `Blob`, or `Tag`.
4. **Branch tracking**: branch wrappers expose HEAD/checked-out state, upstream reference, upstream remote, and merge configuration; clearing upstream is represented by null.
5. **Remote advertisement**: connect in fetch direction, list advertised references, disconnect, and map native heads to immutable `RemoteReference` records.
6. **Fetch**: combine refspecs, pruning, proxy, authentication, certificate, progress, and update callbacks; download objects and update tips; return transfer counters from remote statistics.
7. **Push**: apply push refspecs and callbacks through the same proxy/authentication boundary; per-reference remote failures surface through `pushUpdateReference`.
8. **Prune**: create arena-scoped native callbacks, plug requested Dart callbacks into the struct, prune stale tracking refs, then release temporary allocations.
9. **Certificate projection**: discriminate none/X.509/SSH/strarray/unknown; expose hostkey hashes and raw bytes only when the corresponding native availability bits are set.

### Confirmed rules

- 🟢 A reference is either direct (`Oid`) or symbolic (`String`); create, matching-create, and set-target enforce this distinction (`lib/src/reference.dart:47-116`, `187-210`).
- 🟢 Compare-and-set updates require current and desired targets to share the same representation (`lib/src/reference.dart:85-116`).
- 🟢 A branch upstream can be removed by passing null, but setting one requires its tracking reference to already exist (`lib/src/branch.dart:207-218`).
- 🟢 Remote listing explicitly connects in fetch direction and disconnects after reading advertised refs (`lib/src/remote.dart:260-283`).
- 🟢 Fetch defaults to configured refspecs, unspecified prune policy, and libgit2 certificate behavior unless callbacks override it (`lib/src/remote.dart:285-322`, `callbacks.dart:43-59`).
- 🟢 Certificate objects are borrowed and valid only during the callback (`lib/src/certificate.dart:50-53`).
- 🟢 Missing SSH hashes or raw key bytes are represented as null rather than fabricated values (`lib/src/certificate.dart:104-167`).

### Error model and security boundary

Native reference collisions, invalid names, stale expected values, missing upstreams, ambiguous remote refspec matches, network failures, authentication failures, certificate rejection, and push rejection are translated from libgit2. Credentials are typed by mechanism: plaintext user/password, filesystem SSH keypair, SSH agent, or in-memory SSH material. A user certificate callback receives both native validity and host identity and returns the final acceptance decision.

### Complexity

**High**. This module combines mutable reference semantics, compare-and-set behavior, network state, credentials, callback lifetimes, remote progress, and certificate trust decisions.

## Feature 5: History and Integration Operations

### Purpose and boundaries

This feature interprets history and performs graph-changing or history-derived operations: revision parsing and walking, merge analysis/execution, rebase sequencing, blame, notes, mailmap identity normalization, commit message helpers, pack construction, and submodule lifecycle.

Primary evidence: `lib/src/revparse.dart`, `revwalk.dart`, `merge.dart`, `rebase.dart`, `blame.dart`, `note.dart`, `mailmap.dart`, `message.dart`, `packbuilder.dart`, `submodule.dart`, their binding peers, and corresponding tests.

### Main control flows and algorithms

1. **Revision parsing**: parse a single spec or extended/range spec, inspect the native object kind, and return a typed commit/tree/blob/tag or a `RevSpec` pair with range flags.
2. **Revision walking**: bitwise-combine sort modes, push roots/references/globs/ranges, hide commits or predicates and their ancestors, materialize commits with an optional limit, and automatically reset the walker after traversal.
3. **Merge analysis**: resolve the destination reference and annotated incoming head, decode an analysis bitmask plus merge preference, then let the caller select up-to-date, fast-forward, unborn, or normal merge behavior.
4. **Merge execution**: apply the incoming annotated commit to workdir/index and enter repository merge state; conflicts are represented in the index and state must later be cleaned explicitly. Alternative APIs merge commits/trees into an in-memory index or merge file contents directly.
5. **Rebase state machine**: initialize or reopen a rebase, inspect operations, call `next()` to apply the next patch, resolve index/workdir conflicts externally, commit the current operation, then finish or abort.
6. **Blame projection**: create file blame using commit/line bounds and flags or re-blame an in-memory buffer; expose final/original committers, OIDs, paths, and line spans per hunk.
7. **Mailmap resolution**: load empty/buffer/repository mappings, resolve name/email or an owned signature, and validate that replacement email is not blank before adding a mapping.
8. **Pack building**: add individual, recursive, commit, tree, or revwalk object sets; select thread count; write a pack and expose total/written object counts and generated name.
9. **Submodule lifecycle**: setup metadata, clone using remote callbacks, finalize registration, optionally initialize/update, open the nested repository, decode status/location bitmasks, and synchronize configurable URL/branch/ignore/update/recurse policies.

### Confirmed rules

- 🟢 Revision walking requires at least one pushed root, treats range `A..B` as hide A plus push B, and resets after a completed walk (`lib/src/revwalk.dart:55-72`, `91-145`, `197-204`).
- 🟢 Merge analysis decodes every matching `GitMergeAnalysis` flag plus one `GitMergePreference` (`lib/src/merge.dart:99-120`).
- 🟢 A workdir merge enters repository merge state; callers must use `Repository.stateCleanup()` after completion or abort (`lib/src/merge.dart:122-158`).
- 🟢 `Rebase.next()` applies non-exec patches to index/workdir, and conflicts must be resolved before `commit()` (`lib/src/rebase.dart:107-143`).
- 🟢 `Rebase.finish()` advances HEAD to the final commit, while `abort()` restores repository and workdir state (`lib/src/rebase.dart:145-158`).
- 🟢 Mailmap replacement email must contain non-whitespace text (`lib/src/mailmap.dart:155-176`).
- 🟢 Submodule add is a three-stage setup, clone, finalize transaction (`lib/src/submodule.dart:36-55`).
- 🟢 `workdirOid` is not a full dirty-state check; callers must inspect `status()` for that (`lib/src/submodule.dart:221-230`).

### Error and state model

Graph lookup, invalid revision specs, missing merge bases, conflicting merges/rebases, invalid notes, unavailable blame lines, pack write failures, and submodule network/config failures are surfaced through translated libgit2 exceptions. Some operations intentionally return an in-memory `Index` so the caller can inspect conflicts without mutating the workdir. Merge and rebase are explicit multi-step state machines rather than single atomic actions.

### Complexity

**High**. These APIs combine graph traversal, multi-parent history, mutable repository states, conflict-bearing indexes, external subrepositories, and native callback/resource lifetimes.

## Feature 6: Native Runtime and Platform Boundary

### Purpose and boundaries

This feature is the safety and portability layer between idiomatic Dart and generated libgit2 declarations from `git2dart_binaries`. It initializes the native runtime, configures platform support, maps C enums and bitmasks to Dart types, allocates temporary native memory, translates negative libgit2 result codes, and defines explicit/finalized ownership conventions.

Primary evidence: `lib/src/libgit2.dart`, `platform_specific.dart`, `error.dart`, `git_types.dart`, `extensions.dart`, `helpers/error_helper.dart`, all 46 files under `lib/src/bindings/`, and `git2dart_binaries` imports.

### Main control flows and algorithms

1. **Platform initialization**: on Android, force libgit2 loading, initialize the companion package's SSL certificate helper, and configure the resulting CA file; on iOS, eagerly access libgit2 version to ensure statically linked symbols are available. Other platforms perform no special async setup.
2. **Native invocation**: allocate output pointers and UTF-8 inputs, invoke a generated libgit2 function, pass its result to `checkErrorAndThrow`, convert the output into a Dart value/wrapper, and release temporary allocations.
3. **Error translation**: every negative result code reads `git_error_last()` and throws `LibGit2Error`; non-negative status/result values remain available to the caller for operation-specific interpretation.
4. **String marshalling**: encode Dart strings as UTF-8, allocate `length + 1` bytes in an arena, copy units, and append a zero terminator. An explicit allocation variant exists for lifetimes that cannot be arena-scoped.
5. **Owned pointer lifecycle**: high-level wrappers attach a type-specific `Finalizer`; manual `free()` delegates to the matching native destructor and detaches the finalizer to prevent double release. Borrowed views are documented where their lifetime is externally bounded.
6. **Enum and flag translation**: `git_types.dart` assigns libgit2-compatible integer constants, provides `fromValue` dispatch, and represents combinable flags as `Set<Enum>` folded with bitwise OR.
7. **Global libgit2 options**: static getters/setters initialize libgit2, marshal values, and control cache limits, memory mapping, config paths, templates, SSL locations, user agent, strict validation, pack behavior, supported extensions, and owner validation.
8. **Buffer disposal**: getters returning `git_buf` convert exactly `size` bytes and call `git_buf_dispose`; arena or `calloc` output pointers are released after conversion.
9. **Native callback bridging**: callback structs are initialized at the correct version, optional Dart closures are registered in bridge slots, and native callbacks project pointer data into typed Dart objects during the synchronous call lifetime.

### Confirmed rules

- 🟢 `git2dart_binaries` supplies generated declarations, native library loading, and Android SSL support; this repository does not regenerate those declarations (`pubspec.yaml`, imports across `lib/src/bindings/`).
- 🟢 A negative libgit2 return code always becomes `LibGit2Error(git_error_last())` through the shared helper (`lib/src/helpers/error_helper.dart:5-9`).
- 🟢 Arena-backed UTF-8 strings are null-terminated and scoped to the native call (`lib/src/extensions.dart:8-25`).
- 🟢 Android initialization configures a concrete certificate file; iOS initialization eagerly resolves statically linked symbols (`lib/src/platform_specific.dart:11-34`).
- 🟢 SSL location configuration rejects the case where both file and directory are null (`lib/src/libgit2.dart:265-283`).
- 🟢 Pack maximum object size rejects negative input before the native call (`lib/src/libgit2.dart:452-476`).
- 🟢 Strict object creation, strict symbolic refs, strict hash verification, and unsaved-index safety are enabled by libgit2 defaults, but the public API exposes explicit disabling methods (`lib/src/libgit2.dart:309-430`).
- 🟢 `CachedMemory` reports current and allowed cache bytes; temporary output integers are released after reading (`lib/src/libgit2.dart:203-221`).
- 🟢 Owner validation is enabled/disabled through a global integer option (`lib/src/libgit2.dart:548-569`).

### Safety and concurrency observations

- 🟢 **CONFIRMED**: most short-lived native allocations use `Arena`, providing deterministic release at callback exit.
- 🟢 **CONFIRMED**: persistent libgit2 objects use matching finalizers and explicit free methods.
- 🟡 **INFERRED**: because libgit2 settings and callback bridge fields are process-global/static, callers should serialize conflicting global configuration changes and avoid overlapping remote operations that install different callback closures unless the binding layer guarantees isolation.
- 🔴 **GAP**: this static extraction did not run a concurrency stress test or independently audit every allocation/free pair across all 46 binding files.

### Complexity

**Very high**. Correctness depends on ABI compatibility with `git2dart_binaries`, ownership transfer, native callback lifetime, error-code semantics, process-global configuration, and platform-specific dynamic/static loading.

## Extraction Progress

| Feature | Status | Entities catalogued |
| --- | --- | ---: |
| Repository lifecycle | Complete | 4 |
| Git objects and object database | Complete | 12 |
| Working tree and index | Complete | 11 |
| References and remotes | Complete | 13 |
| History and integration operations | Complete | 10 |
| Native runtime and platform boundary | Complete | 5 |

## Archaeologist Summary

- Modules analyzed: **6/6**.
- Principal entities catalogued: **55** across the six semantic feature groups.
- Dominant algorithms: native resource ownership, Git object serialization, index conflict projection, diff application, reference compare-and-set, remote callback bridging, graph traversal, merge/rebase state machines, submodule transactions, enum/bitmask translation.
- 🔴 Remaining validation gaps: no dynamic trace, live remote interoperability run, platform matrix execution, ABI audit, concurrency stress test, or fresh full test run was performed during extraction.
