---
name: check-git2dart-binaries-api
description: Compare public API declarations between git2dart_binaries versions and assess their impact on git2dart. Use when updating, upgrading, or reviewing git2dart_binaries; when asked what changed between two package versions; when comparing package APIs; or when adapting bindings after a dependency update.
---

# Check git2dart_binaries API

Use the repository's comparison tool, then connect declaration changes to
git2dart code. Keep the complete diff out of the conversation: it is an
intermediate artifact, not the result.

## Compare versions

Prefer explicit versions when the user provides them:

```shell
dart run tool/compare_git2dart_binaries_api.dart \
  --old <old-version> --new <new-version> \
  --output <temporary-report-path>
```

Run without version arguments only when the user requests the default workflow.
That mode compares the version in
`tool/api_diff/git2dart_binaries.baseline` with the version in `pubspec.lock`.

Accept paths and complete `pub://` or `git://` package references as supported
by the project tool.

For every comparison, write the Markdown report to a unique temporary file
outside tracked source (for example, under `.dart_tool/`). Do not stream the
CLI report into agent context. Inspect the report locally and return only the
change counts, changed declaration names, and the small sections relevant to
consumers found in `git2dart`. Delete the temporary report after the result is
derived. Preserve it or copy it to a user-requested path only when the user
explicitly requests a persistent Markdown file.

If local inspection needs more detail, progressively widen it: start with
report headings and declaration identifiers, then read only the sections for
changed symbols with actual consumers. Never load or echo the whole report.

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
to identify concrete consumers. Search first for exact changed identifiers;
expand the query only when that finds no consumer. Return paths and symbol names,
not full matching files.

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

Return a compact result: versions compared; breaking and non-breaking counts;
changed declarations with concrete consumers; recommended action; validation not
performed. List individual declarations only when breaking or consumed. If no
changes are found, say specifically that no public Dart API changes were
detected rather than claiming that the package versions are fully equivalent.
Do not create or link a report file unless the user requested one.
