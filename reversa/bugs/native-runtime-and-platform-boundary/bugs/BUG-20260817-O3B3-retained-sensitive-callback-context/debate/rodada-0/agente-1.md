---
protocol_version: 1
debate_id: BUG-20260817-O3B3-repair-20260821
bug_id: BUG-20260817-O3B3
role: solver
engine: local
round: 0
status: ok
started_at: 2026-08-21T10:02:26.8909210+07:00
finished_at: 2026-08-21T10:04:53.7974857+07:00
---

# Strategy

Introduce one package-internal `_RemoteCallbackSession` in `remote_callbacks.dart`, exposed to the other binding files only through a generic `RemoteCallbacks.withSession<T>(...)` helper. The helper must create the session before installing any callback state, perform installation and the supplied operation inside one `try`, and close the session in `finally`. Its action closure must include both the native call and `checkErrorAndThrow`; translating the error after `withSession` returns would allow cleanup to run before `git_error_last()` is captured.

Pass the enclosing `Arena` into `withSession`/`plug` and allocate the credential-attempt payload from that arena instead of global `calloc`. The arena is the sole owner of native callback temporaries. The session is the sole owner of the process-static Dart references (`transferProgress`, `sidebandProgress`, `updateTips`, `pushUpdateReference`, `certificateCheck`, `credentials`, `remoteCbData`, and `repositoryCbData`). Session close clears every reference and is guarded by a private `_closed` flag, making repeated close a no-op. Cleanup contains no libgit2 call, so it cannot replace an already captured native error.

Convert exactly six call sites: remote connect/fetch/push, repository clone, and submodule update/clone. Repository clone passes its optional remote/repository callback data into the same session instead of assigning those globals separately. Do not add locking, an active-session assertion, zones, payload-based dispatch, or other overlap behavior; EC-NP-16 remains unchanged.

# Proposed root cause

`RemoteCallbacks.plug` mutates process-static fields and allocates callback payload state, but returns no lifecycle owner. Each caller manually invokes `reset`, and several invoke `checkErrorAndThrow` first. A native error therefore throws past reset; a Dart exception during installation, option preparation, callback execution, or translation can do the same. Submodule paths reset before translation, but still rely on normal return from the native call and follow a different ordering. The absence of one structural lifetime boundary, rather than any individual callback, is the defect.

# Test

Add a restricted helper assertion that all eight static fields are null, with an unconditional test teardown reset so a red run cannot retain synthetic state.

1. In `remote_test.dart`, use `withSession` directly with arena-backed options: verify normal return clears all fields; then invoke a bridge in Dart with a callback that throws `StateError('synthetic callback failure')`, verify the same error escapes, and verify all fields are cleared. This proves Dart-error cleanup without characterizing exception propagation across an actual FFI callback boundary.
2. Turn the existing loopback reproduction into a red-to-green fetch test using only `127.0.0.1:1` and synthetic `UserPass` values. Assert the thrown object is the original `LibGit2Error`, callback state is clear, and a subsequent empty session starts clean. Retain the three isolated iterations if runtime cost is acceptable.
3. Add/augment local success tests for remote connect/fetch/push and repository clone, asserting state is clear after return. Add controlled failure coverage for each operation and for submodule update/clone in their existing test files. Each failure supplies a synthetic callback so installation is observable, then asserts cleanup. Prefer local repositories or loopback endpoints; no real credentials or external service.
4. Add a static review assertion (or focused source review checklist) that all six callback-bearing native calls occur inside `withSession` and that each closure calls `checkErrorAndThrow` before returning.

# Spec impact

No public API, ABI, generated binding, or effective-spec change. The repair implements FR-NP-03/05/08, FL-NP-06, EC-NP-10/14, and ADR-003. EC-NP-15 remains a characterization gap for real FFI callback exception propagation; EC-NP-16 remains explicitly out of scope.

# Risks and side effects

- Moving the attempt payload to the caller's arena also closes the callback-payload ownership path recorded by related BUG-20260817-47ZS; coordinate its closure to avoid a duplicate manual free.
- Clearing state too early would break native callbacks; `finally` must run only after the native call and immediate error translation complete.
- The session does not make static callbacks concurrency-safe. Overlapping operations can still overwrite each other's state.
- Repository clone copies callback options into clone options; arena lifetime must cover the entire native clone call, as it does today.

# Evidence

- `remote_callbacks.dart:250-303` installs global callback state and allocates the credential payload; `remote_callbacks.dart:305-316` only clears Dart fields.
- `remote.dart:382-412`, `473-515`, and `528-561` place reset after immediate error translation, so native failure bypasses it.
- `repository.dart:175-226` additionally installs clone-specific globals before the native call and resets only after translation.
- `submodule.dart:107-133` and `231-253` use a different reset-before-translation sequence but still lack `finally`.
- The restricted reproduction reports retained state in 3/3 isolated failures; the effective specs require deterministic temporary cleanup and exactly one owner/destructor path.

# Confidence

High. The primitive removes manual sequencing from every identified callback-bearing call site, preserves immediate native-error capture, uses the already-established arena lifetime, and deliberately leaves callback concurrency semantics unchanged.
