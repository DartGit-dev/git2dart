---
schema_version: 1
id: BUG-20260817-6KRT
display_number: 13
title: Index read and write operations silently ignore native failures
status: active
phase: awaiting-human
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-26
origin: {type: inspection, external_ref: null}
area: repository-operations
module: working-tree-and-index
feature: working-tree-and-index
labels: [index, persistence, error-contract, silent-failure]
visibility: normal
security_suspected: false
reproduction:
  classification: deterministic
  rate: "3/3 static paths"
  suspected_triggers: [invalid index, read failure, write failure]
blocking: []
relationships: []
traceability:
  specs:
    - "reversa/sdd/working-tree-and-index/requirements.md#functional-requirements"
    - "reversa/sdd/working-tree-and-index/flows.md#fl-wi-01-stage-paths-and-write-a-tree"
  affected_code: ["lib/src/bindings/index.dart:98", "lib/src/bindings/index.dart:110", "lib/src/bindings/index.dart:347", "lib/src/index.dart:277", "lib/src/index.dart:285", "lib/src/index.dart:294"]
  root_cause:
    state: confirmed
    hypothesis: "The index binding discards the integer status values from git_index_read, git_index_read_tree, and git_index_write instead of passing them through the shared error boundary."
    causal_path: ["fallible native index operation", "integer error status", "binding discards status", "public method returns normally", "caller observes false success"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "All three stated native calls omit checkErrorAndThrow; a complete binding search found exactly these three calls in scope."}
      - {ref: "evidence/reproduction.md", observation: "An in-memory index read returned normally before the correction; after it, read and write throw LibGit2Error while the valid readTree path remains green."}
    code_refs:
      - {file: "lib/src/bindings/index.dart", symbol: "read", commit: null}
      - {file: "lib/src/bindings/index.dart", symbol: "readTree", commit: null}
      - {file: "lib/src/bindings/index.dart", symbol: "write", commit: null}
  reproduction_tests: ["test/index_test.dart:269-274"]
  regression_tests: ["test/index_test.dart:255-267", "test/index_test.dart:269-274", "test/index_test.dart:308-317"]
spec_verdict: null
change_set:
  - {id: CHG-001, kind: test, artifact: "test/index_test.dart", purpose: "Cover safe native persistence failures and preserve valid read/readTree behavior.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/bindings/index.dart", purpose: "Translate all three ignored index I/O statuses through the shared error boundary.", diff: "fix/CHG-002.diff"}
closure: {policy: package, satisfied: false}
resolution_kind: null
change_risk:
  classification: low
  reasons:
    - "The patch checks only the three pre-existing native result codes in scope."
    - "Successful zero statuses, public APIs, native ABI, and persistence semantics are unchanged."
---

# Index read and write operations silently ignore native failures

## Summary

Three public index persistence paths discard libgit2 status codes and therefore report success when the native operation fails.

## Expected Behavior

FR-WI-03, FR-WI-04, and the central native error contract require every failed read, tree read, or write to throw a translated error.

## Actual Behavior

`read`, `readTree`, and `write` call fallible libgit2 APIs without passing the result to `checkErrorAndThrow`.

## Steps to Reproduce

Trace the three high-level methods to their binding functions and follow the returned native integer.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- All three return codes are checked.
- Negative tests demonstrate that invalid or unwritable index operations throw.
- Successful behavior remains unchanged on the supported platform matrix.

## Resolution

### Reproduction and root cause

Before the correction, `Index.newInMemory().read()` returned normally even
though libgit2 reported a native error. The root cause is confirmed: the
binding discarded the status codes from exactly three in-scope calls:
`git_index_read`, `git_index_read_tree`, and `git_index_write`.

### Applied change set

| ID | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/index_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/bindings/index.dart` | `fix/CHG-002.diff` |

Read and write failure paths now throw `LibGit2Error`. The existing successful
disk read/write and valid-tree tests remain green. A null native tree was not
retained as a negative stimulus: libgit2 did not return a status for that
invalid pointer and the test did not complete. `readTree` error translation is
therefore established by complete local control-flow evidence, while its valid
path remains dynamically covered.

### Validation

- `flutter test -j 1 test/index_test.dart` — red before CHG-002, green after it.
- `flutter analyze` — passed with no issues.
- `git diff --check` — passed.

### Pending human decisions and delivery

Recommended specification verdict: `spec-correta`. FR-WI-03 and FR-WI-04
already require translated native failures. Package closure still requires a
human-recorded verdict, merge, and publication.
