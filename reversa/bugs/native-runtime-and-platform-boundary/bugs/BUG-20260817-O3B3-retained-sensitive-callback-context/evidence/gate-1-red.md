# Gate 1 RED Evidence

Date: 2026-08-21
Base commit: `9683aa78b8eba77da50965d3a635005b6030d431`

## Authorization boundary

The human approved applying only the four O3B3 test diffs. No production code was changed. BUG-20260817-47ZS and BUG-20260817-3FWN remain unlaunched.

## Applied test changes

- `fix/CHG-001.diff` — helper success, Dart-error identity, synchronous bridge failure, and reset idempotence.
- `fix/CHG-002.diff` — repeated synthetic loopback fetch failure cleanup.
- `fix/CHG-003.diff` — repository clone cleanup for both clone callback-data fields.
- `fix/CHG-004.diff` — submodule family postconditions and two-site lexical migration invariant.

All four test files were formatted with `dart format` after application.

## Focused RED commands and observations

### Callback helper contract

Command:

```text
flutter test -j 1 --reporter expanded test/callbacks_test.dart
```

Result: RED during compilation. `RemoteCallbacks.withCallbackState` is absent at all three intended helper call sites. This is the expected pre-correction contract failure.

### Repeated remote failure

Command:

```text
flutter test -j 1 --reporter expanded test/remote_test.dart
```

Result: RED. The loopback fetch failure preserved `RemoteCallbacks.credentials` as a synthetic `UserPass` instead of clearing it. Summary: 30 passed, 7 skipped, 1 failed.

### Repository clone failure

Command:

```text
flutter test -j 1 --reporter expanded test/repository_clone_test.dart
```

Result: RED. The controlled clone failure preserved `RemoteCallbacks.remoteCbData` instead of clearing it. Summary: 9 passed, 1 failed.

### Submodule migration completeness

Command:

```text
flutter test -j 1 --reporter expanded test/submodule_test.dart
```

Result: RED. The source invariant found zero `RemoteCallbacks.withCallbackState` sites instead of the required two. Summary: 10 passed, 8 skipped, 1 failed.

## Gate conclusion

Gate 1 is satisfied: the approved tests are applied and demonstrate the registered defect on the current base. Production-code preparation requires a separate Gate 2 review and approval.
