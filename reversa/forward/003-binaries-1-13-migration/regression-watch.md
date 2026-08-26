# Regression Watch: Companion Binaries 1.13 Migration

> Feature: `003-binaries-1-13-migration`

| ID | Origin (file, section) | Expected rule after change | Verification type | Violation signal |
|---|---|---|---|---|
| W001 | `reversa/sdd/architecture.md`, Companion native package | The package resolves hosted `git2dart_binaries` 1.13.x without regenerated declarations, changed binaries, or an override. | presence | A future extraction finds a path override, vendored declarations, binary edits, or a non-1.13 resolution. |
| W002 | `reversa/sdd/architecture.md`, Native runtime and platform boundary | The four affected `size_t` option outputs use `Pointer<Size>` and cached-memory current/allowed use `Pointer<IntPtr>` before returning Dart integers. | redação | A future extraction finds fixed-width pointers or a swapped `Size`/`IntPtr` group. |
| W003 | `reversa/sdd/domain.md`, Memory and ABI safety | Negative native results propagate the delivered native error; missing native detail produces the authorized deterministic `StateError` fallback. | redação | A future extraction finds direct construction of the removed error type or no deterministic missing-error path. |

## Re-extraction history

_No re-extraction has been run for this feature._

## Archived

_None._

## Observations

- Cross-platform CI proof for Linux, macOS, Windows, Android, and iOS remains outside the completed local gate. T015–T020 must remain pending until green workflow evidence exists.
