# Current-head audit

## Scope

- Date: 2026-08-27
- Checkout: current HEAD, without branch or worktree mutation
- Corrective commit: `e2d8bb48123dcb290bccf63bcbfcc7eae2d89cca` (`fix: harden native binding cleanup`)
- Scope checked: callback bridge, seven callback-bearing call sites, and focused remote tests

## Historical red proof

Before `e2d8bb4`, `RemoteCallbacks.withCallbackState` called `plug` directly and only reset the shared state in `finally`. A nested or overlapping operation could therefore enter `plug` while the first operation's process-static closures were live and replace them. The historical remote test suite had no overlap-rejection regression.

## Current implementation

`RemoteCallbacks.withCallbackState` now uses `_operationActive`. A second entry throws `StateError` before `plug`; the outer call uses `finally` to reset callback fields, free the credential payload, and release the guard. This enforces serialization of synchronous callback-bearing operations rather than claiming operation-local callback isolation.

All current callback-bearing paths use `withCallbackState`:

1. `lib/src/remote.dart` — `Remote.prune`
2. `lib/src/bindings/remote.dart` — connect
3. `lib/src/bindings/remote.dart` — fetch
4. `lib/src/bindings/remote.dart` — push
5. `lib/src/bindings/repository.dart` — clone
6. `lib/src/bindings/submodule.dart` — update
7. `lib/src/bindings/submodule.dart` — clone

There are no production call sites of `RemoteCallbacks.plug` outside this boundary. The relevant production sources have no local working-tree diff. `test/remote_test.dart` has unrelated approved VG7G changes, preserved by this audit.

## Validation

| Command | Result | Proof |
| --- | --- | --- |
| `flutter test -j 1 test/remote_test.dart --plain-name "rejects overlapping callback operations before state is replaced"` | exit 0; 1 passing | nested callback operation is rejected before shared state replacement |
| `flutter test -j 1 test/remote_test.dart --plain-name "clears callback state after repeated loopback fetch failures"` | exit 0; 1 passing | repeated failure leaves all static callback fields and credential payload clear |
| `flutter analyze lib/src/bindings/remote_callbacks.dart lib/src/bindings/remote.dart lib/src/bindings/repository.dart test/remote_test.dart` | exit 0; no issues | focused bridge and consumers are statically clean |
| `git diff --check e2d8bb4^ e2d8bb4 -- lib/src/bindings/remote_callbacks.dart lib/src/bindings/remote.dart lib/src/bindings/repository.dart lib/src/bindings/submodule.dart lib/src/remote.dart test/remote_test.dart` | exit 0 | recorded correction has no whitespace errors |

## Proof boundary and closure

The regression is a deterministic same-isolate reentrancy test. It demonstrates the supported serialized-use restriction but does not dynamically characterize distinct native threads, callback exceptions, cancellation, or the five-platform network matrix. Those gaps remain listed in the SDD and in `blocking`.

The evidence supports `spec-correta`; see `spec-verdict.md`. The correction is contained by local and remote `0.5.5`, but concurrent-native-matrix and package-publication evidence remain pending, so this record is `active` / `delivering`.
