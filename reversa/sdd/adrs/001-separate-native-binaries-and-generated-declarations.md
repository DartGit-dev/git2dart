# ADR-001: Separate Native Binaries and Generated Declarations

## Status

Accepted (retrospective).

## Context

The Dart package needs reproducible libgit2 binaries on Windows, Linux, macOS, Android, and iOS without vendoring/building libgit2 in the high-level package.

## Decision

Use the companion `git2dart_binaries` package for prebuilt native libraries and generated FFI declarations. Keep idiomatic wrappers and hand-written binding adapters in `git2dart`. Constrain the companion package to an explicitly compatible minor range and compare public declarations before upgrades.

Evidence: repository architecture, `pubspec.yaml`, version update history, and `a725bac` API comparison tooling. 🟢 CONFIRMED.

## Alternatives considered

- Vendor and compile libgit2 source in this repository.
- Generate declarations during each consumer build.
- Use system-installed libgit2 exclusively.

## Consequences

- Smaller, clearer high-level repository and reproducible artifacts.
- Native ABI/declaration upgrades become an explicit dependency migration concern.
- Platform packaging failures can occur outside the source wrapper code.

