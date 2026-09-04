# Changelog
## [0.5.6] - 2026-09-04
### Changed
- Upgraded `git2dart_binaries` to the 1.14.x companion range, resolving 1.14.0 with bundled libgit2 1.9.7 on the validated Windows x64 host.
- Confirmed that the 1.13.0-to-1.14.0 comparison detected no public Dart declaration changes.

### Testing
- Updated the libgit2-version expectation to the directly observed bundled 1.9.7 runtime value.

## [0.5.5] - 2026-08-28
### Features
* Add `Libgit2.shutdown()` for deterministic, isolate-scoped native runtime
  shutdown after live repository and commit owners are released.
* Add explicit native-memory release for owned `Oid` and `IndexEntry` values.

### Changed
* Update `git2dart_binaries` to `>=1.13.0 <1.14.0` and migrate the native
  adapter to its managed runtime, lifecycle, bindings, and options APIs.
* Preserve the public integer option API while using ABI-correct native-width
  types for mmap, pack-object, and cached-memory values.

### Fixes
* Correct native ownership for repositories, commits, OIDs, tree entries,
  index entries, status performance data, and remote results to prevent leaks,
  dangling pointers, double frees, and invalid frees.
* Propagate libgit2 failures from global options, index persistence, repository
  identity, rebase completion, and option initialization instead of silently
  continuing with invalid output.
* Release temporary option structures, buffers, callbacks, and credentials on
  success and failure paths, and clear remote callback state after operations.

#### Resolved Reversa defects

##### Git objects and object database

* `BUG-20260817-A6QS` — Manage owned OID allocations and safely copy borrowed OID pointers.
* `BUG-20260817-E3LU` — Prevent invalid release of borrowed `TreeEntry` values.
* `BUG-20260817-H7NP` — Encode `BlobWriteStream.writeString` input as UTF-8.
* `BUG-20260817-K2RY` — Dispose libgit2 buffers after blob filtering.

##### History and integration operations

* `BUG-20260817-J9CU` — Propagate native failures from rebase finish and abort.
* `BUG-20260817-P5DB` — Release native merge options on every exit.
* `BUG-20260817-T8MW` — Pass `nullptr` for empty root-commit parent arrays.
* `BUG-20260817-X4AE` — Dispose libgit2 commit buffers on success and failure.

##### Native runtime and platform boundary

* `BUG-20260817-3PON` — Release native string-array storage returned by the extensions getter.
* `BUG-20260817-47ZS` — Release credential callback allocations after remote operations.
* `BUG-20260817-CIKD` — Serialize callback-bearing remote operations and reject overlapping callback-state replacement.
* `BUG-20260817-DQPX` — Propagate native failures from global libgit2 option APIs.
* `BUG-20260817-O3B3` — Clear sensitive remote callback context after every operation.
* `BUG-20260817-QWMA` — Validate every fallible native options initializer before structure use.
* `BUG-20260817-ZC7X` — Balance libgit2 initialization leases with deterministic shutdown.

##### References and remotes

* `BUG-20260817-2TB4` — Release native OID storage used by reference name-to-ID lookup.
* `BUG-20260817-3FWN` — Release fetch options and refspec allocations.
* `BUG-20260817-BVMB` — Reject invalid refspec indexes instead of wrapping null pointers.
* `BUG-20260817-VG7G` — Guarantee remote disconnect after advertisement listing.
* `BUG-20260817-VGYQ` — Reject out-of-range reflog indexes instead of wrapping null entries.

##### Repository lifecycle

* `BUG-20260817-L8WX` — Propagate native repository identity lookup failures.
* `BUG-20260817-N4FC` — Release native worktree handles created during listing.
* `BUG-20260817-Q6JV` — Dispose native worktree lock-reason buffers.
* `BUG-20260817-V9TR` — Copy status performance counters before arena-backed storage is released.

##### Working tree and index

* `BUG-20260817-6KRT` — Propagate native index read and write failures.
* `BUG-20260817-8HNA` — Release checkout options used by stash apply and pop.
* `BUG-20260817-M2VF` — Release temporary lookup objects during reference and commit checkout.
* `BUG-20260817-R4PL` — Give mutable `IndexEntry` values independent owned path storage.
* `BUG-20260817-Y7GX` — Release output OID buffers when index, stash, or diff operations fail.

### CI
* Add cross-platform build gates for Linux, macOS, Windows, and Android using
  the validated Flutter toolchain.
* Skip build, test, and publication jobs when the triggering commit message
  contains the `[docs]` marker.

### Documentation
* Document deterministic runtime shutdown, explicit `Oid` and `IndexEntry`
  ownership, and the `git2dart_binaries` 1.13 dependency baseline.

## [0.5.4] - 2026-07-21
### Features
* Add `Libgit2.packMaxObjectSize` for controlling the maximum declared object
  size accepted in downloaded packfiles.

### Changed
* Update `git2dart_binaries` to `1.12.1`, including bundled libgit2 `1.9.6`
  and typed pack maximum object size options.

### Tooling
* Add a project skill and comparison command for analyzing public API changes
  between `git2dart_binaries` versions.
* Print API comparison results directly to the agent, with optional Markdown
  export when explicitly requested.

### Documentation
* Document the `git2dart_binaries` API update and migration workflow.

## [0.5.3] - 2026-06-30
### Documentation
* Link to the multi-platform `git2dart_examples` Flutter demo app from the
  main README and documentation index.

## [0.5.2] - 2026-06-29
### Features
* Expand libgit2 binding coverage across repository, remote, status, tree,
  tag, signature, submodule, config, diff, index, ODB, reference, and related
  APIs.
* Add public wrappers for extended repository opening, basic repository
  initialization, annotated HEAD detaching, remote instance URL overrides,
  remote autotag configuration, tree walking, tree updates, status callbacks,
  and annotation-only tag creation.

### Testing
* Add focused tests for the newly exposed binding wrappers.
* Include binding files in coverage by removing file-level coverage ignores.

## [0.5.1] - 2026-06-29
### Fixed
* Require `git2dart_binaries` `>=1.11.2 <1.12.0` to pick up the latest
  packaged libgit2 binaries and generated bindings.
* Add a remote `certificateCheck` callback so SSH clients can supply host key
  trust decisions without relying on `known_hosts` lookup.

### Documentation
* Document the `git2dart_binaries` `1.11.2` dependency baseline in the README.

## [0.5.0] - 2026-05-30
### Features
* Update `git2dart_binaries` constraint to `>=1.11.0 <1.12.0`.
* Add public APIs for commit graphs, ignore rules, messages, and pathspec matching.
* Extend config, diff, oid, repository, and tree APIs with additional libgit2-backed helpers.
* Add Flutter iOS platform support and shared `PlatformSpecific.initialize()`.

### Documentation
* Refresh public API documentation for consistency.
* Add platform setup documentation for iOS.

## [0.4.0] - 2025-11-20
### Features
* Add `PlatformSpecific.androidInitialize` to wire up libgit2 SSL certificates automatically on Flutter/Android before cloning or fetching.
* Re-export the platform helper from `git2dart.dart` so Flutter apps can call it without touching internals.

### Documentation
* Introduce a dedicated Android guide (`doc/types/android.md`) covering prerequisites, initialization flow, and troubleshooting tips.
* Expand `README.md` and `doc/README.md` with Flutter-on-Android quick start notes, including supported `arm64-v8a` and `x86_64` ABIs.

## [0.3.1] - 2025-11-19
### Changes
* Set restriction for version git2dart_binaries library

## [0.3.0] - 2025-06-11
### Features
* Add `BlobWriteStream` for streaming blob writes.
* Introduce `Filter` API with options.
* Expose additional `Worktree` operations.
* Add repository attribute helpers and `AttrOptions`.
* Expand bindings for ODB, Oid, Packbuilder, Patch and Rebase.
* Improve tag and tree builder callbacks.

### Fixes
* Stabilize remote tests.
## [0.2.2] - 2025-06-07
### Changes
*  upgrade version libgit2 to 1.9.1

## [0.2.1] - 2025-05-29
### Changes
* Add missing API sections to README:
  * Remote
  * Reset
  * Blame
  * Describe
  * Note
  * Rebase
  * Mailmap
  * Credentials
  * ODB
  * Packbuilder
  * Signature
  * RevParse
  * AnnotatedCommit
* Add system dependencies section to README for Linux, macOS and Windows

## [0.2.0] - 2025-05-17

### Breaking Changes
* Migrate to Dart 3
* Migrate to 1.9.0 version libgit2
* Migrate actual api, remove depricated api calls

## [0.0.6] - 2023-03-09

### Features
* Add macOS test support

### Fixes
* Fix README documentation

## [0.0.5] - 2023-03-08

### Features
* Add repository extensions:
  * `headCommit`
  * `createCommitOnHead`

### Fixes
* Fix repository links

### Dependencies
* Update dependencies

## [0.0.4] - 2023-03-07

### Dependencies
* Update dependencies

## [0.0.3] - 2023-03-05

### Dependencies
* Update dependencies

## [0.0.2] - 2023-03-05

### Dependencies
* Update dependencies

## [0.0.1] - 2023-03-02

### Features
* Initial release
