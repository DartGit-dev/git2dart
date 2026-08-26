---
schema_version: 1
id: BUG-20260817-H7NP
display_number: 24
title: BlobWriteStream writeString corrupts non-ASCII text
status: active
phase: awaiting-human
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-26
origin: {type: inspection, external_ref: null}
area: native-integration
module: git-objects-and-object-database
feature: git-objects-and-object-database
labels: [blob, stream, utf8, data-corruption]
visibility: normal
security_suspected: false
reproduction: {classification: deterministic, rate: "all non-Latin-1 input", suspected_triggers: [writing Unicode text to a blob stream]}
blocking: []
relationships: []
traceability:
  specs: ["reversa/sdd/git-objects-and-object-database/requirements.md", "reversa/sdd/git-objects-and-object-database/tests.md"]
  affected_code: ["lib/src/writestream.dart:42"]
  root_cause:
    state: confirmed
    hypothesis: "BlobWriteStream.writeString passes UTF-16 code units to an 8-bit byte list instead of UTF-8 encoding the string."
    causal_path: ["String text", "text.codeUnits", "Uint8List.fromList", "git_writestream write", "corrupted blob bytes"]
    evidence:
      - {ref: "evidence/static-analysis.md", observation: "writeString uses text.codeUnits even though its public documentation promises UTF-8."}
      - {ref: "evidence/reproduction.md", observation: "The focused blob-stream test failed before the fix, returning corrupted text for mixed Unicode input."}
    code_refs:
      - {file: "lib/src/writestream.dart", symbol: "BlobWriteStream.writeString", commit: null}
  reproduction_tests: ["test/blob_test.dart:175-185"]
  regression_tests: ["test/blob_test.dart:175-185"]
spec_verdict: null
change_set:
  - {id: CHG-001, kind: test, artifact: "test/blob_test.dart", purpose: "Prove Unicode stream text round-trips as UTF-8.", diff: "fix/CHG-001.diff"}
  - {id: CHG-002, kind: code, artifact: "lib/src/writestream.dart", purpose: "Encode string input as UTF-8 before streaming it to libgit2.", diff: "fix/CHG-002.diff"}
closure: {policy: package, satisfied: false}
resolution_kind: null
change_risk:
  classification: low
  reasons:
    - "The patch changes one documented convenience conversion to Dart's standard UTF-8 encoder."
    - "The public API signature, raw byte write path, and native ABI are unchanged."
---

# BlobWriteStream writeString corrupts non-ASCII text

## Summary

The method documented as UTF-8 writes UTF-16 code units directly into an 8-bit list instead of encoding the string as UTF-8.

## Expected Behavior

String input must be converted with a UTF-8 encoder and reproduce the original text when the blob is read.

## Actual Behavior

`Uint8List.fromList(text.codeUnits)` truncates code units above 255 and does not produce multibyte UTF-8 sequences.

## Evidence

- `evidence/static-analysis.md`

## Acceptance Criteria

- UTF-8 encoding is used.
- Tests cover Cyrillic, emoji, combining characters, and ASCII.

## Resolution

### Reproduction and root cause

The focused reproduction test failed before the correction and passed after it.
The root cause is confirmed: `BlobWriteStream.writeString` sent UTF-16 code
units to an 8-bit native write API instead of UTF-8 bytes. See
`evidence/reproduction.md` and `evidence/static-analysis.md`.

### Applied change set

| ID | Kind | Artifact | Evidence |
| --- | --- | --- | --- |
| CHG-001 | test | `test/blob_test.dart` | `fix/CHG-001.diff` |
| CHG-002 | code | `lib/src/writestream.dart` | `fix/CHG-002.diff` |

The test covers one string containing ASCII, Cyrillic, an emoji, and a
combining character. Before the correction it failed at the text round-trip;
after the correction it verifies both the text and exact UTF-8 bytes.

### Validation

- `flutter test -j 1 test/blob_test.dart` — red before CHG-002, green after it.
- `flutter analyze` — passed with no issues.
- `flutter test -j 1` — passed: 959 tests.
- `git diff --check` — passed.

### Pending human decisions and delivery

Recommended specification verdict: `spec-gap`. The effective SDD requires
streamed blob content preservation, but does not explicitly state that
`writeString` serializes Dart strings as UTF-8. A human decision is required
before creating any immutable addendum. Package closure additionally requires
merge and publication; no external delivery action was authorized.

## Agent Notes

- Mitigation was not applied: this is a package defect with no evidence of a currently running production deployment in scope.
- Existing blobs written with non-ASCII text cannot be reconstructed automatically because the original UTF-16 code units were truncated; no data-repair change is proposed.
