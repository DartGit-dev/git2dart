---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
mode: repair
solvers: 3
epochs: 2
external_participants: forbidden
visibility: restricted
status: active
created_at: 2026-08-21T03:00:00+07:00
---

# Frozen Repair Problem

## Execution Contract

- Three local solvers, two total solver epochs: independent round 0 and one
  synchronous revision round.
- One isolated local judge after round 1.
- Seven agent calls in total.
- External harnesses and disclosure outside this bug folder are prohibited.
- The debate may propose a repair and tests but must not edit source, tests, or
  effective specifications.

## Problem

`BUG-20260817-O3B3` is a high-severity restricted defect. The root cause is
confirmed: remote callback state cleanup is sequenced only on normal completion
instead of being guaranteed for every exit. A controlled local failure using
synthetic values reproduced retained callback state in three of three isolated
runs. The separate process-static callback concurrency defect is out of scope.

The repair must guarantee deterministic cleanup for every callback-bearing
operation while preserving immediate native-error translation and avoiding any
expansion into the separately registered concurrency problem.

## Relevant Repair Surface

- `lib/src/bindings/remote_callbacks.dart`: callback state installation and reset.
- `lib/src/bindings/remote.dart`: connect, fetch, and push call sites.
- `lib/src/bindings/repository.dart`: repository clone call site.
- `lib/src/bindings/submodule.dart`: update and clone call sites.
- `test/remote_test.dart`, `test/repository_test.dart`, and
  `test/submodule_test.dart`: candidate regression coverage.

## Evidence

- `../bug.md`
- `../evidence/reproduction.md`
- `../evidence/restricted-reproduction-test.dart`
- `../evidence/restricted-static-analysis.md`
- `../evidence/root-cause.md`

## Effective Specification

- `FR-NP-03`: temporary native memory is released.
- `FR-NP-05`: exactly one owner/destructor path exists.
- `FR-NP-08`: callback data and decisions cross FFI safely.
- `FL-NP-06`: temporary callback conversion state is released.
- `EC-NP-10`: manual temporaries require matching disposal after later failure.
- `EC-NP-14`: callback data must not escape its callback lifetime unless copied.
- `EC-NP-15`: callback-throw cleanup remains a characterization gap.
- `EC-NP-16` and static callback concurrency remain explicitly out of scope.
- ADR-003 prefers `using(Arena)` for call-scoped allocations and deterministic
  release for manually owned temporaries.

## Agent Notes and Constraints

- Use only synthetic examples; do not reproduce or expose secret-like values.
- No external harness receives this material.
- Keep the correction surgical; do not solve callback concurrency in this patch.
- Preserve the native error before any cleanup call can overwrite it.
- Cleanup must be idempotent or structurally impossible to invoke twice.

## Frozen Judge Rubric

The winning repair must:

1. Eliminate the confirmed root cause on success, native error, and Dart error.
2. Be the smallest coherent change across all affected call sites.
3. Minimize regression risk under the recorded high-risk classification.
4. Be reversible and avoid public API or ABI changes unless strictly necessary.
5. Adhere to the effective specification and restricted Agent Notes.
6. Provide a red-to-green test design that proves cleanup without real credentials.
