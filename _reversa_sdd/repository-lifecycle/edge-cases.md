# Repository Lifecycle — Edge Cases

> 🟢 **CONFIRMED** — This catalog captures boundary and failure behavior for repository acquisition, state, HEAD, status, reset, worktrees, and native ownership. Confirmed cases come from code/tests; inferred cases are explicitly marked; gaps require validation before claiming compatibility.

## Classification

| Class | Meaning | Required treatment |
| --- | --- | --- |
| 🟢 CONFIRMED | Directly represented by current code, tests, or an explicit public contract | Preserve in a faithful reimplementation |
| 🟡 INFERRED | Follows from architecture or libgit2-facing patterns but lacks direct focused proof | Validate with targeted tests |
| 🔴 GAP | The current extraction cannot establish the behavior | Obtain a decision or dynamic evidence |

## Acquisition and Discovery

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-01 | Initialize with `bare = true` while the supplied flag set omits `GitRepositoryInit.bare` | The wrapper adds the bare bit before native initialization. | `lib/src/repository.dart:78-82` | 🟢 CONFIRMED |
| EC-RL-02 | Initialize with an invalid or unwritable path | Native initialization fails and the wrapper returns no usable repository. | Repository binding error policy | 🟢 CONFIRMED |
| EC-RL-03 | Extended open cannot find a repository below the supplied ceiling directory | The native failure is translated rather than represented as null. | `test/repository_test.dart:65-74` | 🟢 CONFIRMED |
| EC-RL-04 | Discover starts outside any repository | Discovery throws the translated not-found error. | `test/repository_test.dart:119-132` | 🟢 CONFIRMED |
| EC-RL-05 | Open a bare repository through the normal and bare-specific acquisition paths | The resulting repository reports bare state; workdir-dependent operations remain unavailable. | `test/repository_test.dart:37-44`, bare status test | 🟢 CONFIRMED |
| EC-RL-06 | Clone destination already contains conflicting data | The native clone result is authoritative and failure must not yield a partial success wrapper. | Clone adapter/error architecture | 🟡 INFERRED |
| EC-RL-07 | Clone callback fails after local files have been created | The operation throws; cleanup/partial-directory semantics follow libgit2 and are not normalized by the high-level wrapper. | Clone architecture and callback flow | 🟡 INFERRED |
| EC-RL-08 | Android clone/fetch occurs before platform certificate initialization | TLS behavior may fail because the Android CA path has not been installed. | `lib/src/platform_specific.dart`, ADR-005 | 🟢 CONFIRMED for required initialization; 🔴 GAP for every failure shape |

## Namespace, Identity, and Paths

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-09 | Repository has no namespace | `namespace` returns an empty string. | `test/repository_test.dart:134-137` | 🟢 CONFIRMED |
| EC-RL-10 | Caller passes null to `setNamespace` | The active namespace is removed. | `test/repository_test.dart:138-145` | 🟢 CONFIRMED |
| EC-RL-11 | Caller sets only one identity field or clears identity values | The wrapper forwards nullable name/email; exact persistence rules remain native. | `lib/src/repository.dart:343-351` | 🟢 CONFIRMED for forwarding; 🟡 INFERRED for all native combinations |
| EC-RL-12 | Caller assigns an invalid working-directory path | `setWorkdir` throws the translated native error. | `test/repository_test.dart:146-164` | 🟢 CONFIRMED |
| EC-RL-13 | Caller reads `workdir` from a bare repository | The binding's documented empty/absent representation is returned; callers must not treat it as a usable path. | `lib/src/repository.dart:414`, data dictionary | 🟢 CONFIRMED |
| EC-RL-14 | Paths differ only by platform separators or case | Behavior follows OS/libgit2 path semantics; no repository-layer normalization contract was extracted. | Cross-platform architecture | 🔴 GAP |

## HEAD and Repository State

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-15 | `setHead` receives an `Oid` | HEAD is detached to that object identifier. | `lib/src/repository.dart:300-313` | 🟢 CONFIRMED |
| EC-RL-16 | `setHead` receives a `String` naming a reference | HEAD becomes symbolic to that reference. | `lib/src/repository.dart:300-313` | 🟢 CONFIRMED |
| EC-RL-17 | `setHead` receives a value of another runtime type | The wrapper throws `ArgumentError` before native target dispatch. | `test/repository_test.dart:202-205` | 🟢 CONFIRMED |
| EC-RL-18 | Symbolic HEAD points to an unborn branch | `isBranchUnborn` is true and HEAD may be attached without an existing commit. | `test/repository_test.dart:195-201` | 🟢 CONFIRMED |
| EC-RL-19 | Caller asks for HEAD when no valid HEAD can be resolved | The native error is translated; no nullable reference is returned. | `test/repository_test.dart:165-170` | 🟢 CONFIRMED |
| EC-RL-20 | Annotated-commit detachment fails | The operation throws the translated native error and must not claim successful detachment. | `test/repository_test.dart:224-246` | 🟢 CONFIRMED |
| EC-RL-21 | `stateCleanup` is called when native cleanup cannot proceed | The operation throws and the active state remains authoritative. | `test/repository_test.dart:319-324` | 🟢 CONFIRMED |
| EC-RL-22 | Repository state was initiated outside this package's dedicated wrappers | `state` may still expose the corresponding libgit2 enum; not every state has a high-level starter method. | `_reversa_sdd/state-machines.md` | 🟢 CONFIRMED for observation; 🟡 INFERRED for initiation route |

## Status and History

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-23 | A status integer is exactly `GitStatus.current` (`0`) | `statusFile` returns an empty set; zero is never treated as a matching flag. | `lib/src/repository.dart:636-654` | 🟢 CONFIRMED |
| EC-RL-24 | One path has multiple non-zero status bits | Repository status includes every matching bit in the path's set. | `lib/src/repository.dart:592-624` | 🟢 CONFIRMED |
| EC-RL-25 | A status entry contains both `head_to_index` and `index_to_workdir` deltas | The repository-wide decoder prefers `head_to_index` for path projection. | `lib/src/repository.dart:597-606` | 🟢 CONFIRMED |
| EC-RL-26 | Status reports a rename | The decoder uses the new path rather than the old path. | `lib/src/repository.dart:606-610` | 🟢 CONFIRMED |
| EC-RL-27 | Status is requested for a bare repository | Workdir-dependent status throws. | `test/repository_test.dart:296-301` | 🟢 CONFIRMED |
| EC-RL-28 | File status is requested for an invalid path | The native error is translated. | `test/repository_test.dart:335-338` | 🟢 CONFIRMED |
| EC-RL-29 | FETCH_HEAD or MERGE_HEAD administrative files are absent | The corresponding getters return empty lists. | `test/repository_test.dart:314-318` | 🟢 CONFIRMED |
| EC-RL-30 | History starts from an unavailable OID | Revision-walk push/lookup fails rather than returning an unrelated empty history. | `lib/src/repository.dart:572-582`, revision-walk contract | 🟡 INFERRED |
| EC-RL-31 | History contains more commits than practical to materialize | `Repository.log` materializes the walker result as a list; no streaming/backpressure contract is exposed by this helper. | `lib/src/repository.dart:572-582` | 🟢 CONFIRMED |

## Reset, Attributes, Describe, and Pack

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-32 | Reset target OID cannot be resolved | Object lookup throws and reset is not invoked with a valid target. | `lib/src/repository.dart:674-696` | 🟢 CONFIRMED |
| EC-RL-33 | `resetDefault` receives null OID | No target object is looked up; the pathspec-only native reset is invoked with a null target. | `lib/src/repository.dart:708-723` | 🟢 CONFIRMED |
| EC-RL-34 | Reset/checkout pathspec is empty | Behavior follows libgit2; the wrapper does not define an additional empty-list rejection. | Reset wrapper design | 🟡 INFERRED |
| EC-RL-35 | Reset throws after the temporary target object was acquired | The design requires release, but exhaustive exceptional-path proof is absent. | ADR-003, architecture gap | 🔴 GAP |
| EC-RL-36 | Attribute is unspecified, set, unset, or a string value | The typed result may represent these distinct native attribute states; absence is not necessarily an error. | `lib/src/repository.dart:730-791`, attribute tests | 🟢 CONFIRMED |
| EC-RL-37 | Attribute iteration callback/binding fails | The failure is translated rather than silently returning a partial successful enumeration. | `test/repository_test.dart:380-439` | 🟢 CONFIRMED |
| EC-RL-38 | `describe` cannot find a matching name under supplied options | The native failure is translated; temporary describe results must not leak. | `lib/src/repository.dart:858-901` | 🟡 INFERRED |
| EC-RL-39 | Pack thread count or object selection is unusual but native-valid | The wrapper forwards the caller's selection and thread value to `PackBuilder`. | `lib/src/repository.dart:916-940` | 🟢 CONFIRMED |
| EC-RL-40 | Remote pack advertises an object larger than configured maximum | Process-global libgit2 pack limit may reject it; this is configured in the native-runtime component. | `domain.md`, `lib/src/libgit2.dart` | 🟢 CONFIRMED |

## Linked Worktrees

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-41 | Worktree create receives an invalid name or path | Creation throws and no valid worktree wrapper is returned. | `test/worktree_test.dart:81-91` | 🟢 CONFIRMED |
| EC-RL-42 | Worktree lookup uses an unknown name | Lookup throws the translated native error. | `test/worktree_test.dart:120-126` | 🟢 CONFIRMED |
| EC-RL-43 | Caller reads linked HEAD for an unknown worktree | Repository linked-HEAD lookup throws. | `test/worktree_test.dart:101-119` | 🟢 CONFIRMED |
| EC-RL-44 | Worktree is locked | Administrative mutation/prune behavior remains constrained until unlock under native rules. | `test/worktree_test.dart:127-141` | 🟢 CONFIRMED |
| EC-RL-45 | Worktree is pruned with caller-selected flags | Eligibility and effect reflect those native flags rather than a hard-coded policy. | `test/worktree_test.dart:142-177` | 🟢 CONFIRMED |
| EC-RL-46 | Listing worktrees encounters a native error | Listing throws rather than returning a partial list. | `test/worktree_test.dart:178-184` | 🟢 CONFIRMED |
| EC-RL-47 | `repositoryFromWorktree` is called on a valid worktree | A separately owned repository wrapper is returned and requires its own release lifecycle. | `test/worktree_test.dart:216-230` | 🟢 CONFIRMED |
| EC-RL-48 | Worktree administrative metadata is internally inconsistent | `validate` throws; `isValid` reports the native validity result. | `test/worktree_test.dart:231-238` | 🟢 CONFIRMED |

## Commit-on-HEAD Convenience

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-49 | HEAD is unborn or cannot resolve to a commit | `headCommit` lookup fails before staging/commit completion. | `lib/src/extensions/repository.dart:6-10` | 🟢 CONFIRMED by flow; 🔴 GAP for dedicated test |
| EC-RL-50 | Supplied file list is empty | The extension clears the index and writes the resulting tree; exact intended product semantics require validation. | `lib/src/extensions/repository.dart:13-37` | 🟡 INFERRED |
| EC-RL-51 | One supplied path cannot be staged | Index add fails and no success OID is returned; the index may already reflect earlier steps in the sequence. | Extension flow and index error model | 🟡 INFERRED |
| EC-RL-52 | Commit creation fails after index/tree mutation | Failure is surfaced, but the convenience wrapper does not provide an explicit rollback transaction. | `lib/src/extensions/repository.dart:13-37` | 🟡 INFERRED |
| EC-RL-53 | Current HEAD commit/tree belongs to a different repository | Repository-scoped lookup and commit ownership invariants reject invalid cross-repository composition. | Domain rules, commit contract | 🟢 CONFIRMED |

## Native Ownership and Lifecycle

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-54 | Caller manually frees a repository/worktree | The matching destructor runs and the finalizer is detached. | `lib/src/repository.dart:438-445`, `lib/src/worktree.dart:132-149` | 🟢 CONFIRMED |
| EC-RL-55 | Caller does not manually free an owned wrapper | The attached finalizer is eligible to release it later; release timing is nondeterministic. | ADR-003 | 🟢 CONFIRMED |
| EC-RL-56 | Caller invokes `free()` twice | Safe idempotency is not established; consumers must not assume repeated release is supported. | Missing guard contract | 🔴 GAP |
| EC-RL-57 | Caller invokes a method after `free()` | Safe failure is not established; use-after-free must be treated as unsupported until guarded. | Missing guard contract | 🔴 GAP |
| EC-RL-58 | A child wrapper outlives its repository | Correctness depends on the child's native ownership contract; no universal parent-retention guarantee is documented here. | Data dictionary and ownership architecture | 🔴 GAP |
| EC-RL-59 | Two concurrent operations mutate the same repository or static callback state | Ordering and isolation guarantees are not established. | Domain rule 23, architecture risks | 🔴 GAP |
| EC-RL-60 | A native error occurs after temporary allocation | Arena-scoped allocations should unwind; manually owned temporary resources require explicit cleanup. | ADR-003, native flow | 🟢 CONFIRMED as rule; 🔴 GAP for exhaustive proof |

## Platform and Compatibility Boundaries

| ID | Edge case | Expected behavior | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| EC-RL-61 | Native library or generated declarations are ABI-incompatible | Repository calls may fail to load or behave unsafely; dependency upgrades require API/ABI review. | ADR-001, dependency comparison tooling | 🟢 CONFIRMED |
| EC-RL-62 | Windows cannot locate `libgit2.dll` | Tests/runtime fail before repository operations; the DLL directory must be discoverable by the loader. | `AGENTS.md`, platform documentation | 🟢 CONFIRMED |
| EC-RL-63 | iOS static symbols have not been eagerly initialized | `PlatformSpecific.initialize()` is the documented startup path before normal use. | `lib/src/platform_specific.dart` | 🟢 CONFIRMED |
| EC-RL-64 | Repository uses SHA-256 object format | `oidType` and some validation paths exist, but complete lifecycle support is not proven. | Domain/architecture gaps | 🔴 GAP |
| EC-RL-65 | Default tests pass while live remote tests remain skipped | Local repository behavior has evidence, but clone/network compatibility is not proven by that result. | `dart_test.yaml`, ADR-007 | 🟢 CONFIRMED |

## Minimum Edge-Case Test Matrix

| Test group | Required cases | Confidence |
| --- | --- | --- |
| Acquisition | Bare-flag forcing, missing repository, ceiling-directory stop, invalid path, clone callback failure | 🟢 CONFIRMED except live clone evidence 🔴 GAP |
| HEAD/state | OID, symbolic, unborn, invalid type, missing HEAD, failed detach, cleanup success/failure | 🟢 CONFIRMED |
| Status | Current zero, multi-bit, rename path, bare repository, invalid path, absent administrative files | 🟢 CONFIRMED |
| Reset | Missing target, null default target, empty pathspec characterization, injected native failure cleanup | 🟢 CONFIRMED / 🔴 GAP for cleanup proof |
| Worktrees | Invalid name/path, unknown lookup, lock/unlock, prune flags, list error, invalid metadata | 🟢 CONFIRMED |
| Ownership | Explicit release, finalizer fallback, repeated release, post-release method, child lifetime | 🟢 CONFIRMED / 🔴 GAP for unsupported lifecycle edges |
| Compatibility | Native loading on five platforms, SHA-1/SHA-256 matrix, live HTTPS/SSH clone | 🔴 GAP until fresh dynamic evidence |

## Decisions Required Before Claiming Full Fidelity

1. 🔴 **GAP** — Define whether `free()` is intentionally non-idempotent or must become guarded.
2. 🔴 **GAP** — Define child-wrapper lifetime guarantees relative to the repository wrapper.
3. 🔴 **GAP** — Define concurrency and isolation guarantees for repository handles, callbacks, and global libgit2 state.
4. 🔴 **GAP** — Define the supported SHA-256 repository operation matrix.
5. 🔴 **GAP** — Define required live clone transports, credential types, certificate policies, and platform combinations.
6. 🔴 **GAP** — Define whether `createCommitOnHead` should be transactional or document its partial-index mutation behavior.

