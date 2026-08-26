# Roadmap: Companion Binaries 1.13 Migration

> Identifier: `003-binaries-1-13-migration`
> Date: `2026-08-26`
> Requirements: `reversa/forward/003-binaries-1-13-migration/requirements.md`
> Confidence: 🟢 CONFIRMED, 🟡 INFERRED, 🔴 GAP

## 1. Approach summary

Adopt the already-present hosted 1.13.0 resolution and baseline as pre-existing
migration work. Conform all hand-written consumers to the delivered runtime
surface without changing public Dart APIs. Use `Pointer<Size>` only for mmap
window size, mmap mapped limit, mmap file limit, and pack maximum objects; keep
both cached-memory outputs as `Pointer<IntPtr>`. Migrate every obsolete direct
error construction to the delivered-error/authorized-`StateError` contract.
Full Linux, macOS, Windows, Android, and iOS CI is mandatory completion proof.

## 2. Applied principles

| Principle | Feature relationship | Status |
|-----------|----------------------|--------|
| I. Preserve the Safe Public Dart Facade | Preserves public `int` getter/setter call forms, signatures, and intended consumer behavior while changing only the native boundary. | respects 🟢 |
| II. Keep Generated Artifacts in the Companion Boundary | Consumes the adopted hosted 1.13.0 declarations and binaries; it neither regenerates nor vendors them. | respects 🟢 |
| III. Preserve Native ABI and Memory Ownership Safety | Maps each native-width output according to the delivered declaration and keeps temporary allocation cleanup scoped to the call. | respects 🟢 |
| IV. Translate Native Failures at One Boundary | Uses delivered native error detail when present and the authorized `StateError` fallback when it is absent; it rejects duplicate reconstruction paths. | respects 🟢 |
| V. Keep Supported Platform Initialization Explicit | Retains Android certificate setup and iOS eager native-symbol loading as supported startup paths. | respects 🟢 |
| VI. Make Validation Evidence Match Its Scope | Separates local gates, platform CI, declaration evidence, and the explicit absence of a concurrency guarantee. | respects 🟢 |

## 3. Technical decisions

| ID | Decision | Justification | Alternatives discarded | Confidence |
|----|----------|---------------|------------------------|------------|
| D-01 | Adopt the existing hosted 1.13.0 resolution and baseline; do not claim an unavailable 1.12.2 comparison. | The baseline is approved pre-existing migration input. | Regeneration, vendoring, or invented comparison history. | 🟢 |
| D-02 | Replace removed package-level `bindings` and `options` access with the delivered runtime object's `bindings` and `options` members. | Requirements define this runtime access surface; its internal implementation shape remains local to the adapters. | Recreating removed globals or retaining package-level access. | 🟢 |
| D-03 | Map the four delivered `size_t` outputs through `Pointer<Size>` and cached-memory current/allowed through `Pointer<IntPtr>`, then return Dart `int` values. | The declarations distinguish `size_t` from `intptr_t`; call-scoped allocation and cleanup remain mandatory. | Blanket `Size` conversion or fixed-width output pointers. | 🟢 |
| D-04 | Make a 64-bit, representable `4_294_967_296` round-trip an explicit conditional validation case for every affected option that accepts it. | FR-03 requires direct evidence against 32-bit truncation without claiming unsupported-option behavior. | Treating ordinary small values as ABI-width proof. | 🟢 |
| D-05 | Route every feature-owned obsolete error construction through delivered error retrieval, with an explanatory `StateError` fallback only when native detail is absent. | BR-03 and Principle IV define one observable negative-result contract. | Reconstructing the removed companion error or silently swallowing missing detail. | 🟢 |
| D-06 | Update only matched consumer-facing public comments, `doc/types/`, README, and API-reference wording; validate with the exact `dart doc` command. | FR-06 corrects obsolete promises without widening into a native-error documentation rewrite. | Unscoped documentation cleanup or an unspecified equivalent command. | 🟢 |
| D-07 | Preserve Android certificate setup and iOS eager native-symbol loading, then require the full supported CI matrix as completion evidence. | Platform startup remains explicit and local Windows is insufficient proof. | Optional mobile CI or local-platform substitution. | 🟢 |
| D-08 | Preserve the explicit scope boundary: this feature adds no synchronization guarantee for process-global options, and tests restore altered values. | Existing extraction leaves overlapping global-operation safety unproven. | Representing set/read/reset tests as concurrent-safety proof. | 🟡 |

## 4. Assumptions

None. No `[DÚVIDA]` remains.

## 5. Architectural delta

| Component | Legacy source | Change type | Summary |
|-----------|---------------|-------------|---------|
| Native runtime and platform boundary | `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary` | changed rule | Use the delivered runtime object's access surface; preserve native width, shared error translation, explicit startup, and call-scoped cleanup. |
| Companion native package | `reversa/sdd/architecture.md#Companion native package` | adopted state | Existing 1.13.0 input; no regeneration. |
| Public package facade | `reversa/sdd/architecture.md#Public package facade` | unchanged | Dart API, ownership, and public call forms stay stable. |

## 6. Data-model delta

No durable Git data change. Native-width outputs are transient adapter values:
four `size_t` groups use `Size`, while cached-memory current/allowed use
`IntPtr`. The feature adds no process-global option concurrency contract.
Detail: `data-delta.md`.

## 7. External-contract delta

No external HTTP, queue, gRPC, GraphQL, or file contract; omit `interfaces/`.

## 8. Minimal implementation and validation plan

| File | Delta | Verification |
|------|-------|--------------|
| `lib/src/libgit2.dart` | Reach native options through the delivered runtime object; preserve four `Size` and two cached-memory `IntPtr` groups and clean up outputs on every path. | Set/read/reset tests, including a conditional 64-bit `2^32` round-trip where accepted. |
| `lib/src/helpers/error_helper.dart`, `lib/src/bindings/commit.dart`, `diff.dart`, `remote_callbacks.dart` | Remove feature-owned obsolete direct construction, including both callback paths, in favor of delivered error detail or explanatory `StateError`. | Symbol search plus native-detail-present and native-detail-absent tests. |
| `lib/src/platform_specific.dart` | Preserve Android certificates and iOS symbol loading. | Host smoke plus mobile CI. |
| `test/libgit2_test.dart`, `test/libgit2_option_error_test.dart`, `test/platform_specific_test.dart` | Cover exact ABI groups, fallback, startup. | Focused tests, formatter, analyzer, full suite. |
| Affected public `lib/**/*.dart` docs, `doc/types/**/*.md`, `README.md`/API reference when matched | Replace only obsolete constructor/error-contract wording with the delivered-error plus `StateError` fallback behavior. | Scoped search over these roots returns no obsolete contract wording; `dart doc` succeeds. |

## 9. Migration plan

1. Inventory removed package-level access and obsolete error construction; preserve adopted dependency artifacts.
2. Adapt native calls through the delivered runtime object and repair ABI groups with call-scoped cleanup.
3. Exercise native-width behavior, including the conditional 64-bit `2^32` boundary, while restoring all altered process-global options.
4. Migrate each feature-owned error path together, preserving delivered detail and the authorized missing-detail fallback.
5. Update only matched consumer documentation, run the scoped search, and run `dart doc`.
6. Run local gates, then mandatory Linux, macOS, Windows, Android, and iOS CI; do not claim concurrent global-option safety.

## 10. Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Cached-memory becomes `Size` | high | Keep both outputs `IntPtr`. |
| Obsolete construction remains | high | One owned action covers all four files/both callbacks. |
| Adopted baseline misrepresented | high | Do not claim unavailable comparison history. |
| Consumer docs retain obsolete error wording | medium | Restrict search/fix to public Dart docs, `doc/types/`, and README/API reference matches; build documentation. |
| Local test replaces CI | high | Require all supported CI platforms. |
| A 64-bit result is truncated by a fixed-width output pointer | high | Exercise the conditional `2^32` round-trip where the native option accepts it. |
| Global-option tests imply a concurrency guarantee | medium | Restore state in every test and state the no-synchronization scope boundary. |

## 11. Definition of done

- [ ] Existing 1.13.0 artifacts are validated without regeneration or unavailable-comparison claims.
- [ ] Four `Size` groups and two `IntPtr` cached-memory outputs are correct and safely released.
- [ ] The delivered runtime object's `bindings` and `options` access surface replaces removed package-level access without changing public APIs.
- [ ] On applicable 64-bit option paths, `4_294_967_296` round-trips unchanged; tests do not claim concurrent global-option safety.
- [ ] All obsolete error construction sites are migrated and covered.
- [ ] Affected public Dart comments and matched README/API-reference documentation no longer promise the obsolete error type; scoped search and `dart doc` are green.
- [ ] Full supported-platform CI is green after local format, analysis, and tests.

## 12. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-26 | Revised after clarification and audit A001-A006 | reversa |
| 2026-08-26 | Refreshed after final requirements quality: runtime access surface, 64-bit boundary, concurrency scope, principles, terminology, and exact `dart doc` validation. | reversa |
