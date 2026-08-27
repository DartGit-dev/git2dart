---
schema_version: 1
id: BUG-20260817-VG7G
display_number: 9
title: Remote advertisement listing does not guarantee disconnect
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-27
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
      - {ref: "evidence/test-seam-analysis.md", observation: "A deterministic source-structure regression can distinguish the pre-fix sequential control flow from the required try/finally cleanup without adding a mutable production test hook."}
      - {ref: "evidence/gate-1.md", observation: "The Gate 1 structural assertion is green on the current source and its expected block is absent from immutable pre-fix commit 1914a90^."}
    code_refs:
      - {file: "lib/src/remote.dart", symbol: "Remote.ls", commit: null}
  reproduction_tests: ["test/remote_test.dart:336"]
  regression_tests:
    - "test/remote_test.dart:328"
    - "test/remote_test.dart:336"
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/remote_test.dart", purpose: "Exercise two local advertisement listings without public network access.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/remote.dart", purpose: "Guarantee disconnect from finally after every post-connect listing exit.", diff: "fix/CHG-002.diff"}
  - {id: CHG-003, kind: test, artifact: "test/remote_test.dart", purpose: "Assert that the post-connect listing remains enclosed by finally cleanup.", diff: "fix/CHG-003.diff"}
closure: {policy: package, satisfied: false}
resolution_kind: fixed
change_risk:
  classification: low
  reasons:
    - "The patch changes only cleanup ordering after a successful connect."
    - "The original listing exception remains primary because disconnect is non-throwing."
    - "CHG-003 is test-only and normalizes source line endings before a structural assertion."
delivery:
  branch: "0.5.5"
  correction_commit: "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  gate_1: "passed locally; evidence/gate-1.md"
  merge: "correction commit contained by local HEAD and origin/0.5.5 on 2026-08-27"
  publication: "pending"
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
| CHG-003 | test | `test/remote_test.dart` | `fix/CHG-003.diff` |

`Remote.ls` now always invokes `disconnect` in `finally` after successful
connection. The local test lists a temporary repository twice without public
network access.

### Validation and proof boundary

- `flutter test -j 1 test/remote_test.dart` — passed: 36 tests, 7 network tests skipped.

No safe deterministic local stimulus makes `git_remote_ls` fail after a
successful connection. The renewed Gate 1 plan therefore adds a deterministic
source-structure regression: it will be red against the former sequential
implementation and green only when `lsRemotes` remains inside `try/finally`.
This proves the wrapper control flow, not a live native advertisement failure;
no public network remote will be contacted.

### Renewed Gate 1 plan

The existing local two-list test is retained as the positive, network-free
cleanup check. CHG-003 is the smallest additional test-only change: it reads
the `Remote.ls` method body and asserts the ordering and enclosure of
`try`, `lsRemotes`, `finally`, and `disconnect`.

### Gate 1 completion

The user authorized automatic sequential remediation without further plan or
gate prompts (`evidence/authorization.md`). CHG-003 now normalizes CRLF before
checking the exact cleanup structure, so the assertion is portable across the
supported Windows and Unix line endings. The immutable pre-fix source at
`1914a90^` has no matching `try/finally` block; the focused current suite is
green. Details and commands are in `evidence/gate-1.md`.

### CHG-002 source audit

CHG-002 is already present in commit `1914a90`: after a successful connect,
`Remote.ls` encloses only `lsRemotes` in `try/finally` and invokes the binding
disconnect in `finally`. The binding does not translate a disconnect status
into a Dart exception, preserving a listing exception as the primary error.
See `evidence/source-audit.md`.

### Specification verdict and delivery

The effective specification is `spec-correta`: BR-RR-06, FR-RR-07, FL-RR-03,
and EC-RR-12 already require cleanup for both successful and failed listing.
The evidence and decision are recorded in `evidence/spec-verdict.md`; no
addendum is required. Commit `1914a905` is contained by local `HEAD` and
`origin/0.5.5`.

Package closure still requires publication, so this record remains
`active/delivering` and no `DONE.md` is created.

## Agent Notes

No live remote was contacted during inspection.
