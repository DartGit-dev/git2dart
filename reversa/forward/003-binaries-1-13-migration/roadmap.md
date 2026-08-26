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

`.reversa/principles.md` is absent; no project principle can be evaluated.

| Principle | Feature relationship | Status |
|-----------|----------------------|--------|
| Typed facade over native ABI (`reversa/sdd/architecture.md#Architectural Style`) | Keeps ABI changes below public APIs. | respects 🟢 |
| Error boundary (`reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`) | Owns all obsolete construction paths and explicit fallback. | changes-authorized 🟢 |

## 3. Technical decisions

| ID | Decision | Justification | Confidence |
|----|----------|---------------|------------|
| D-01 | Adopt existing 1.13.0 resolution/baseline; do not claim an unavailable 1.12.2 comparison. | Approved clarification resolves A004/A005. | 🟢 |
| D-02 | Use runtime bindings/options at all changed consumers. | Former global fields were removed. | 🟢 |
| D-03 | Split four `Size` groups from two cached-memory `IntPtr` outputs. | `size_t` and `intptr_t` declarations differ; resolves A001. | 🟢 |
| D-04 | Route helper, commit, diff, and both remote-callback paths through delivered error or authorized `StateError`. | Resolves A002/A003. | 🟢 |
| D-05 | Require full supported-platform CI. | FR-07 clarification resolves A006. | 🟢 |
| D-06 | Update only affected public Dart `///` comments and matching `doc/types/` or README/API-reference wording that promises the obsolete constructor. | FR-06 requires accurate consumer documentation without rewriting unrelated native-error documentation. | 🟢 |

## 4. Assumptions

None. No `[DÚVIDA]` remains.

## 5. Architectural delta

| Component | Legacy source | Change type | Summary |
|-----------|---------------|-------------|---------|
| Native runtime and platform boundary | `reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary` | changed rule | Exact ABI types and error fallback. |
| Companion native package | `reversa/sdd/architecture.md#Companion native package` | adopted state | Existing 1.13.0 input; no regeneration. |
| Public package facade | `reversa/sdd/architecture.md#Public package facade` | unchanged | Dart API/ownership stay stable. |

## 6. Data-model delta

No durable Git data change. Four transient `size_t` outputs use `Size`; two
cached-memory `intptr_t` outputs use `IntPtr`. Detail: `data-delta.md`.

## 7. External-contract delta

No external HTTP, queue, gRPC, GraphQL, or file contract; omit `interfaces/`.

## 8. Minimal implementation and validation plan

| File | Delta | Verification |
|------|-------|--------------|
| `lib/src/libgit2.dart` | Preserve four `Size` and two cached-memory `IntPtr` groups; clean up outputs on every path. | Global option set/read/reset tests. |
| `lib/src/helpers/error_helper.dart`, `lib/src/bindings/commit.dart`, `diff.dart`, `remote_callbacks.dart` | Remove all obsolete direct construction, including both callback paths. | Symbol search and negative-result tests. |
| `lib/src/platform_specific.dart` | Preserve Android certificates and iOS symbol loading. | Host smoke plus mobile CI. |
| `test/libgit2_test.dart`, `test/libgit2_option_error_test.dart`, `test/platform_specific_test.dart` | Cover exact ABI groups, fallback, startup. | Focused tests, formatter, analyzer, full suite. |
| Affected public `lib/**/*.dart` docs, `doc/types/**/*.md`, `README.md`/API reference when matched | Replace only obsolete constructor/error-contract wording with the delivered-error plus `StateError` fallback behavior. | Scoped `rg` over these documentation roots returns no obsolete contract wording; `dart doc` or an equivalent documentation check succeeds. |

## 9. Migration plan

1. Inventory obsolete consumers; preserve adopted dependency artifacts.
2. Repair ABI groups and cleanup.
3. Migrate every named error call site together.
4. Update matched public API comments and documentation references, then run the scoped documentation search and `dart doc` or equivalent check.
5. Run local gates, then mandatory full supported-platform CI.

## 10. Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Cached-memory becomes `Size` | high | Keep both outputs `IntPtr`. |
| Obsolete construction remains | high | One owned action covers all four files/both callbacks. |
| Adopted baseline misrepresented | high | Do not claim unavailable comparison history. |
| Consumer docs retain obsolete error wording | medium | Restrict search/fix to public Dart docs, `doc/types/`, and README/API reference matches; build documentation. |
| Local test replaces CI | high | Require all supported CI platforms. |

## 11. Definition of done

- [ ] Existing 1.13.0 artifacts are validated without regeneration or unavailable-comparison claims.
- [ ] Four `Size` groups and two `IntPtr` cached-memory outputs are correct and safely released.
- [ ] All obsolete error construction sites are migrated and covered.
- [ ] Affected public Dart comments and matched README/API-reference documentation no longer promise the obsolete error type; scoped search and `dart doc`/equivalent are green.
- [ ] Full supported-platform CI is green after local format, analysis, and tests.

## 12. Change history

| Date | Change | Author |
|------|--------|--------|
| 2026-08-26 | Revised after clarification and audit A001-A006 | reversa |
