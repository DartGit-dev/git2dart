# Legacy Impact: 005-binaries-1-14-release-0-5-6

> Date: 2026-09-04
> Context anchor: legacy (`reversa/sdd/architecture.md` and `reversa/sdd/domain.md`)
> Execution status: partial; stopped at failed T010 local release gate.

| Affected file | Component | Type | Severity | Rationale |
|---|---|---|---|---|
| `pubspec.yaml` | Native runtime and platform boundary | `delta-de-contrato-externo` | MEDIUM | Raises the hosted companion range to 1.14.x and package version to 0.5.6 without changing the Dart facade. |
| `pubspec.lock` | Platform runtime | `delta-de-contrato-externo` | MEDIUM | Resolves the host dependency to companion 1.14.0, whose bundled libgit2 reports 1.9.7 on this host. |
| `test/libgit2_test.dart` | Native runtime and platform boundary | `regra-alterada` | LOW | Updates the verified bundled libgit2 version assertion from 1.9.6 to 1.9.7. |
| `reversa/forward/005-binaries-1-14-release-0-5-6/release-evidence.md` | Release validation evidence | `regra-nova` | LOW | Adds host-scoped candidate evidence and explicit unproven boundaries. |

## Conceptual delta

The public `PlatformSpecific` facade remains exported and its three initialization methods remain callable. The product delta is the external companion dependency contract, with one evidence-backed test expectation updated for bundled libgit2 1.9.7. The Windows x64 local suite passes after that correction.

## Preserved

No confirmed green legacy domain rule was modified or removed. Native ownership, error translation, and the no-raw-pointer public boundary were not edited.

## Modified

No confirmed green legacy domain rule was modified or removed. The external companion constraint is updated and the local-gate assertion now matches the resolved runtime.
