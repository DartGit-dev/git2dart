# External Contract: `git2dart_binaries` 1.14.0

## Contract type

Hosted Dart package dependency delivering generated FFI declarations, platform
native artifacts, and Android SSL support. This is not an HTTP, queue, gRPC, or
GraphQL contract.

## Version request and response

| Direction | Contract |
|-----------|----------|
| Request from `git2dart` | `pubspec.yaml` declares `git2dart_binaries >=1.14.0 <1.15.0`; dependency resolution requests a compatible hosted release. |
| Required resolved response | `pubspec.lock` records version 1.14.0 with its hosted integrity metadata. |
| Consumer-facing response | `git2dart` 0.5.6 retains its public Dart declarations; the completed 1.13.0-to-1.14.0 declaration comparison reports no public declaration change. |

## Error and compatibility handling

- Dependency-resolution failure, unavailable package contents, compilation
  mismatch, or runtime initialization failure blocks release readiness until
  investigated with target-specific evidence.
- A declaration comparison with no public Dart change does not establish ABI,
  binary packaging/provenance, memory ownership, platform runtime, or behavior
  equivalence.
- Generated declarations and binaries remain owned by the companion package;
  this repository must not copy or regenerate them to mask a mismatch.

## Idempotence and timeouts

- Repeating dependency resolution is idempotent with respect to the declared
  range, subject to hosted registry availability and lock-file state.
- No application-level request timeout exists at this package contract. Network
  timeouts are controlled by the package manager/CI environment and must be
  recorded if they affect validation.

## Validation obligations

1. Verify the resolved lock-file version.
2. Preserve the declaration-comparison result as scoped public API evidence.
3. Compile, analyze, and test the hand-written adapters against the resolved package.
4. Validate Android/iOS initialization and hosted target results only where observed.
5. Do not infer publication or live HTTPS/SSH behavior from dependency resolution or standard offline tests.
