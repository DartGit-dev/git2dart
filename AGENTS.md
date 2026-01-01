## 1. Mission

Provide idiomatic, null-safe Dart bindings for **libgit2** that feel like native Dart code while preserving C-level performance and memory safety.

## 2. Audience

* Contributors writing FFI glue or high-level Dart wrappers
* CI agents ensuring formatting, static analysis, and testing
* Release automation tooling publishing versions to *pub.dev*

## 3. Repository Layout

| Path                 | Purpose                                                   | Visibility |
| -------------------- | --------------------------------------------------------- | ---------- |
| `lib/`               | Public API exposed to end users                           | ✅ Public   |
| `lib/src/`           | Internal implementation classes and helpers               | ✅ Public   |
| `lib/src/bindings/`  | Auto-generated & hand-tuned FFI bindings (memory-managed) | 🔒 Private  |
| `test/`              | Unit & integration tests                                  | 🔒 Private  |
| `scripts/`           | build scripts                                             | 🔒 Private  |
| `git2dart_binaries/` | Pre-built **libgit2** binaries + generated Dart stubs     | —           |

## 4. Quick Start

```bash
# Install dependencies
flutter pub get

# Format, analyze, and test
dart format . --set-exit-if-changed
flutter analyze
flutter test
```

If you need to install Flutter, use script `scripts/install_flutter.sh`.

**Note**: FFI bindings are provided by the `git2dart_binaries` package and do not need to be regenerated in this repository.

All targets **must** pass on Linux, macOS, Windows, and Android using Dart 3.7.2+ and Flutter stable (3.29.3+).

## 5. Coding Conventions

* Follow *Effective Dart* for style and naming.
* Always run `dart format .` before committing.
* `flutter analyze` must report **zero** warnings.
* Document public symbols with `///` comments.
* Throw specific `GitError` subclasses. Avoid returning `null` unless explicitly required.
* **All code, comments, commit messages, and git artifacts must be in English.**

## 6. Testing Policy

1. Tests live in `test/` and mirror the public API hierarchy.
2. Each new public API element **must** include:

   * at least one positive test;
   * at least one negative test.
3. Performance-critical code should include micro-benchmarks in `test/benchmarks/`.
4. Use the in-memory repository helper (`helpers/util.dart`) to avoid unnecessary I/O.

## 7. Release Procedure (Agents Only)

1. Bump version in `pubspec.yaml` (Semantic Versioning).
2. Update `CHANGELOG.md`.
3. Tag the commit `vx.y.z`.
4. Ensure `dart pub publish --dry-run` succeeds locally and in CI.
5. Create GitHub release with `gh release create vx.y.z` (binaries are handled by CI workflow).

## 8. Common Pitfalls

* **Never** commit generated `*.g.dart` files; regenerate with:
  `dart run build_runner build --delete-conflicting-outputs`
* Do not vendor full libgit2 source; use submodules or binary archives.
* On Windows, ensure `libgit2.dll` is copied to `bin/` for tests to pass.
* All code, documentation, commit messages, branch names, and git artifacts must be in English.

## 9. Agent Checklist (Each Commit)

* [ ] Code formatted with `dart format .`
* [ ] `flutter analyze` reports zero warnings
* [ ] All tests pass (`flutter test`)
* [ ] Public API changes include documentation
* [ ] Commit message follows Conventional Commits format
* [ ] All code, comments, and commit messages are in English

## 10. Architecture

### 10.1 `git2dart_binaries`

Companion package with:

* Pre-built **libgit2** binaries for Windows, Linux, macOS
* `ffigen` config
* Generated Dart headers and auto-generated FFI code for the **libgit2** C API

Separating heavy artefacts ensures versioned, reproducible builds while letting the high-level API evolve.

### 10.2 `lib/src/bindings`

* Contains **bindings** to the auto-generated FFI code from `git2dart_binaries`
* Defines the Dart-level interface to C functions and structures
* Handles all interaction with native memory: allocations, pointer math, conversions
* All raw C calls and memory operations happen here
* No raw `Pointer` escapes; must be converted to safe Dart types

### 10.3 `lib/src`

* Implements idiomatic Dart API: `Repository`, `Commit`, `Oid`, etc.
* Delegates native work to `bindings`
* Hides FFI details from end users
* Contains helpers/mixins not part of public API

## 11. Language Requirements

**All artifacts in code and git must be in English:**

* Source code (variable names, function names, class names)
* Comments and documentation
* Commit messages
* Branch names
* Pull request titles and descriptions
* Issue titles and descriptions
* Code review comments

This ensures consistency, maintainability, and accessibility for the international developer community.

## 12. Contact Points

* Open issues or PRs on GitHub
* Prefix commits with Conventional Commit types (`feat:`, `fix:`, etc.)
* Breaking-change PRs require approval from a `@DartGit-dev/core` maintainer
