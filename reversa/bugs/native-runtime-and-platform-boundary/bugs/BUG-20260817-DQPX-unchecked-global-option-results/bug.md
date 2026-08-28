---
schema_version: 1
id: BUG-20260817-DQPX
display_number: 2
title: Global libgit2 option APIs silently ignore native failures
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-27
origin:
  type: inspection
  external_ref: null
area: native-integration
module: native-runtime-and-platform-boundary
feature: native-runtime-and-platform-boundary
labels: [error-contract, global-options, silent-failure]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 isolated public-versus-raw native comparison"
  suspected_triggers: [invalid native option value, unsupported platform option]
blocking: []
relationships:
  - bug: BUG-20260817-QWMA
    type: related-to
    state: proposed
    evidence: []
traceability:
  specs:
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#business-rules"
    - "reversa/sdd/native-runtime-and-platform-boundary/flows.md#fl-np-05-set-a-global-option"
    - "reversa/sdd/adrs/004-centralize-native-error-translation.md#decision"
  affected_code:
    - "lib/src/libgit2.dart"
  root_cause:
    state: confirmed
    hypothesis: "Forty Libgit2 global-option wrappers discard the integer status returned by their fallible native call instead of passing it immediately to checkErrorAndThrow."
    causal_path:
      - "A public Libgit2 global-option wrapper invokes a typed git_libgit2_opts operation."
      - "The native operation returns a negative status and records diagnostic state for an invalid or unsupported option."
      - "The wrapper discards that status and continues returning normally or reading its output buffer."
      - "The caller therefore observes apparent success instead of the required LibGit2Error."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "Fresh scan found 40 unchecked global-option calls and only two checked calls in lib/src/libgit2.dart."}
      - {ref: "evidence/reproduction.md", observation: "The raw invalid cache-object limit call returned a negative status while the public wrapper returned normally with the same input."}
    code_refs:
      - {file: "lib/src/libgit2.dart", symbol: "Libgit2 global-option APIs", commit: "131f7c8f405fd818affd1bf4cc3fd60cd2b52f60"}
  reproduction_tests:
    - "evidence/reproduction_test.dart"
    - "test/libgit2_option_error_test.dart#reproduction: native option failures are exposed"
  regression_tests:
    - "test/libgit2_option_error_test.dart#reproduction: native option failures are exposed"
    - "test/libgit2_option_error_test.dart#regression: every global option call checks its status"
spec_verdict: spec-correta
change_risk:
  classification: medium
  reasons:
    - "The correction changes failure behavior across 40 public global-option wrappers."
    - "All changes are confined to one facade and reuse the existing checked pack-size pattern."
    - "Negative results must be checked before output interpretation or another native call can replace git_error_last state."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/libgit2_option_error_test.dart"
    purpose: "Prove native option failures are translated and prevent any global-option status from being discarded."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: source
    artifact: "lib/src/libgit2.dart"
    purpose: "Immediately translate every fallible global-option native status through checkErrorAndThrow."
    diff: "fix/CHG-002.proposed.diff"
  - id: CHG-003
    kind: test
    artifact: "test/libgit2_test.dart"
    purpose: "Express the platform-specific SSL backend failure that is now exposed instead of silently discarded."
    diff: "fix/CHG-003.diff"
closure:
  policy: package
  satisfied: false
delivery:
  branch: "0.5.5"
  commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: pending
versions:
  fixed_in: null
backports: []
resolution_kind: fixed
---

# Global libgit2 option APIs silently ignore native failures

## Summary

Most global option getters and setters discard the native return code, so an unsuccessful option operation can appear successful to the caller.

## Expected Behavior

BR-NP-03, FR-NP-04, FL-NP-05, and ADR-004 require immediate translation of negative native results.

## Actual Behavior

`lib/src/libgit2.dart` invokes global option functions without passing their results to `checkErrorAndThrow`. The pack maximum object size accessors are the notable checked exception.

## Steps to Reproduce

1. Run `evidence/reproduction_test.dart` with the Windows native binary root.
2. Observe that the raw invalid cache-object limit call returns a negative status.
3. Observe that the public wrapper returns normally for the same invalid input.

## Evidence

- `evidence/static-analysis.md`
- `evidence/reproduction.md`
- `evidence/reproduction_test.dart`
- `evidence/root-cause.md`
- `evidence/strategy.md`
- `fix/plan.html`
- `evidence/gate-1-approval.md`
- `evidence/gate-1-red.md`
- `evidence/gate-2-green.md`
- `evidence/spec-verdict.md`

## Suspected Area

Typed process-global option facade in `Libgit2`.

## Acceptance Criteria

- Every fallible global option call checks its native result immediately.
- Negative cases are covered without changing unrelated process-global state.
- Successful get and set behavior remains covered on supported platforms.

## Traceability

- Specs: BR-NP-03, FR-NP-04, FL-NP-05, ADR-004.
- Code: `lib/src/libgit2.dart`.

## Resolution

CHG-002 and supplemental CHG-003 were approved and applied. The current-head
audit confirms all global-option calls check their native status, the focused
suite passes 34 tests, and focused analysis reports no issues. The authorized
evidence-based verdict is `spec-correta`; package publication is not yet
complete. See `evidence/current-head-audit.md` and
`evidence/spec-verdict.md`.

## Agent Notes

The inspection did not infer that every option can fail on every platform. The defect is the systematic loss of a fallible native status.
