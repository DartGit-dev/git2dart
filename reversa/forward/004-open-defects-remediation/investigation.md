# Investigation: Open Defects Remediation

## Evidence sources

- `reversa/bugs/**/bug.md` for all twelve records and acceptance criteria.
- `reversa/sdd/architecture.md` for wrapper/binding boundaries.
- ADR-003 for native ownership, ADR-004 for native error translation, and
  `reversa/sdd/state-machines.md` for lifecycle-sensitive operations.
- `.reversa/principles.md` for delivery constraints.

## Alternatives

1. **Native cleanup:** deterministic `try/finally` is preferred over finalizers
   for temporaries; finalizers remain a safety net only.
2. **OID results:** copy to managed storage where a temporary native pointer
   currently escapes. Retaining it is only acceptable with documented single
   ownership and deterministic release.
3. **Remote callbacks:** prefer operation-local callback context. If the FFI
   ABI cannot carry context safely, introduce narrow serialization rather than
   allowing callback cross-delivery.
4. **Initializer failures:** use the existing shared error helper immediately;
   do not duplicate exception translation in every adapter.

## Required investigation before each edit

- Confirm allocation provenance and the matching native disposer from the
  current generated declaration/libgit2 contract.
- Confirm ownership across success, native-error, Dart-conversion-error, and
  callback-exception paths.
- Add a precise regression test before declaring root cause confirmed.
- For QWMA and CIKD, validate under current companion binaries and record any
  platform-specific limitation.
