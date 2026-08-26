# Legacy impact: 003-binaries-1-13-migration

Date: 2026-08-26

| Affected file | Component | Type | Severity | Rationale |
|---|---|---|---|---|
| `lib/src/libgit2.dart` | Native runtime and platform boundary | regra-alterada | HIGH | Global-option outputs now use the delivered 1.13 runtime surfaces with arena-managed `Size` and `IntPtr` pointers. |
| `test/libgit2_test.dart` | Native runtime and platform boundary | regra-nova | MEDIUM | Covers native-width option groups, restoration of process-global values, and the 64-bit round-trip. |

## Conceptual diff by component

The native runtime boundary remains a hand-written adapter over declarations
delivered by `git2dart_binaries`. Temporary global-option output pointers now
have arena lifetime on both success and error paths. The public `int` API is
unchanged. The four size-valued option getters retain `Size`; cached-memory
outputs retain `IntPtr`.

## Preserved

- 🟢 The public façade keeps raw pointers below `lib/src/bindings/`.
- 🟢 Negative native result codes continue through the centralized error
  translation boundary.
- 🟢 Android certificate setup and iOS eager native-symbol loading remain
  explicit platform initialization responsibilities.
- 🟢 Process-global libgit2 options have no overlapping-operation safety
  contract.

## Modified

- 🟢 Temporary option-output allocation now guarantees release through an
  arena on failing native calls as well as successful calls.
- 🟢 The adopted hosted 1.13 runtime boundary is exercised through its
  `bindings` and `options` surfaces without changing the public Dart API.
