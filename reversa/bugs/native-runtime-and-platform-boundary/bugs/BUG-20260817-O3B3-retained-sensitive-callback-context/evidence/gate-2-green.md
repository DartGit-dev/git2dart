# Gate 2 GREEN Evidence

Date: 2026-08-21
Base commit: `9683aa78b8eba77da50965d3a635005b6030d431`

## Authorized correction

The human approved CHG-005 through CHG-008. The implementation adds one internal synchronous lexical callback-state owner and migrates exactly six operation families: remote connect/fetch/push, repository clone, and submodule update/clone.

Credential payload ownership under BUG-20260817-47ZS and fetch temporary ownership under BUG-20260817-3FWN were not changed.

## Focused validation

Command:

```text
flutter test -j 1 --reporter compact test/callbacks_test.dart test/remote_test.dart test/repository_clone_test.dart test/submodule_test.dart
```

Result: GREEN — 60 passed, 15 network-tagged tests skipped.

The helper preserved return values and Dart error identity, cleared callback state after a synchronous bridge error, and remained safe under repeated reset. Repeated loopback fetch failures and controlled repository clone failure both cleared all registered callback fields. The submodule migration invariant found both required lexical scopes.

## Static analysis

Command:

```text
flutter analyze
```

Result: GREEN — no issues found.

## Full local suite

Command:

```text
flutter test -j 1 --reporter compact
```

Result: GREEN — 938 passed, 24 network-tagged tests skipped.

## Migration and exclusion audit

- `lib/src/bindings/remote.dart`: three `RemoteCallbacks.withCallbackState` sites.
- `lib/src/bindings/repository.dart`: one site.
- `lib/src/bindings/submodule.dart`: two sites.
- No migrated operation retains a standalone `RemoteCallbacks.reset()` call.
- The 47ZS callback payload still uses its registered unmanaged `calloc<Int8>()` path.
- The 47ZS SSH-key builder remains outside arena ownership.
- The 3FWN fetch path still contains its three registered global `calloc` allocations.

## Gate conclusion

Gate 2 is satisfied. The corrected behavior is ready for the mandatory human specification verdict.
