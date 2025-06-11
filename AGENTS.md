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
| `lib/src/`           | Internal implementation classes and helpers               |  Public    |
| `lib/src/bindings/`  | Auto-generated & hand-tuned FFI bindings (memory-managed) | 🔒 Private |
| `test/`              | Unit & integration tests                                  | ✅ Public   |
| `tool/`              | One-off scripts (code-gen, benchmarks, etc.)              | ✅ Public   |
| `git2dart_binaries/` | Pre-built **libgit2** binaries + generated Dart stubs     | —          |

## 4. Quick Start

```bash
# Install dependencies
dart pub get

# Generate FFI bindings (requires clang)
dart run ffigen

# Format, analyze, and test
dart format . --set-exit-if-changed
dart analyze
dart test
```

All targets **must** pass on Linux, macOS & Windows using Dart 3.7+ and Flutter stable.

## 5. Coding Conventions

* Follow *Effective Dart* for style and naming.
* Always run `dart format .` before committing.
* `dart analyze` must report **zero** warnings.
* Document public symbols with `///` comments.
* Throw specific `GitError` subclasses. Avoid returning `null` unless explicitly required.

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
5. Use `gh release create` to attach binaries from `tool/build_artefacts.dart`.

## 8. Common Pitfalls

* **Never** commit generated `*.g.dart` files; regenerate with:
  `dart run build_runner build --delete-conflicting-outputs`
* Do not vendor full libgit2 source; use submodules or binary archives.
* On Windows, ensure `libgit2.dll` is copied to `bin/` for tests to pass.

## 9. Agent Checklist (Each Commit)

*

## 10. Architecture

### 10.1 `git2dart_binaries`

Companion package with:

* Pre-built **libgit2** binaries for Windows, Linux, macOS
* `ffigen` config
* Generated Dart headers and auto-generated FFI code for the **libgit2** C API

Separating heavy artefacts ensures versioned, reproducible builds while letting the high-level API evolve. ensures versioned, reproducible builds while letting the high-level API evolve.

### 10.2 `lib/src/bindings`

* Contains **bindings** to the auto-generated FFI code from `git2dart_binaries`
* Defines the Dart-level interface to C functions and structures
* Handles all interaction with native memory: allocations, pointer math, conversions
* All raw C calls and memory operations happen here
* No raw `Pointer` escapes; must be converted to safe Dart typesContains **bindings** to the auto-generated FFI code from `git2dart_binaries`

### 10.3 `lib/src`

* Implements idiomatic Dart API: `Repository`, `Commit`, `Oid`, etc.
* Delegates native work to `bindings`
* Hides FFI details from end users
* Contains helpers/mixins not part of public API

## 11. Contact Points

* Open issues or PRs on GitHub
* Prefix commits with Conventional Commit types (`feat:`, `fix:`, etc.)
* Breaking-change PRs require approval from a `@DartGit-dev/core` maintainer
