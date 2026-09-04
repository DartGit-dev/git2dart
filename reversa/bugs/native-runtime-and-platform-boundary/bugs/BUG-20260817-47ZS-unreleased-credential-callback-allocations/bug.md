---
schema_version: 1
id: BUG-20260817-47ZS
display_number: 5
title: Credential callback allocations are never released
status: resolved
phase: closed
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
labels: [native-memory, callbacks, credentials]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "3/3 source ownership probes"
  suspected_triggers: [credential-bearing remote operation]
regression_analysis:
  last_known_good: "4dcd65b348f9f62d0080299806305fe7c0a4dd9e"
  first_known_bad: "37c3c41d3073207ccd2cf362acf39b05e719a5ae"
  bisect: "automated, 7 tested revisions, evidence/bisect.md"
  culprit_commit: "37c3c41d3073207ccd2cf362acf39b05e719a5ae"
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "reversa/sdd/native-runtime-and-platform-boundary/flows.md#fl-np-06-native-callback"
    - "reversa/sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code:
    - "lib/src/bindings/remote_callbacks.dart"
    - "lib/src/bindings/credentials.dart"
  root_cause:
    state: confirmed
    hypothesis: "Credential callback ownership is split across unmanaged allocations that neither the arena nor RemoteCallbacks.reset releases."
    causal_path:
      - "Credential callback setup allocates a native attempt payload with calloc."
      - "The payload pointer is stored only in the native callback options structure."
      - "RemoteCallbacks.reset clears Dart references without releasing that payload."
      - "The SSH-key credential builder separately bypasses its former arena for one output slot and four strings."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "Every unmanaged credential allocation was traced to a missing owner or release."}
      - {ref: "evidence/reproduction.md", observation: "Three of three source ownership probes reproduced the allocation pattern."}
    code_refs:
      - {file: "lib/src/bindings/remote_callbacks.dart", symbol: "RemoteCallbacks.plug and reset", commit: "37c3c41d3073207ccd2cf362acf39b05e719a5ae"}
      - {file: "lib/src/bindings/credentials.dart", symbol: "sshKey", commit: "37c3c41d3073207ccd2cf362acf39b05e719a5ae"}
  reproduction_tests: []
  regression_tests:
    - "test/credentials_test.dart"
    - "test/callbacks_test.dart"
spec_verdict: spec-correta
change_risk:
  classification: medium
  reasons:
    - "The correction changes native allocation ownership in authentication callbacks."
    - "Credential creation spans multiple authentication modes and both success and error exits."
    - "The intended repair restores existing arena conventions and adds an idempotent payload release without changing the public API."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/credentials_test.dart"
    purpose: "Prove SSH-key temporary values use deterministic arena ownership."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: test
    artifact: "test/callbacks_test.dart"
    purpose: "Prove the credential payload has one owner and idempotent release."
    diff: "fix/CHG-002.diff"
  - id: CHG-003
    kind: code
    artifact: "lib/src/bindings/credentials.dart"
    purpose: "Restore arena ownership for the SSH-key output slot and four input strings."
    diff: "fix/CHG-003.diff"
  - id: CHG-004
    kind: code
    artifact: "lib/src/bindings/remote_callbacks.dart"
    purpose: "Track and release the credential attempt payload exactly once during reset."
    diff: "fix/CHG-004.diff"
  - id: CHG-005
    kind: test
    artifact: "test/callbacks_test.dart"
    purpose: "Prove credential error-message buffers use deterministic arena ownership."
    diff: "fix/CHG-005.diff"
  - id: CHG-006
    kind: code
    artifact: "lib/src/bindings/remote_callbacks.dart"
    purpose: "Scope both copied credential error-message buffers to their native calls."
    diff: "fix/CHG-006.diff"
delivery:
  branch: "0.5.5"
  commit: "c8ce43e"
  pull_request: null
  merge: "contained by local 0.5.5 and origin/0.5.5; no pull request record"
  local_audit: "evidence/current-head-audit.md"
  publication: "USER-CONFIRMED on 2026-08-29; package registry not independently verified"
versions:
  fixed_in: "0.5.5"
backports: []
closure:
  policy: package
  satisfied: true
resolution_kind: fixed
---

# Credential callback allocations are never released

## Summary

Credential callback setup and error paths create native allocations without a matching release path.

## Expected Behavior

FR-NP-08, FL-NP-06, and ADR-003 require callback conversion state and manual temporary allocations to be released.

## Actual Behavior

`RemoteCallbacks.plug` allocates a credential attempt payload with `calloc<Int8>()`, assigns it to the native callback payload, and never frees it. Credential error messages also use unmanaged string allocation without an explicit matching free. The SSH key credential builder separately allocates its output slot and four strings without a matching release.

## Steps to Reproduce

1. Trace credential-bearing `RemoteCallbacks.plug` calls.
2. Follow `callbacksOptions.payload` through connect, fetch, push, clone, and submodule operations.
3. Search reset and call-site cleanup for a matching `calloc.free`.

## Evidence

- `evidence/static-analysis.md`
- `evidence/references-and-remotes-occurrence.md`
- `evidence/gate-1-red.md`
- `evidence/gate-2-green.md`

## Suspected Area

Remote credential callback payload ownership.

## Acceptance Criteria

- Every credential callback allocation has a single owner and matching release on success, native failure, and Dart callback failure.
- Repeated credential operations show no native allocation growth.
- Cleanup does not invalidate payload while native code may still invoke the callback.

## Traceability

- Specs: FR-NP-08, FL-NP-06, ADR-003.
- Code: `lib/src/bindings/remote_callbacks.dart` and its call sites.

## Resolution

The approved local change set is implemented and green in commit `c8ce43e`.
The current-head audit re-ran local synthetic ownership regressions and
focused analysis without real credentials or network access; both remain
green. The effective verdict remains `spec-correta`. Package publication is
still pending, so the record remains `active` / `delivering`; see
`evidence/current-head-audit.md`.

## Agent Notes

Do not include real credentials in reproduction evidence.
