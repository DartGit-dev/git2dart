---
name: check-git2dart-binaries-api
description: Compare public API declarations between git2dart_binaries versions and assess their impact on git2dart. Use when updating, upgrading, or reviewing git2dart_binaries; when asked what changed between two package versions; when comparing package APIs; or when adapting bindings after a dependency update.
---

# Check git2dart_binaries API

Use the repository's comparison tool to emit an API diff directly to the
agent's command output, then connect declaration changes to git2dart code.

## Compare versions

Prefer explicit versions when the user provides them:

```shell
dart run tool/compare_git2dart_binaries_api.dart --old <old-version> --new <new-version>
```

Run without version arguments only when the user requests the default workflow.
That mode compares the version in
`tool/api_diff/git2dart_binaries.baseline` with the version in `pubspec.lock`.

Accept paths and complete `pub://` or `git://` package references as supported
by the project tool. Do not pass `--output` during normal skill use: consume the
CLI diff directly. Use `--output <path>` only when the user explicitly requests
a persistent Markdown file.

If a requested published version does not exist, report that clearly. Do not
substitute another version without user direction.

## Review the command output

Capture and summarize:

1. Breaking changes: removed declarations, changed signatures, and platform
   constraint changes.
2. Non-breaking changes: added methods, functions, structs, fields, constants,
   enums, and dependency changes.
3. Whether no public Dart API changes were detected.

Treat the tool's severity as a signal that still requires engineering judgment.
For every changed FFI symbol, search `lib/src/bindings/`, `lib/src/`, and `test/`
with `rg` to identify concrete consumers.

## Validate an upgrade

When the dependency has actually been updated, run:

```shell
dart format . --set-exit-if-changed
flutter analyze
flutter test
```

Static analysis finds source-level incompatibilities. Tests cover behavior and
native loading that declaration comparison cannot prove. Follow the repository
AGENTS.md requirements for platform-specific validation.

Do not edit `pubspec.yaml`, `pubspec.lock`, bindings, or the baseline when the
user only asks for a comparison or diagnosis. After the migration is complete
and all checks pass, update `tool/api_diff/git2dart_binaries.baseline` only as
part of an explicitly requested dependency update.

## Report limitations

State that the API diff compares exported Dart declarations. It does not detect
native ABI incompatibility, binary packaging changes, or implementation and
behavior changes. For an upgrade decision, also inspect the
`git2dart_binaries` changelog and relevant libgit2 release notes.

## Return the result

List the important changes from command output and identify any validation not
performed. If no changes are found, say specifically that no public Dart API
changes were detected rather than claiming that the package versions are fully
equivalent. Do not create or link a report file unless the user requested one.
