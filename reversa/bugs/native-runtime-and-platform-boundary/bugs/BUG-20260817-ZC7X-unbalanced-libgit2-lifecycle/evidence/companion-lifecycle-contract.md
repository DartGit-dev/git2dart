# Companion Lifecycle Contract Available

- Date verified: 2026-08-23
- Companion checkout: `F:/git2dart_binaries`
- Companion branch / commit: `1.12.2` / `ea87cf29626a371fcb33e646be64bfe30b565c72`
- Commit subject: `feat: manage libgit2 process lifecycle`
- Consumer override: `pubspec_overrides.yaml` -> `../git2dart_binaries`
- Resolved package root: `../../git2dart_binaries`

## Implemented companion boundary

The companion feature `001-libgit2-process-lifecycle` records an explicit
Gate 2 GREEN result for its own repository. It exports one isolate-local
`libgit2Runtime` with:

- checked `bindings` and `options` access;
- `withCall` transient protection for ownerless synchronous native work;
- `acquireOwner` persistent exact-once ownership leases;
- guarded, idempotent, terminal `shutdown`;
- construction rollback, ownership transfer, and non-throwing finalizer
  fallback through `Libgit2OwnerLease`.

The eager top-level `libgit2` and `libgit2Opts` globals were intentionally
removed. Native library discovery and raw init/shutdown ownership remain in
`git2dart_binaries`; `git2dart` must consume this public API rather than
reimplement the loader.

## Consumer impact

The current `git2dart` source and tests contain:

- 1,096 `libgit2` / `libgit2Opts` occurrences across 72 Dart files;
- 66 direct `git_libgit2_init()` calls across 9 source files;
- 31 finalizer-backed owner files requiring ownership classification.

With the direct checkout active, focused package tests stop during compilation
and `flutter analyze` reports 977 issues because the removed globals are still
referenced. No lifecycle regression test body is reached.

## Gate consequence

The former ZC7X blocker required the companion lifecycle and loading contract
to exist first. Commit `ea87cf2` satisfies that prerequisite, so the blocker
is cleared.

The companion Gate 2 evidence explicitly leaves the separate `git2dart`
consumer gate closed. The historical git2dart-local runtime proposal and its
approved RED test are still superseded because they target a duplicate local
runtime API. A refreshed consumer-only plan, an adapted Gate 1 test diff, and a
separate Gate 2 source diff are required.

## Proof boundary

The companion evidence is GREEN on the available Windows host. It does not
prove the unmodified `git2dart` consumer, macOS, Linux, iOS, Android, native
ABI compatibility, merge, publication, or package-version availability.
