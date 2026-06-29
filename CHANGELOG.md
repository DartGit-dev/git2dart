# Changelog
## [0.5.1] - 2026-06-29
### Fixed
* Require `git2dart_binaries` `>=1.11.2 <1.12.0` to pick up the latest
  packaged libgit2 binaries and generated bindings.

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
