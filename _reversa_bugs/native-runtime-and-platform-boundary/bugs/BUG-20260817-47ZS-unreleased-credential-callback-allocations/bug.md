---
schema_version: 1
id: BUG-20260817-47ZS
display_number: 5
title: Credential callback allocations are never released
status: open
phase: triaging
severity: high
priority: P1
created: 2026-08-17
updated: 2026-08-17
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
  rate: "1/1 static path"
  suspected_triggers: [credential-bearing remote operation]
blocking: []
relationships: []
traceability:
  specs:
    - "_reversa_sdd/native-runtime-and-platform-boundary/requirements.md#functional-requirements"
    - "_reversa_sdd/native-runtime-and-platform-boundary/flows.md#fl-np-06-native-callback"
    - "_reversa_sdd/adrs/003-use-arenas-and-finalizers-for-native-memory.md#decision"
  affected_code:
    - "lib/src/bindings/remote_callbacks.dart"
    - "lib/src/bindings/credentials.dart"
  root_cause: null
  reproduction_tests: []
  regression_tests: []
spec_verdict: null
change_set: []
closure:
  policy: package
  satisfied: false
resolution_kind: null
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

Pending `/reversa-debugger-fix` investigation and approved change set.

## Agent Notes

Do not include real credentials in reproduction evidence.
