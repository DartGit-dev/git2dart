---
schema_version: 1
id: BUG-20260817-L8WX
display_number: 26
title: Repository identity lookup silently ignores native failures
status: active
phase: delivering
severity: medium
priority: P2
created: 2026-08-17
updated: 2026-08-27
origin: {type: inspection, external_ref: null}
area: repository-operations
module: repository-lifecycle
feature: repository-lifecycle
labels: [repository, identity, error-contract, silent-failure]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "1/1 static path", suspected_triggers: [invalid repository identity lookup]}
blocking: []
relationships:
  - {bug: BUG-20260817-6KRT, type: related-to, state: proposed, evidence: []}
traceability:
  specs: ["reversa/sdd/repository-lifecycle/requirements.md", "reversa/sdd/repository-lifecycle/edge-cases.md"]
  affected_code: ["lib/src/bindings/repository.dart:629"]
  root_cause:
    state: confirmed
    hypothesis: "The identity adapter read libgit2 output pointers without checking the git_repository_ident result."
    causal_path: "A native identity lookup failure returned a nonzero status; the historical adapter ignored it and projected any output as success."
    evidence:
      - "evidence/static-analysis.md"
      - "evidence/current-head-audit.md"
      - "1914a9053af88c6295fb58e6ed4e357dd8c27134"
  reproduction_tests:
    - path: "evidence/static-analysis.md"
      kind: static-historical-path
      result: reproduced-by-inspection
  regression_tests:
    - path: "test/repository_empty_test.dart"
      tests: ["sets identity", "unsets identity"]
      command: "flutter test -j 1 test/repository_empty_test.dart"
      result: "18 passed"
spec_verdict: spec-correta
change_set:
  - id: CHG-001
    kind: code
    path: lib/src/bindings/repository.dart
    commit: 1914a9053af88c6295fb58e6ed4e357dd8c27134
    diff: fix/CHG-001.diff
    summary: "Translate git_repository_ident failures before reading output pointers and free temporary slots in finally."
closure: {policy: package, satisfied: false}
resolution_kind: fixed
---

# Repository identity lookup silently ignores native failures

## Summary

The identity adapter ignores `git_repository_ident` status and returns an empty or partial list as if lookup succeeded.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- Native failure is checked and translated before output pointers are read.
- Temporary pointers are released in guaranteed cleanup.
- Negative tests distinguish no configured identity from repository failure.

## Resolution

The historical adapter ignored the status returned by `git_repository_ident`, so a native lookup failure could be represented as an empty or partial identity. Commit `1914a9053af88c6295fb58e6ed4e357dd8c27134` captures the status, calls `checkErrorAndThrow` before reading either output pointer, and frees both temporary pointer slots in a `finally` block. Current-head inspection confirms the correction remains present.

`flutter test -j 1 test/repository_empty_test.dart` passed all 18 tests, including configured and unset identity behavior. Focused `flutter analyze` passed with no issues. The error-path proof is the deterministic source-order audit because there is no safe public seam to induce a libgit2 identity-lookup failure without undefined native-pointer behavior.

The effective specification already requires native failures to be translated, so the approved default verdict is `spec-correta`. The correction is contained by local `HEAD` and `origin/0.5.5`; package publication remains required by closure policy, so this record remains `active/delivering`.

### Delivery

- Branch: `0.5.5`
- Corrective commit: `1914a9053af88c6295fb58e6ed4e357dd8c27134`
- Containment: verified in local `HEAD` and `origin/0.5.5`
- Local audit: `evidence/current-head-audit.md`
- Publication: pending; no version/backport has been published or claimed
