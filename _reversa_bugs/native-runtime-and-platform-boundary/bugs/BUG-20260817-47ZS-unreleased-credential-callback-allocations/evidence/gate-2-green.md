# Gate 2 GREEN evidence

Date: 2026-08-21

## Implemented ownership changes

- `sshKey` now assigns its output slot and four input strings to a call-scoped arena.
- `RemoteCallbacks` now retains the credential attempt payload under one nullable owner and frees it idempotently in `reset()`.
- Both credential error-message buffers now use short arena scopes around `git_error_set_str()`, which copies the message.
- The existing O3B3 `withCallbackState` `finally` path invokes `reset()` after migrated synchronous remote operations.

## Focused validation

The four ownership regressions passed individually:

- SSH-key temporary arena ownership.
- Callback payload single ownership.
- Callback payload idempotent release.
- Credential error-message arena ownership.

The complete callback test file passed: 11 tests.

The combined callback, credential, and remote test files passed: 47 tests; 16 network-tagged tests were skipped by project configuration.

## Repository validation

- `flutter analyze`: no issues found.
- `flutter test -j 1`: 943 tests passed; 24 network-tagged tests skipped.

## Proof boundary

The tests prove the selected source ownership contracts, cleanup idempotence, callback-state postconditions, and repository regression status in the current Windows environment. They do not provide native heap-growth instrumentation, sanitizer evidence, concurrent callback proof, or execution on every supported platform.
