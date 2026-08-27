# Delivery Status

Observed on 2026-08-27.

## Repository integration

- Local branch: `0.5.5`
- Fix and integration commit: `131f7c8f405fd818affd1bf4cc3fd60cd2b52f60`
- Current merge-base checks: `131f7c8` is contained by local `0.5.5` and
  `origin/0.5.5`.
- Integration form: direct commit on the release branch; no pull request.

The commit contains the lifecycle source changes and regressions. Subsequent
branch work now declares `git2dart_binaries >=1.13.0 <1.14.0`.

## Fresh validation

- `flutter test -j 1 test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart`: 8/8 passed.
- `flutter analyze lib/src/libgit2.dart lib/src/helpers/native_owner.dart lib/src/repository.dart lib/src/commit.dart test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart`: no issues found.
- Current `.dart_tool/package_config.json` resolves the lifecycle API from the
  local hosted-cache directory `git2dart_binaries-1.13.0`.

## Publication boundary

- Pub.dev latest `git2dart_binaries`: `1.12.1`
- Current required compatible companion: `>=1.13.0 <1.14.0`
- Local green tests use cached `1.13.0`, but that version is not available on
  the current pub.dev versions list.
- Pub.dev latest `git2dart`: `0.5.4`
- Published consumer version containing the fix: none observed

Sources:

- <https://pub.dev/packages/git2dart_binaries/versions>
- <https://pub.dev/packages/git2dart/versions>

The package closure policy remains unsatisfied until a compatible companion
version and a consumer version containing the fix are published. No `DONE.md`
may be created before then.
