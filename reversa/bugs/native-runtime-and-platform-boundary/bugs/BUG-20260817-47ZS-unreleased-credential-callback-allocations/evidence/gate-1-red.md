# Gate 1 RED evidence

Date: 2026-08-21

## Credential binding ownership

Command:

```text
flutter test -j 1 test/credentials_test.dart --plain-name "owns SSH key temporary allocations through the active arena"
```

Result: failed as expected. The extracted `sshKey` implementation contains `calloc<Pointer<git_credential>>()` and four `toCharAlloc()` calls, and does not contain an arena owner.

## Callback payload ownership

Command:

```text
flutter test -j 1 test/callbacks_test.dart --plain-name "gives the credential payload one reset owner"
```

Result: failed as expected. The callback payload allocation is local to `plug`; no nullable static owner is declared for idempotent release by `reset()`.

## Credential error-message ownership

Command:

```text
flutter test -j 1 test/callbacks_test.dart --plain-name "owns credential error messages through callback arenas"
```

Result: failed as expected. `credentialsCb` contains two unmanaged `toCharAlloc()` conversions and no arena owner for the buffers passed to the copying `git_error_set_str()` calls.

## Proof boundary

These source-level regression tests prove that the known native allocation paths do not satisfy the selected ownership contract before the production changes. They do not establish runtime heap measurements or platform-wide leak freedom.
