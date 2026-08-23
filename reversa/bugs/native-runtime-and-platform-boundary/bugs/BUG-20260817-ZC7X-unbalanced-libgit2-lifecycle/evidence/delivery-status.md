# Delivery Status

Observed on 2026-08-23.

## Repository integration

- Local branch: `0.5.5`
- Fix and integration commit: `131f7c8f405fd818affd1bf4cc3fd60cd2b52f60`
- Remote verification command: `git ls-remote origin refs/heads/0.5.5`
- Remote result: `origin/0.5.5` points to the same commit.
- Integration form: direct commit on the release branch; no pull request.

The commit contains the lifecycle source changes, regression tests, and the
`git2dart_binaries >=1.12.2 <1.13.0` dependency constraint.

## Fresh validation

- `flutter test -j 1 test/libgit2_lifecycle_source_test.dart test/libgit2_lifecycle_test.dart`: 8/8 passed.
- `flutter analyze lib test`: no issues found.
- Validation used the direct `F:/git2dart_binaries` dependency override and
  the hosted 1.12.1 package only as the Windows native binary root, preserving
  the previously recorded proof boundary.

## Publication boundary

- Pub.dev latest `git2dart_binaries`: `1.12.1`
- Required compatible companion: `>=1.12.2 <1.13.0`
- Pub.dev latest `git2dart`: `0.5.4`
- Published consumer version containing the fix: none observed

Sources:

- <https://pub.dev/packages/git2dart_binaries/versions>
- <https://pub.dev/packages/git2dart/versions>

The package closure policy remains unsatisfied until a compatible companion
version and a consumer version containing the fix are published. No `DONE.md`
may be created before then.
