---
protocol_version: 1
role: candidate
candidate_id: A
status: ok
ordering: descending-sha256
content_hash: C83277F6C6EB630FC6977FECABFD83FFE60A5AC6516D5D3C773447B6047C264A
---

# Candidate A

## Fix strategy

Revise the initial hybrid proposal to use one native initialization lease per Dart isolate, with two kinds of logical pins sharing that lease: transient call pins and persistent wrapper owner tokens. This keeps the useful lifetime distinction from the hybrid model without performing native init and shutdown around every operation or every wrapper.

1. Add one private `_Libgit2Runtime` state machine per isolate. The first pin calls `git_libgit2_init()`, checks the result before committing state, and throws `LibGit2Error` on a negative value. Later pins reuse the same native lease.
2. Replace all 66 direct initialization calls with the runtime entry operation. Pure calls take a transient pin and release it in `finally`. This logical call scope does not invoke native shutdown, so process global options and Android bootstrap survive between calls. It also prevents shutdown during a reentrant or otherwise in flight operation.
3. Give every independently usable native owner a managed cleanup token. The token records the native destructor and one persistent runtime pin. Explicit `free()` and fallback finalization execute the same one shot token: destroy or transfer the native resource first, then release the pin. Failed construction releases its provisional pin. Ownership transfer needs a distinct path that detaches without invoking the destructor.
4. Audit all ownership producing constructors and finalizer attachments, not only constructors containing the current 18 non global init calls. A child that can outlive its repository must have its own logical pin. Borrowed views must not create pins merely because they contain pointers.
5. Provide a deterministic terminal lifecycle boundary. A public raw decrement is neither necessary nor safe. Because Dart offers no guaranteed normal isolate exit hook, some explicit public boundary is necessary for full balancing; the smallest acceptable surface is a guarded, idempotent `Libgit2.shutdown()` that can release only the calling isolate's lease. It must throw `StateError` without changing native state while any transient or persistent pin exists. After successful shutdown, the isolate runtime is terminal and all later git2dart calls throw. An opaque runtime owner would encode ownership more strongly but is a larger API change and is not required for this repair.
6. Do not defer shutdown until a finalizer happens, do not cancel a pending shutdown on later use, and do not automatically shut down when the logical owner count reaches zero. Those behaviors make the moment of global cleanup nondeterministic or erase process global configuration between ordinary operations. The caller must explicitly free wrappers and then call terminal shutdown.
7. Keep Android certificate configuration and iOS eager loading under the isolate lease acquired by platform bootstrap. Repeated platform initialization reuses that lease. Terminal shutdown ends that configuration epoch; reinitialization is intentionally rejected until a separately specified platform rebootstrap design exists.

This is smaller than the round 0 per wrapper native lease proposal, avoids native counter churn, preserves global configuration, and still prevents premature shutdown through explicit logical ownership.

## Causa raiz proposta

The confirmed root cause is that 66 entry points acquire native initialization without an owner, ignore initialization failure, and never release the process global reference count. The safe correction is not merely to add shutdown calls. It must assign one native increment to an isolate lifecycle and prove that no call or native wrapper remains live when that isolate releases its increment.

## Teste

1. In a fresh isolate, probe the baseline, invoke `Libgit2.version` and other guarded APIs repeatedly, and prove that the package adds only one native initialization. After terminal shutdown, prove that the baseline is restored and a second shutdown does not decrement again.
2. Inject a negative initialization result. Assert that `LibGit2Error` is surfaced, no initialized state or pin is recorded, and a later successful initialization can proceed.
3. Hold a representative wrapper and assert that shutdown throws without changing the native count. Free the wrapper, shut down successfully, and prove destructor before shutdown ordering.
4. Create a child owner from a repository, release the repository, and prove that shutdown remains rejected until the child is released. This is the required guard against an incomplete root wrapper audit.
5. Exercise a transfer path such as a write stream commit. Transfer must detach ownership without a duplicate destructor and must release exactly one logical pin.
6. Exercise shutdown during a transient operation through a controlled reentrant callback or injected runtime adapter. Shutdown must reject while the call pin is active.
7. Test constructor validation and native failure paths. Neither may leave a wrapper pin behind, and terminal shutdown must still balance the isolate lease.
8. Coordinate two isolates. Both acquire one native lease; one performs terminal shutdown while the other remains usable; the second then shuts down and restores the original process count.
9. Verify repeated Android and iOS bootstrap. Android CA configuration remains effective through later TLS work until terminal shutdown.
10. Run formatting, zero warning analysis, focused lifecycle tests, the full Flutter suite, and the Windows, Linux, macOS, Android, and iOS matrix. Deterministic acceptance must use explicit cleanup rather than assume Dart finalizers run promptly.

## Impacto sobre a spec

The strategy satisfies FR NP 01 by assigning initialization and shutdown to one isolate owned lease. It strengthens FR NP 05 and FL NP 02 by making native destruction, transfer, and runtime pin release one ordered cleanup path. The effective specification does not need a verdict change.

The design and test specifications should clarify the two logical pin kinds, terminal shutdown rejection while pins exist, destructor before pin release ordering, ownership transfer, multi isolate composition through libgit2's native count, and the terminal platform configuration epoch. The public shutdown addition requires documentation plus positive and negative tests. No generated FFI declaration or companion binary change is justified by the locked evidence.

## Riscos e efeitos colaterais

The ownership inventory remains the dominant implementation risk. Missing one independently usable finalizer backed child permits premature shutdown; pinning a borrowed view can unnecessarily block shutdown.

The runtime must count transient calls as well as wrappers. A wrapper only registry leaves a reentrant call window in which shutdown could occur while native code is active.

Cleanup must be one shot and ordered. A destructor or transfer must complete before its persistent pin is released. If cleanup cannot confirm that the native owner was discharged, the safe state is to retain the pin and surface the failure, not to permit shutdown.

Finalizers are nondeterministic. They may retain the bounded isolate lease when callers omit explicit `free()`, but they must never trigger a previously requested shutdown later. Explicit cleanup followed by explicit shutdown is the deterministic contract.

Terminal shutdown is conservative. It avoids silently losing Android CA and process global options through reinitialization, but it prevents multiple runtime epochs in one isolate. A future rebootstrap API would require separate specification and platform tests.

Isolate local state cannot observe every wrapper in another isolate, but it does not need to: each isolate releases only its own native increment, and libgit2's process global reference count preserves other isolates' leases.

The finalizer adapter and ownership audit are broad, although mechanical. Centralizing the state machine and token behavior keeps the change reversible and avoids generated or binary modifications.

## Evidence

* `problema.md` locks the deterministic 2 to 3 to 4 reproduction, the 66 to 0 static count, the process global and isolate local constraint, platform bootstrap, and the effective FR NP 01, FR NP 05, and FL NP 02 requirements.
* the first prior proposal identifies the need for one isolate lease, wrapper registration, destructor before release ordering, multi isolate composition, and the absence of a guaranteed Dart finalizer shutdown boundary.
* the second prior proposal identifies 39 finalizer declarations across 30 files, derived child owners, explicit transfer behavior, constructor failure rollback, and the risk of resetting Android and global options between calls.
* the third prior proposal distinguishes pure calls, persistent native wrappers, and long lived global configuration, and rejects a public operation that can blindly decrement a lease it does not own.
* The official libgit2 references listed in `problema.md` define initialization and shutdown as a process global reference counted pair.

## Confidence

High. The revised strategy adopts the smaller one native lease per isolate model while preserving scoped safety through transient and persistent logical pins. Remaining uncertainty is implementation completeness across the ownership inventory and platform validation, not the lifecycle model.

## Critique of the other proposals

prior proposal X correctly reduces the 66 native increments to one isolate lease, requires wrapper tracking, orders destruction before release, and recognizes that ordinary finalizers cannot guarantee isolate teardown. Its deferred shutdown design is the main weakness. A `shutdown()` call that returns before native shutdown and later completes from a finalizer has surprising semantics, while cancellation by a later acquisition introduces another state transition and can hide that shutdown never occurred. Allowing a new runtime generation also risks losing Android CA and other process global configuration unless platform bootstrap is repeated. Rejecting shutdown while resources are live and making successful shutdown terminal is smaller and deterministic.

prior proposal Y provides the strongest ownership details: independently usable children need logical tokens, transfer is distinct from destruction, all finalizer backed owners need classification, and terminal shutdown preserves global configuration semantics. I adopt those points. Its proposal should additionally count transient operations, not only live wrappers, so shutdown cannot race a reentrant native call. Its statement that finalization releases the logical owner in `finally` is also too permissive if destruction can fail before ownership is actually discharged; fail closed by retaining the pin when cleanup is unconfirmed. Finally, the public `Libgit2.shutdown()` must be described as a guarded release of the calling isolate's owned lease, never as direct access to the raw native decrement.

