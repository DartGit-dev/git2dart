# Direct Local Binaries Compatibility Check

- Date: 2026-08-22
- `git2dart` branch / HEAD: `0.5.5` / `b118faf9c933883cf22f6ac3451c9080c9cc467f`
- A6QS candidate: `aba8aa73dc94d9d11615809699616b8e9e644e84`
- Candidate ancestry: contained in the current `git2dart` HEAD
- Remote delivery branch: `origin/0.5.5` contains the candidate; `origin/main` does not
- Dependency override: `pubspec_overrides.yaml` -> `../git2dart_binaries`
- Resolved package root: `../../git2dart_binaries`
- Companion branch / HEAD: `1.12.2` / `ea87cf29626a371fcb33e646be64bfe30b565c72`

## Exported API comparison

Command:

```text
dart run tool/compare_git2dart_binaries_api.dart --old 1.12.1 --new F:/git2dart_binaries
```

The direct checkout intentionally removes the former top-level `libgit2` and
`libgit2Opts` fields. It adds the managed runtime API, including
`Libgit2Runtime`, `Libgit2RuntimeState`, `Libgit2OwnerLease`, and
`libgit2Runtime`. The current `git2dart` source and tests contain 1,094
references to the removed globals across 72 files.

This declaration comparison does not prove native ABI, binary packaging, or
runtime behavior compatibility.

## Current validation

Focused command:

```text
flutter test -j 1 test/oid_test.dart test/commit_test.dart
```

Result: exit code `1`. Both focused files fail during package compilation
because the direct checkout no longer exports `libgit2` and `libgit2Opts`.
No A6QS test body is reached.

Repository analyzer command:

```text
flutter analyze
```

Result: exit code `1`, `977 issues found`. The errors are dominated by
undefined `libgit2` / `libgit2Opts` references throughout the package.

## Proof boundary

The earlier Gate 2 green proof remains the accepted A6QS red-to-green evidence
for the dependency API supported by the branch when the gate was approved. The
direct checkout check neither refutes nor re-proves the OID ownership change:
compilation stops first at a package-wide managed-runtime API migration.

Adapting 72 consumer files to the new lifecycle API is a separate, broad
dependency-compatibility change set. It is outside approved A6QS Gate 2 and
requires its own plan, tests, and approval. This check does not advance package
closure; merge and publication of a fixed package version remain pending.

The local remote-tracking refs show both `origin/main` and `origin/0.5.5` still
declare package version `0.5.4`. Pub.dev also lists `0.5.4` as the current
published version on 2026-08-22. Thus the candidate has reached the remote
delivery branch, but it is neither merged to the default branch nor published
as a new fixed package version.
