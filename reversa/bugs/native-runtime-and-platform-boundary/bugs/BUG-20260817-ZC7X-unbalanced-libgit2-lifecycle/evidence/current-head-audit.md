# Current-head lifecycle audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Lifecycle corrective commit: `131f7c8f405fd818affd1bf4cc3fd60cd2b52f60`
- Scope checked: managed runtime consumer, owner leases, lifecycle regressions, and package delivery prerequisite

## Current implementation and validation

Production sources contain no raw `git_libgit2_init` or
`git_libgit2_shutdown` calls; the structural lifecycle regression passes.
`ManagedNativeOwner` acquires an owner lease, releases it exactly once, and
uses a finalizer fallback. Focused tests also prove repeated public calls,
live-owner shutdown rejection, derived-child ownership, construction rollback,
stream transfer, and two-isolate lease composition.

| Command | Result |
| --- | --- |
| `flutter test -j 1 test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart` | exit 0; 8 passing |
| `flutter analyze lib/src/libgit2.dart lib/src/helpers/native_owner.dart lib/src/repository.dart lib/src/commit.dart test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart` | exit 0; no issues |
| `git diff --check 131f7c8^ 131f7c8 -- lib/src/libgit2.dart lib/src/helpers/native_owner.dart lib/src/repository.dart lib/src/commit.dart test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart` | exit 0 |

No current source or test gap was demonstrated, so this audit made no code or
test edit and did not trigger an independent review.

## Delivery blocker

The current consumer `pubspec.yaml` requires
`git2dart_binaries >=1.13.0 <1.14.0`; `.dart_tool/package_config.json` resolves
cached `1.13.0` for local validation. The pub.dev versions page currently
lists 1.12.1 as latest, so the managed-runtime companion required by the
current consumer cannot yet be resolved by a fresh public-package install.

The effective lifecycle specification remains `spec-correta`. Repository
integration is complete because `131f7c8` is contained by local and origin
`0.5.5`, but compatible companion publication and a consumer release are
still pending. The record therefore remains `active` / `delivering`.
