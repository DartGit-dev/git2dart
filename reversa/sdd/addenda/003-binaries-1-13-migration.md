# Addendum: Companion Binaries 1.13 Migration

Feature ID: `003`

Date: 2026-08-26

Scenario: legacy

## Vigência

Vigente desde 2026-08-26.

## Resumo da entrega

This feature aligns the hand-written runtime boundary with the hosted `git2dart_binaries` 1.13.0 contract while preserving the public Dart API, scoped native allocation, and companion ownership of generated declarations and binaries. It records 20 of 27 planned actions as complete: the local migration, focused tests, local delivery gate, documentation search, and generated API documentation are complete; supported-platform GitHub Actions proof and final CI/baseline reconciliation remain incomplete.

## Impacto por artefato da extração

| Artefato | Seção | Tipo de impacto | Delta |
| --- | --- | --- | --- |
| `reversa/sdd/architecture.md` | [Companion native package](../architecture.md#companion-native-package) | delta-de-contrato-externo | Read the companion dependency as the adopted hosted `1.13.0` contract, with generated declarations and binaries still supplied exclusively by `git2dart_binaries`; no override or regeneration was introduced. |
| `reversa/sdd/architecture.md` | [Native binding adapters](../architecture.md#native-binding-adapters) | regra-alterada | Read affected global-option adapters as using `Pointer<Size>` for four `size_t` outputs and `Pointer<IntPtr>` for cached-memory outputs, preserving public `int` APIs and scoped cleanup. |
| `reversa/sdd/domain.md` | [Memory and ABI safety](../domain.md#memory-and-abi-safety) | regra-alterada | Read negative native results as propagating delivered error detail when available and otherwise throwing the authorized deterministic `StateError`; obsolete companion-error construction is no longer part of the contract. |
| `reversa/sdd/architecture.md` | [Quality and Delivery Architecture](../architecture.md#quality-and-delivery-architecture) | regra-nova | Local focused and full delivery evidence covers the migration boundary, but hosted CI proof for Linux, macOS, Windows, Android, and iOS is explicitly pending and cannot be substituted by local Windows evidence. |

## Entrega parcial e limites de prova

T015–T021 remain open. No GitHub Actions evidence yet proves the hosted 1.13.0 migration on Linux, macOS, Windows, Android, or iOS; consequently CI reconciliation and final API-diff baseline confirmation are also pending. This addendum records the confirmed local implementation only and does not claim cross-platform runtime, binary-packaging, or final re-extraction proof.

## Regras sob vigilância

- [W001](../../forward/003-binaries-1-13-migration/regression-watch.md#w001)
- [W002](../../forward/003-binaries-1-13-migration/regression-watch.md#w002)
- [W003](../../forward/003-binaries-1-13-migration/regression-watch.md#w003)

## Fontes

- `reversa/forward/003-binaries-1-13-migration/legacy-impact.md`
- `reversa/forward/003-binaries-1-13-migration/regression-watch.md`
- `reversa/forward/003-binaries-1-13-migration/requirements.md`
- `reversa/forward/003-binaries-1-13-migration/progress.jsonl`
- `reversa/forward/003-binaries-1-13-migration/actions.md`
- `reversa/sdd/architecture.md`
- `reversa/sdd/domain.md`
