# Native Runtime and Platform Boundary — Test Specification

> 🟢 **CONFIRMED** — This test surface validates the safety substrate beneath every feature, so focused success is necessary but not sufficient without full platform execution.

## Coverage Matrix

| Area | Positive | Negative/characterization | Confidence |
| --- | --- | --- | --- |
| Runtime | init/shutdown/version/features | missing library, wrong ABI/architecture | 🟢 CONFIRMED / 🔴 GAP failure matrix |
| Marshal | Unicode/null/arrays/enums/flags/structs | invalid values, mid-call error cleanup | 🟢 CONFIRMED / 🔴 GAP exhaustive |
| Errors | negative result/native detail | null error state, operation-specific non-negative status | 🟢 CONFIRMED / 🔴 GAP null case |
| Ownership | explicit/finalizer/transfer/borrow | repeated/post-free, parent lifetime, injected failure | 🔴 GAP exhaustive proof |
| Android | load + CA file + SSL path | helper failure, repeated/concurrent init | 🟢 CONFIRMED CI intent / 🔴 GAP fresh |
| iOS | static symbol load/init | missing symbol, repeated/concurrent init | 🟢 CONFIRMED CI intent / 🔴 GAP fresh |
| Global options | set/get/invalid values | overlap/race/restore | 🟢 CONFIRMED / 🔴 GAP concurrency |
| Callbacks | typed values/results | exception/overlap/borrow escape | 🔴 GAP dynamic characterization |

## Acceptance Scenarios

🟢 **CONFIRMED**

```gherkin
Dado a Unicode Dart string passed to a native adapter
Quando it is marshalled within an Arena
Então libgit2 receives UTF-8 null-terminated bytes and temporary memory is released
```

🟢 **CONFIRMED**

```gherkin
Dado a negative native result with diagnostic state
Quando checkErrorAndThrow runs
Então LibGit2Error preserves the native diagnostic and no success value is returned
```

🔴 **GAP**

```gherkin
Dado two overlapping operations with distinct callbacks and global options
Quando native callbacks interleave
Então isolation or an explicit serialized-use restriction is demonstrated
```

## Required Dynamic Evidence

- 🔴 **GAP** — Dependency declaration diff and ABI/load smoke tests for every platform artifact.
- 🔴 **GAP** — Native sanitizer/leak/double-free instrumentation with injected failures.
- 🔴 **GAP** — Callback exception/overlap and borrowed lifetime tests.
- 🔴 **GAP** — Global option race/snapshot/restore tests.
- 🔴 **GAP** — Repeated platform initialize and wrapper free/post-free tests.

## Gate

- 🟢 **CONFIRMED** — Formatting and zero-warning analysis are required.
- 🟢 **CONFIRMED** — Full Flutter tests on Android, iOS, Linux, macOS, and Windows are the declared platform gate.
- 🟢 **CONFIRMED** — `git2dart_binaries` upgrades require the API comparison workflow.
- 🔴 **GAP** — No fresh runtime/sanitizer/platform execution occurred during Writer generation.

