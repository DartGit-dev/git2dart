# Repository Lifecycle Requirements

> 🟢 **CONFIRMED** — This specification defines the observable contract for creating, discovering, opening, cloning, inspecting, mutating, and releasing repositories and linked worktrees. It is derived from the current Dart wrappers, native adapters, tests, and extracted architecture.

## Overview

🟢 **CONFIRMED** — Repository Lifecycle provides the aggregate root through which callers acquire a libgit2 repository handle and reach configuration, index, object database, references, remotes, submodules, worktrees, history, status, attributes, and repository-state operations.

🟢 **CONFIRMED** — The unit also manages linked-worktree administration and the convenience flow that stages files and creates a commit on the current HEAD.

## Scope

### In scope

- 🟢 **CONFIRMED** — Repository initialization, discovery, open, extended open, bare open, and clone.
- 🟢 **CONFIRMED** — Repository metadata, namespace, identity, HEAD, workdir, operation state, and shallow/worktree/object-format inspection.
- 🟢 **CONFIRMED** — Access to repository-associated configuration, index, ODB, references, tags, branches, stashes, remotes, submodules, worktrees, and signatures.
- 🟢 **CONFIRMED** — Status, history walking, graph distance, reset, attributes, describe, hashing, and pack generation exposed by `Repository`.
- 🟢 **CONFIRMED** — Linked-worktree create, lookup, open, list, lock, unlock, prune, validate, repository recovery, and release.
- 🟢 **CONFIRMED** — Explicit native-resource release and finalizer-backed fallback cleanup.

### Out of scope

- 🟢 **CONFIRMED** — Object serialization rules belong to `git-objects-and-object-database`.
- 🟢 **CONFIRMED** — Detailed index, checkout, diff, patch, and stash behavior belongs to `working-tree-and-index`.
- 🟢 **CONFIRMED** — Authentication, certificate validation, refspecs, fetch, and push belong to `references-and-remotes`.
- 🟢 **CONFIRMED** — Merge, rebase, blame, notes, packs as standalone objects, and submodule internals belong to `history-and-integration-operations`.

## Responsibilities

- 🟢 **CONFIRMED** — Initialize libgit2 before acquiring a repository pointer through any repository constructor.
- 🟢 **CONFIRMED** — Preserve the caller-selected repository initialization/open/clone options while delegating native acquisition to binding adapters.
- 🟢 **CONFIRMED** — Represent one owned `git_repository*` as a typed Dart `Repository` with deterministic and fallback cleanup paths.
- 🟢 **CONFIRMED** — Expose repository state without leaking raw C calls through the public package facade.
- 🟢 **CONFIRMED** — Validate locally decidable polymorphic inputs, including `setHead`, before or at the wrapper boundary.
- 🟢 **CONFIRMED** — Translate native acquisition, filesystem, state, status, reset, attribute, graph, and worktree failures through the package error model.
- 🟢 **CONFIRMED** — Keep linked-worktree handles independently owned and releasable.

## Business Rules

| ID | Rule | Confidence | Evidence |
| --- | --- | --- | --- |
| BR-RL-01 | Every repository constructor initializes libgit2 before acquiring a repository handle. | 🟢 CONFIRMED | `lib/src/repository.dart:65-203` |
| BR-RL-02 | `bare = true` adds the bare initialization flag even when other initialization flags are supplied. | 🟢 CONFIRMED | `lib/src/repository.dart:78-82` |
| BR-RL-03 | `setHead` accepts an `Oid` for detached HEAD or a `String` for symbolic HEAD; another runtime type is rejected. | 🟢 CONFIRMED | `lib/src/repository.dart:300-313` |
| BR-RL-04 | A missing namespace is represented as an empty string; passing null to `setNamespace` removes the namespace. | 🟢 CONFIRMED | `lib/src/repository.dart:248-260`, `test/repository_test.dart:134-145` |
| BR-RL-05 | Status decoding omits the zero-valued `GitStatus.current` flag and collects every applicable non-zero status bit. | 🟢 CONFIRMED | `lib/src/repository.dart:592-624` |
| BR-RL-06 | Repository status that depends on a working directory fails for a bare repository. | 🟢 CONFIRMED | `test/repository_test.dart:296-301` |
| BR-RL-07 | A hard/mixed/soft reset resolves its target OID to a temporary native object and releases that object after reset. | 🟢 CONFIRMED | `lib/src/repository.dart:674-696` |
| BR-RL-08 | Default reset accepts a null OID and applies only to the supplied pathspec. | 🟢 CONFIRMED | `lib/src/repository.dart:708-723` |
| BR-RL-09 | A repository operation such as merge or rebase remains observable through `state` until the relevant finish/abort or `stateCleanup` transition. | 🟢 CONFIRMED | `lib/src/repository.dart:393-409`, `state-machines.md` |
| BR-RL-10 | A worktree may be pruned only when libgit2 considers it prunable under the selected flags. | 🟢 CONFIRMED | `lib/src/worktree.dart:92-111` |
| BR-RL-11 | A worktree lock prevents administrative mutation until it is unlocked. | 🟢 CONFIRMED | `lib/src/worktree.dart:75-90`, `test/worktree_test.dart:127-141` |
| BR-RL-12 | Manual `free()` releases the owned pointer and detaches its finalizer; otherwise the finalizer is the fallback release path. | 🟢 CONFIRMED | `lib/src/repository.dart:438-445`, `lib/src/worktree.dart:132-149` |
| BR-RL-13 | `createCommitOnHead` clears the index, stages the supplied files, writes a tree, uses the current HEAD commit as parent, and updates `HEAD`. | 🟢 CONFIRMED | `lib/src/extensions/repository.dart:8-37` |
| BR-RL-14 | Repository wrappers are process-local capabilities and inherit filesystem authority from the embedding process. | 🟢 CONFIRMED | `permissions.md` |
| BR-RL-15 | Thread-safe concurrent mutation of one repository wrapper is not established by the extracted evidence. | 🔴 GAP | `domain.md`, `architecture.md` |

## Functional Requirements

| ID | Requirement | Priority | Acceptance summary | Confidence |
| --- | --- | --- | --- | --- |
| FR-RL-01 | The API shall create a repository with basic or extended initialization options, including bare mode, mode bits, workdir, template, initial HEAD, description, and origin URL where supported. | Must | A valid target yields an owned `Repository`; native invalid-path/options failures surface as package errors. | 🟢 CONFIRMED |
| FR-RL-02 | The API shall discover a repository from a starting path with optional ceiling directories. | Should | A containing repository returns its metadata path; absence produces the translated native error. | 🟢 CONFIRMED |
| FR-RL-03 | The API shall open standard, extended-search, and bare repositories. | Must | A valid repository yields a usable wrapper; a missing/invalid repository fails without returning a partial wrapper. | 🟢 CONFIRMED |
| FR-RL-04 | The API shall clone a remote repository with caller-selected bare/checkout/remote/repository callbacks and transfer callbacks. | Must | A successful clone yields an owned repository; callback or transport failure aborts with a translated error. | 🟢 CONFIRMED |
| FR-RL-05 | The API shall expose repository metadata and state, including path, common directory, namespace, bare/empty/shallow/worktree status, HEAD state, object format, workdir, message, and active operation state. | Must | Values reflect libgit2 state and absent optional state uses the documented Dart representation. | 🟢 CONFIRMED |
| FR-RL-06 | The API shall set, detach, and inspect HEAD using direct OIDs, symbolic reference names, and annotated commits where applicable. | Must | Supported target forms update HEAD; unsupported target types or invalid native targets fail explicitly. | 🟢 CONFIRMED |
| FR-RL-07 | The API shall get and set repository identity, namespace, workdir, configuration, index, and object database handles. | Should | Valid values are observable through later reads; native ownership/validation failures are translated. | 🟢 CONFIRMED |
| FR-RL-08 | The API shall enumerate or access repository-associated config, index, ODB, HEAD, references, tags, branches, stashes, remotes, submodules, worktrees, and default signature. | Must | Each accessor returns the corresponding typed wrapper/list or a translated error when unavailable. | 🟢 CONFIRMED |
| FR-RL-09 | The API shall return repository-wide and single-path status without treating the zero-valued current state as a set flag. | Must | Changed paths contain all applicable non-zero flags; a current path returns an empty status set. | 🟢 CONFIRMED |
| FR-RL-10 | The API shall walk commit history from a supplied OID with caller-selected sorting. | Should | The result begins from the requested root and follows configured revision-walk ordering. | 🟢 CONFIRMED |
| FR-RL-11 | The API shall execute reset and default-reset operations with typed reset/checkout options and pathspecs. | Must | A valid reset changes the selected repository projection; invalid targets or unsafe native states fail explicitly. | 🟢 CONFIRMED |
| FR-RL-12 | The API shall expose attribute lookup/iteration, macro registration, and attribute-cache flush operations. | Could | Attribute values and iteration results match libgit2 evaluation for the supplied path/flags/commit context. | 🟢 CONFIRMED |
| FR-RL-13 | The API shall calculate ahead/behind counts, describe reachable names, hash files, and generate repository packs. | Should | Each operation returns its typed result and releases temporary native results. | 🟢 CONFIRMED |
| FR-RL-14 | The API shall clean active repository operation metadata when `stateCleanup` succeeds. | Must | The repository transitions from an active operation state to `none`; cleanup failure is surfaced. | 🟢 CONFIRMED |
| FR-RL-15 | The API shall create, lookup, open, list, inspect, lock, unlock, prune, validate, and release linked worktrees. | Should | Valid worktrees complete each lifecycle operation; unknown/invalid names, paths, or native state fail explicitly. | 🟢 CONFIRMED |
| FR-RL-16 | The API shall create a commit on HEAD from a supplied file list, message, author, and committer using the existing HEAD commit as parent. | Could | Files are staged into a new tree and `HEAD` advances to the new commit; staging/tree/commit failure aborts the flow. | 🟢 CONFIRMED |
| FR-RL-17 | Repository and worktree wrappers shall provide explicit release and fallback finalizer cleanup for owned native handles. | Must | Explicit release frees once and detaches fallback cleanup; unreleased owned wrappers remain eligible for finalization. | 🟢 CONFIRMED |

## Non-Functional Requirements

| Type | Requirement derived from evidence | Evidence | Confidence |
| --- | --- | --- | --- |
| Memory safety | Temporary native objects and buffers shall be released on both successful and failed operation paths; persistent repository/worktree handles shall have explicit and fallback cleanup. | `lib/src/repository.dart:438-445`, `lib/src/worktree.dart:132-149`, ADR-003 | 🟢 CONFIRMED |
| Type safety | Public operations shall expose typed Dart values and wrappers; raw binding calls and pointer arithmetic shall remain below the public package facade. | `lib/git2dart.dart`, ADR-002 | 🟢 CONFIRMED |
| Error consistency | Negative libgit2 results shall be translated through the shared native error model; locally decidable invalid polymorphic inputs shall raise Dart argument/type errors. | `lib/src/helpers/error_helper.dart`, `lib/src/repository.dart:300-313`, ADR-004 | 🟢 CONFIRMED |
| Portability | Repository behavior shall remain supported on Android, iOS, Linux, macOS, and Windows under the declared Dart/Flutter constraints. | `pubspec.yaml`, `.github/workflows/publish.yml` | 🟢 CONFIRMED |
| ABI compatibility | Repository adapters shall use declarations from the compatible `git2dart_binaries` dependency line and require explicit review when that API changes. | `pubspec.yaml`, ADR-001, API comparison tooling | 🟢 CONFIRMED |
| Security | Filesystem and repository mutations shall not claim authority beyond the embedding process; force/reset/checkout choices remain explicit caller capabilities. | `permissions.md` | 🟢 CONFIRMED |
| Concurrency | No guarantee of safe concurrent mutation of a shared repository wrapper or process-global libgit2 state shall be inferred until validated. | `domain.md`, `architecture.md` | 🔴 GAP |

## Acceptance Criteria

### AC-RL-01 — Initialize and open a repository

🟢 **CONFIRMED**

```gherkin
Dado a writable valid filesystem path
Quando the caller initializes a non-bare repository and then opens that path
Então an owned Repository is returned and reports the expected repository path and non-bare state
```

🟢 **CONFIRMED**

```gherkin
Dado a path that does not contain a repository
Quando the caller attempts a normal or extended open that cannot locate one
Então the operation throws the translated libgit2 error and returns no partial Repository
```

### AC-RL-02 — Select HEAD representation

🟢 **CONFIRMED**

```gherkin
Dado an open repository and an existing reference name or valid Oid
Quando the caller sets HEAD with the reference name or Oid
Então HEAD becomes symbolic for the String target or detached for the Oid target
```

🟢 **CONFIRMED**

```gherkin
Dado an open repository
Quando the caller passes a target that is neither String nor Oid to setHead
Então the operation throws ArgumentError without selecting another target representation
```

### AC-RL-03 — Read repository status

🟢 **CONFIRMED**

```gherkin
Dado a non-bare repository containing changed paths
Quando the caller requests repository status
Então every changed path is mapped to all applicable non-zero GitStatus values
```

🟢 **CONFIRMED**

```gherkin
Dado a bare repository without a working directory
Quando the caller requests workdir-dependent status
Então the operation throws the translated native error
```

### AC-RL-04 — Reset selected state

🟢 **CONFIRMED**

```gherkin
Dado an open repository and a valid target Oid
Quando the caller performs a typed reset with valid checkout options
Então libgit2 applies the requested reset and the temporary target object is released
```

🟢 **CONFIRMED**

```gherkin
Dado an invalid or unavailable reset target
Quando the caller performs reset
Então the operation throws the translated error without returning a success result
```

### AC-RL-05 — Clean an active operation state

🟢 **CONFIRMED**

```gherkin
Dado a repository in merge, rebase, or another cleanup-supported operation state
Quando the caller invokes stateCleanup and libgit2 accepts the cleanup
Então the repository reports GitRepositoryState.none
```

🟢 **CONFIRMED**

```gherkin
Dado a repository whose active state cannot be cleaned by libgit2
Quando the caller invokes stateCleanup
Então the cleanup failure is surfaced as a translated error
```

### AC-RL-06 — Manage a linked worktree

🟢 **CONFIRMED**

```gherkin
Dado an open repository and a valid unique worktree name and path
Quando the caller creates, locks, unlocks, validates, and opens the worktree
Então each operation returns or exposes the corresponding valid linked-worktree state
```

🟢 **CONFIRMED**

```gherkin
Dado an invalid worktree name, invalid path, or unknown lookup name
Quando the caller creates or looks up the worktree
Então the operation throws the translated error and does not return a valid Worktree wrapper
```

### AC-RL-07 — Release native ownership

🟢 **CONFIRMED**

```gherkin
Dado an owned Repository or Worktree wrapper
Quando the caller invokes free
Então the matching native resource is released and the wrapper finalizer is detached
```

🔴 **GAP**

```gherkin
Dado overlapping operations that share one Repository wrapper across isolates or threads
Quando those operations mutate repository or process-global native state concurrently
Então the supported safety and ordering guarantees require human and dynamic validation
```

## Priority (MoSCoW)

| Requirement group | MoSCoW | Rationale | Confidence |
| --- | --- | --- | --- |
| Acquire/open/clone and own a repository | Must | It is the entry point for nearly every package capability. | 🟢 CONFIRMED |
| HEAD, state, status, reset, and child-resource access | Must | These are core repository integrity and coordination contracts used across features. | 🟢 CONFIRMED |
| Native resource cleanup and error translation | Must | Incorrect behavior risks leaks, crashes, or false success across all repository flows. | 🟢 CONFIRMED |
| Worktree lifecycle | Should | It is a complete supported feature but not required for single-worktree repositories. | 🟢 CONFIRMED |
| History, graph counts, describe, hash, and pack helpers | Should | They are important repository-level conveniences with lower-level alternatives elsewhere in the package. | 🟡 INFERRED |
| Attributes and commit-on-HEAD convenience | Could | They are specialized or compositional APIs rather than universal repository acquisition requirements. | 🟡 INFERRED |
| Concurrent shared-wrapper mutation guarantee | Won't for this extracted contract | The legacy evidence does not establish such a guarantee. | 🔴 GAP |

## Code Traceability

| Legacy file | Class or responsibility | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/src/repository.dart` | `Repository`, `RepositoryCallback`, `Identity`; all high-level repository operations | Direct | 🟢 CONFIRMED |
| `lib/src/worktree.dart` | `Worktree` lifecycle and ownership | Direct | 🟢 CONFIRMED |
| `lib/src/extensions/repository.dart` | `RepositoryExtension.headCommit`, `createCommitOnHead` | Direct | 🟢 CONFIRMED |
| `lib/src/bindings/repository.dart` | Repository acquisition, metadata, state, child-handle, and mutation native calls | Direct | 🟢 CONFIRMED |
| `lib/src/bindings/worktree.dart` | Worktree native calls and pointer conversion | Direct | 🟢 CONFIRMED |
| `lib/src/bindings/status.dart` | Repository and file status projection | Direct | 🟢 CONFIRMED |
| `lib/src/bindings/reset.dart` | Reset and default-reset native operations | Direct | 🟢 CONFIRMED |
| `lib/src/bindings/graph.dart` | Ahead/behind graph calculation | Supporting | 🟢 CONFIRMED |
| `lib/src/bindings/attr.dart` | Attribute lookup, iteration, macro, and cache operations | Supporting | 🟢 CONFIRMED |
| `lib/src/bindings/describe.dart` | Describe result and formatting | Supporting | 🟢 CONFIRMED |
| `test/repository_test.dart` | Positive and negative repository behavior | Verification evidence | 🟢 CONFIRMED |
| `test/worktree_test.dart` | Positive and negative worktree behavior | Verification evidence | 🟢 CONFIRMED |

## Open Questions

- 🔴 **GAP** — Are `Repository` and its child wrappers intended to be used concurrently from multiple Dart isolates or native threads?
- 🔴 **GAP** — Which repository object formats are contractually supported end to end beyond the SHA-1-dominant test fixtures?
- 🔴 **GAP** — Is there a required idempotency or post-`free()` behavior contract for repeated release or later method calls?
- 🔴 **GAP** — Which live clone transports and authentication modes are release-gated on every supported platform?

