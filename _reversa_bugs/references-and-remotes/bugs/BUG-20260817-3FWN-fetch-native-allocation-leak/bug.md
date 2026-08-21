---
schema_version: 1
id: BUG-20260817-3FWN
display_number: 8
title: Remote fetch leaks native options and refspec allocations
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-21
origin: {type: inspection, external_ref: null}
area: native-integration
module: references-and-remotes
feature: references-and-remotes
labels: [remote-fetch, native-memory, leak]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "3/3 source ownership probes"
  suspected_triggers: [remote fetch]
regression_analysis:
  last_known_good: "0f78771da90054dedf0f54d28d4e154ea3eb7b2d"
  first_known_bad: "02c6784aaf6157c434e62dd99c4248f80d84ee80"
  bisect: "automated, 7 tested revisions, evidence/bisect.md"
  culprit_commit: "02c6784aaf6157c434e62dd99c4248f80d84ee80"
blocking: []
relationships:
  - bug: BUG-20260817-47ZS
    type: related-to
    state: confirmed
    evidence:
      - "evidence/reproduction.md"
      - "../../../native-runtime-and-platform-boundary/bugs/BUG-20260817-47ZS-unreleased-credential-callback-allocations/evidence/root-cause.md"
traceability:
  specs:
    - "_reversa_sdd/references-and-remotes/requirements.md#functional-requirements"
    - "_reversa_sdd/references-and-remotes/flows.md#fl-rr-04-fetch"
    - "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code: ["lib/src/bindings/remote.dart:473"]
  root_cause:
    state: confirmed
    hypothesis: "The fetch path bypasses its active arena for three temporary native structures and supplies no explicit release."
    causal_path:
      - "Fetch enters an Arena using scope."
      - "The refspec wrapper, pointer array, and fetch options are allocated with global calloc instead of the arena."
      - "Neither normal completion nor error unwind explicitly frees those temporary structures."
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "All three unmanaged fetch allocations have no matching free."}
      - {ref: "evidence/reproduction.md", observation: "Three of three source ownership probes reproduced the pattern."}
    code_refs:
      - {file: "lib/src/bindings/remote.dart", symbol: "fetch", commit: "02c6784aaf6157c434e62dd99c4248f80d84ee80"}
  reproduction_tests: []
  regression_tests:
    - "test/remote_test.dart"
spec_verdict: spec-correta
change_risk:
  classification: low
  reasons:
    - "The repair is confined to three temporary allocations inside one binding function."
    - "The adjacent push path already demonstrates the intended arena-owned pattern."
    - "No public API, persistent data, or native ABI changes are required."
change_set:
  - id: CHG-001
    kind: test
    artifact: "test/remote_test.dart"
    purpose: "Prove all three fetch temporaries use deterministic arena ownership."
    diff: "fix/CHG-001.diff"
  - id: CHG-002
    kind: code
    artifact: "lib/src/bindings/remote.dart"
    purpose: "Move the fetch refspec wrapper, pointer array, and options into the active arena."
    diff: "fix/CHG-002.diff"
delivery:
  branch: "0.5.5"
  commit: null
  pull_request: null
  merge: pending
  publication: pending
versions:
  fixed_in: null
backports: []
closure: {policy: package, satisfied: false}
resolution_kind: fixed
---

# Remote fetch leaks native options and refspec allocations

## Summary

Every fetch allocates three native containers outside the arena and never releases them.

## Expected Behavior

FR-RR-08, FR-RR-12, FL-RR-04, and ADR-003 require remote options and temporary refspec storage to be released on success and error.

## Actual Behavior

`fetch` allocates `git_strarray`, its pointer array, and `git_fetch_options` with `calloc`. The enclosing arena does not own these allocations and no explicit free exists.

## Steps to Reproduce

Trace allocations and cleanup in `lib/src/bindings/remote.dart:473-516`.

## Evidence

- `evidence/static-analysis.md`
- `evidence/gate-1-red.md`
- `evidence/gate-2-green.md`

## Suspected Area

Remote fetch option and refspec marshalling.

## Acceptance Criteria

- Each allocation has one owner and is released on all exits.
- Repeated fetch instrumentation reports no growth.
- Callback payload cleanup remains correctly ordered.

## Traceability

FR-RR-08, FR-RR-12, FL-RR-04, ADR-003, and the remote fetch binding.

## Resolution

The approved local change set is implemented and green. Package delivery remains pending; no commit, merge, or publication has been performed.

## Agent Notes

The source remained read-only during inspection.
