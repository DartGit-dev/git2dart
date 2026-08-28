# Native Runtime and Platform Boundary Requirements

> 🟢 **CONFIRMED** — This unit specifies generated/native dependency separation, libgit2 initialization/options, FFI marshalling, error translation, callbacks, ownership, and Android/iOS bootstrap.

## Responsibilities and Rules

- 🟢 **CONFIRMED** — Keep generated declarations/native binaries in `git2dart_binaries` and hand-written adapters in this package.
- 🟢 **CONFIRMED** — Marshal Dart strings/enums/flags/collections/pointers/callbacks to C-compatible values.
- 🟢 **CONFIRMED** — Translate negative native results immediately from `git_error_last()`.
- 🟢 **CONFIRMED** — Use arenas for call-scoped allocations and finalizer plus explicit free for owned persistent handles.
- 🟢 **CONFIRMED** — Initialize Android CA material and iOS static symbols before platform use.
- 🟢 **CONFIRMED** — Expose typed process-global libgit2 options and runtime version/features/memory values.

| ID | Rule | Confidence |
| --- | --- | --- |
| BR-NP-01 | No raw pointer is exported through the public package barrel; internal pointer access is package-scoped. | 🟢 CONFIRMED |
| BR-NP-02 | Arena strings are UTF-8 and null-terminated. | 🟢 CONFIRMED |
| BR-NP-03 | Negative native return values throw `LibGit2Error` using current native error state. | 🟢 CONFIRMED |
| BR-NP-04 | Manual release detaches finalizer; borrowed callback data is never finalized as owned. | 🟢 CONFIRMED |
| BR-NP-05 | SSL certificate locations require at least file or path. | 🟢 CONFIRMED |
| BR-NP-06 | Pack maximum object size cannot be negative. | 🟢 CONFIRMED |
| BR-NP-07 | Android startup installs a CA certificate file; iOS startup eagerly resolves static symbols. | 🟢 CONFIRMED |
| BR-NP-08 | Process-global options can affect unrelated operations in the same process. | 🟢 CONFIRMED |
| BR-NP-09 | Generated declaration/API upgrades require explicit comparison and compatible native artifacts. | 🟢 CONFIRMED |

## Functional Requirements

| ID | Requirement | Priority | Acceptance summary | Confidence |
| --- | --- | --- | --- | --- |
| FR-NP-01 | Load and initialize/shutdown libgit2 and expose version/features. | Must | Runtime calls resolve on each platform and counters/results are typed. | 🟢 CONFIRMED |
| FR-NP-02 | Provide platform initialization for Android and iOS. | Must | Android sets CA file; iOS resolves static libgit2 symbols. | 🟢 CONFIRMED |
| FR-NP-03 | Marshal UTF-8 strings, nullable values, arrays, enums, flags, structs, and callbacks. | Must | Native receives exact C representation and temporary memory is released. | 🟢 CONFIRMED |
| FR-NP-04 | Translate native errors consistently and expose package-local validation errors distinctly. | Must | Negative result becomes detailed `LibGit2Error`; local invalid args remain Dart errors. | 🟢 CONFIRMED |
| FR-NP-05 | Manage owned/borrowed/transferred native resource lifetimes. | Must | Exactly one owner/destructor path exists and borrowed views remain bounded. | 🟢 CONFIRMED |
| FR-NP-06 | Expose typed libgit2 global configuration for search paths, SSL, cache/mmap, safety, extensions, owner validation, and pack limits. | Should | Valid values round-trip/apply; invalid values fail explicitly. | 🟢 CONFIRMED |
| FR-NP-07 | Expose cached-memory usage and runtime options without leaking raw native structs. | Should | Typed values match native state. | 🟢 CONFIRMED |
| FR-NP-08 | Preserve callback direction, return codes, exceptions/errors, and borrowed lifetime across FFI. | Must | Native operation observes caller decisions/data safely. | 🟢 CONFIRMED |
| FR-NP-09 | Maintain generated-declaration/native ABI compatibility across five platforms. | Must | API comparison and platform tests gate upgrades. | 🟢 CONFIRMED |

## Non-Functional Requirements

| Type | Requirement | Confidence |
| --- | --- | --- |
| Memory safety | No leak, double free, use-after-free, or borrowed-as-owned conversion is acceptable. | 🟢 CONFIRMED goal; 🔴 GAP exhaustive proof |
| ABI safety | Generated declarations and packaged binaries remain version-compatible. | 🟢 CONFIRMED |
| Portability | Android, iOS, Linux, macOS, Windows loading/calling behavior remains supported. | 🟢 CONFIRMED |
| Security | CA/trust, strict validation, owner validation, and pack size settings fail closed by default/current policy. | 🟢 CONFIRMED |
| Concurrency | Global options/static callbacks require serialization unless proven safe. | 🔴 GAP |

## Acceptance Criteria

🟢 **CONFIRMED**

```gherkin
Dado a negative libgit2 result with current native error state
Quando the binding checks the result
Então LibGit2Error is thrown with native diagnostic information before another native call replaces it
```

🟢 **CONFIRMED**

```gherkin
Dado an Android application startup
Quando PlatformSpecific.initialize runs
Então libgit2 is loaded, a CA file is prepared, and its path is configured before TLS Git use
```

🟢 **CONFIRMED**

```gherkin
Dado an owned native wrapper manually released
Quando free completes
Então the matching destructor runs and the finalizer is detached
```

## Traceability

| Legacy area | Coverage | Confidence |
| --- | --- | --- |
| `lib/src/libgit2.dart`, `platform_specific.dart`, `error.dart`, `git_types.dart`, `extensions.dart`, `helpers/error_helper.dart` | runtime/options/platform/shared conversion | 🟢 CONFIRMED |
| `lib/src/bindings/` | all raw calls, allocation, callback and conversion paths | 🟢 CONFIRMED |
| `git2dart_binaries` dependency/API comparison | generated ABI/native packaging boundary | 🟢 CONFIRMED |

