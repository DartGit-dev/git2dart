# Analyzing `git2dart_binaries` API updates

The repository includes a repeatable API comparison tool for dependency
updates. It compares the public Dart API exported by two
`git2dart_binaries` versions and prints breaking, additive, and patch-level
changes directly to the console for the agent to review.

## Normal update workflow

1. Update the `git2dart_binaries` constraint in `pubspec.yaml` and resolve the
   dependency:

   ```shell
   flutter pub upgrade git2dart_binaries
   ```

2. Print the API comparison:

   ```shell
   dart run tool/compare_git2dart_binaries_api.dart
   ```

   The old version comes from
   `tool/api_diff/git2dart_binaries.baseline`. The new version comes from
   `pubspec.lock`. The result is printed directly to standard output.

3. Review the output in this order:

   - breaking changes: removed symbols and changed signatures that require
     changes in `lib/src/bindings/`;
   - additive changes: new libgit2 functions, structs, fields, constants, and
     enums that can be exposed by `git2dart`;
   - patch changes: metadata or API details that normally do not require a
     public `git2dart` change.

4. Find the concrete integration impact:

   ```shell
   flutter analyze
   flutter test
   ```

   Static analysis identifies call sites affected by removed or changed FFI
   declarations. Tests cover behavioral and native ABI changes that cannot be
   inferred from Dart declarations alone.

5. After adapting `git2dart` and passing all checks, replace the version in
   `tool/api_diff/git2dart_binaries.baseline` with the newly integrated
   version. Commit that baseline change together with the dependency update.

## Compare before updating

Both versions can be supplied explicitly without changing `pubspec.yaml` or
`pubspec.lock`:

```shell
dart run tool/compare_git2dart_binaries_api.dart --old 1.11.4 --new 1.11.5
```

The arguments also accept paths and complete package references supported by
`dart_apitool`. For example, compare the published baseline with an unpublished
local checkout:

```shell
dart run tool/compare_git2dart_binaries_api.dart --old 1.11.4 --new ../git2dart_binaries
```

Use `--output <path>` only when a persistent Markdown report is explicitly
needed. Published package references require access to pub.dev; local paths can
be used for unpublished or offline comparisons once their dependencies are
available.

## What the comparison cannot prove

The API diff analyzes Dart declarations, not native binary compatibility or
function behavior. Always review the `git2dart_binaries` changelog and libgit2
release notes, then run the full test suite on every supported platform before
release.
