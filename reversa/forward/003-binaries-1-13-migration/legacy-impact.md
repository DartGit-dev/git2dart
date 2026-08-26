# Legacy Impact: Companion Binaries 1.13 Migration

> Feature: `003-binaries-1-13-migration`
> Date: 2026-08-26
> Context anchor: `reversa/sdd/architecture.md` and `reversa/sdd/domain.md`

| Affected file | Component | Type | Severity | Rationale |
|---|---|---|---|---|
| `pubspec.yaml`, `pubspec.lock`, `tool/api_diff/git2dart_binaries.baseline` | Companion native package | `delta-de-contrato-externo` | HIGH | The already-adopted hosted 1.13.0 contract replaces the legacy 1.12.x constraint without regenerating declarations or changing binaries. |
| `lib/src/libgit2.dart` | Native runtime and platform boundary | `regra-alterada` | HIGH | Four `size_t` outputs use `Size`; cached-memory outputs use `IntPtr`, while public `int` APIs and scoped allocation remain intact. |
| `lib/src/helpers/error_helper.dart`, `lib/src/bindings/commit.dart`, `lib/src/bindings/diff.dart`, `lib/src/bindings/remote_callbacks.dart` | Native runtime and platform boundary | `regra-alterada` | HIGH | Error translation now uses the delivered last-error value, with a deterministic `StateError` when the native library provides no detail. |
| `test/libgit2_test.dart`, `test/libgit2_option_error_test.dart`, `test/platform_specific_test.dart` | Quality and delivery architecture | `regra-nova` | MEDIUM | Tests now explicitly protect ABI-width allocation, the two error branches, and Android/iOS startup paths on safe host execution. |

## Conceptual delta by component

The companion package remains the owner of generated declarations and platform binaries. This feature consumes its hosted 1.13.0 runtime boundary only. The hand-written adapters preserve the public Dart API while converting native-width option values through the correct pointer types and preserving scoped allocation cleanup.

Native failure handling no longer attempts to reconstruct the removed companion-package error constructor. It propagates the delivered native error when available and otherwise fails deterministically with `StateError`. Android certificate initialization and iOS eager symbol loading remain available through the existing public initialization methods.

## Preserved

- 🟢 `domain.md` rule 20: short-lived native inputs/outputs use an arena; persistent wrappers retain explicit release and finalizer protection.
- 🟢 `domain.md` rule 17: Android certificate initialization and iOS platform initialization remain required for their consumers.
- 🟢 `architecture.md`: raw pointers and generated declarations remain below the public facade; native failures are translated at the binding boundary.

## Modified

- 🟢 `architecture.md`: the legacy constrained `1.12.x` companion-package line is superseded by the already-adopted hosted `1.13.0` resolution.
- 🟢 `architecture.md`: native-width output allocation now follows the delivered 1.13 signatures for the affected global options.
- 🟢 `architecture.md`: error translation changes from constructing the former companion error type to delivered-error propagation plus the authorized `StateError` fallback.
