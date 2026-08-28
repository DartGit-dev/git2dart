---
schema_version: 1
id: BUG-20260817-J9CU
display_number: 18
title: Rebase finish and abort silently ignore native failures
status: active
phase: delivering
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: repository-operations
module: history-and-integration-operations
feature: history-and-integration-operations
labels: [rebase, state, error-contract, silent-failure]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "2/2 static paths", suspected_triggers: [failed rebase finish, failed rebase abort]}
blocking: []
relationships:
  - {bug: BUG-20260817-6KRT, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/history-and-integration-operations/flows.md", "reversa/sdd/history-and-integration-operations/edge-cases.md"]
  affected_code: ["lib/src/bindings/rebase.dart:149", "lib/src/bindings/rebase.dart:155", "lib/src/rebase.dart:169", "lib/src/rebase.dart:176"]
  root_cause:
    state: confirmed
    hypothesis: "The rebase binding discards the status codes returned by git_rebase_finish and git_rebase_abort, so public terminal operations return normally after native failure."
    causal_path: ["terminal rebase call", "native integer error status", "binding returns void without validation", "public method returns normally", "repository outcome is unobservable"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "Both terminal native calls are returned directly without checkErrorAndThrow."}
      - {ref: "evidence/reproduction.md", observation: "A second finish returned -15 before the correction and did not reach the public error contract; after the correction it throws LibGit2Error."}
    code_refs:
      - {file: "lib/src/bindings/rebase.dart", symbol: "finish", commit: null}
      - {file: "lib/src/bindings/rebase.dart", symbol: "abort", commit: null}
  reproduction_tests: ["test/rebase_test.dart:72"]
  regression_tests: ["test/rebase_test.dart:70-72", "test/rebase_test.dart:246-248"]
spec_verdict: spec-correta
change_set:
  - {id: CHG-001, kind: test, artifact: "test/rebase_test.dart", purpose: "Cover a successful finish followed by a safe terminal native failure; retain successful abort coverage.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/rebase.dart", purpose: "Translate finish and abort native statuses through the shared error boundary.", diff: "fix/CHG-002.diff"}
closure: {policy: package, satisfied: false}
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
change_risk:
  classification: low
  reasons:
    - "Only the two existing terminal native return codes are checked."
    - "Successful zero statuses, public APIs, and native ABI remain unchanged."
---

# Rebase finish and abort silently ignore native failures

## Summary

The two terminal rebase operations discard libgit2 return codes, so callers cannot know whether repository state was finalized or restored.

## Expected Behavior

Every state-changing terminal operation must translate native failure and leave its outcome observable.

## Actual Behavior

Both binding functions return `void` directly from fallible libgit2 calls without checking their integer status.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Both statuses are checked and translated.
- Negative tests distinguish successful finish/abort from retained rebase state.

## Resolution

### Reproduction and root cause

Before CHG-002, a second `finish()` after a successful rebase returned native
status `-15` but the public method returned normally. The root cause is
confirmed: both terminal binding methods discarded their native integer status.

### Applied change set

| ID | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/rebase_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/rebase.dart` | `fix/CHG-002.diff` |

Both terminal calls now pass their result through `checkErrorAndThrow`. The
focused suite proves the successful finish and successful abort paths, and
proves the safe repeated-finish failure path becomes `LibGit2Error`.

No safe deterministic abort failure injection was found: a repeated abort and
temporary index/HEAD lock files remain idempotent on this libgit2 build. This
is a dynamic-test boundary, not a claim that abort cannot fail; its new error
translation is established by direct control-flow coverage of its returned
status through the shared boundary.

### Validation

- `flutter test -j 1 test/rebase_test.dart` — red before CHG-002, green after it (10 tests).
- `flutter analyze` — passed with no issues.

### Specification verdict and delivery

The evidence-backed default verdict is `spec-correta`: the effective rebase
flow requires `finish` to advance final state and `abort` to restore
pre-rebase state, so their native failures must remain observable through the
existing shared error contract. See `evidence/spec-verdict.md`.

Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` is contained by local and
origin `0.5.5`. Package publication is still pending, so the record remains
`active` / `delivering` under the package closure policy.
