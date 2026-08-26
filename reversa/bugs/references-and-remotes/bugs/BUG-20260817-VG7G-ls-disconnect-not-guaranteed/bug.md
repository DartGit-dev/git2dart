---
schema_version: 1
id: BUG-20260817-VG7G
display_number: 9
title: Remote advertisement listing does not guarantee disconnect
status: active
phase: awaiting-human
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
origin: {type: inspection, external_ref: null}
area: repository-operations
module: references-and-remotes
feature: references-and-remotes
labels: [remote-ls, cleanup, transport]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "1/1 static path"
  suspected_triggers: [post-connect advertisement failure]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/references-and-remotes/requirements.md#responsibilities-and-rules"
    - "reversa/sdd/references-and-remotes/flows.md#fl-rr-03-list-remote-advertisements"
    - "reversa/sdd/references-and-remotes/edge-cases.md#references-and-remotes-edge-cases"
  affected_code: ["lib/src/remote.dart:260"]
  root_cause:
    state: confirmed
    hypothesis: "Remote.ls performs connect, advertisement listing, and disconnect sequentially, so a listing exception bypasses disconnect after a successful connection."
    causal_path: ["Remote.ls connect succeeds", "lsRemotes throws", "sequential disconnect is skipped", "transport remains connected until later disposal"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "The post-connect git_remote_ls call can throw and is not protected by cleanup."}
      - {ref: "evidence/reproduction.md", observation: "The local listing success path is green; direct control-flow analysis proves finally invokes disconnect if lsRemotes exits by throwing."}
    code_refs:
      - {file: "lib/src/remote.dart", symbol: "Remote.ls", commit: null}
  reproduction_tests: []
  regression_tests: ["test/remote_test.dart:326-333"]
spec_verdict: null
change_set:
  - {id: CHG-001, kind: test, artifact: "test/remote_test.dart", purpose: "Exercise two local advertisement listings without public network access.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/remote.dart", purpose: "Guarantee disconnect from finally after every post-connect listing exit.", diff: "fix/CHG-002.diff"}
closure: {policy: package, satisfied: false}
resolution_kind: null
change_risk:
  classification: low
  reasons:
    - "The patch changes only cleanup ordering after a successful connect."
    - "The original listing exception remains primary because disconnect is non-throwing."
---

# Remote advertisement listing does not guarantee disconnect

## Summary

`Remote.ls` disconnects only after advertisement retrieval succeeds.

## Expected Behavior

BR-RR-06, FR-RR-07, FL-RR-03, and EC-RR-12 require connection cleanup on success and failure.

## Actual Behavior

The method connects, reads advertisements, and then disconnects sequentially without `try/finally`. A post-connect failure bypasses disconnect.

## Steps to Reproduce

Trace `lib/src/remote.dart:260-282` and follow an exception from `lsRemotes`.

## Evidence

- `evidence/static-analysis.md`

## Suspected Area

Remote advertisement connection lifecycle.

## Acceptance Criteria

- A successful connection is disconnected on every later exit.
- Original errors remain observable if disconnect also fails.
- Positive and post-connect failure tests verify final connection state.

## Traceability

BR-RR-06, FR-RR-07, FL-RR-03, EC-RR-12, and `Remote.ls`.

## Resolution

### Reproduction and root cause

The cause is confirmed by the complete local control flow: `lsRemotes` passes
its fallible native status through `checkErrorAndThrow`, and the previous
sequential `disconnect` could not run after that throw.

### Applied change set

| ID | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/remote_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/remote.dart` | `fix/CHG-002.diff` |

`Remote.ls` now always invokes `disconnect` in `finally` after successful
connection. The local test lists a temporary repository twice without public
network access.

### Validation and proof boundary

- `flutter test -j 1 test/remote_test.dart` — passed: 34 tests, 7 network tests skipped.
- `flutter analyze` — passed with no issues.

No safe deterministic local stimulus makes `git_remote_ls` fail after a
successful connection. Therefore the post-connect failure cleanup guarantee is
established by control flow, not a live remote failure observation; no public
network remote was contacted.

### Pending human decisions and delivery

Recommended specification verdict: `spec-correta`. Package closure still
requires a human-recorded verdict, merge, and publication.

## Agent Notes

No live remote was contacted during inspection.
