---
schema_version: 1
id: BUG-20260817-H7NP
display_number: 24
title: BlobWriteStream writeString corrupts non-ASCII text
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
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
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure: {policy: package, satisfied: false}
resolution_kind: null
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

Pending approved fix workflow.
