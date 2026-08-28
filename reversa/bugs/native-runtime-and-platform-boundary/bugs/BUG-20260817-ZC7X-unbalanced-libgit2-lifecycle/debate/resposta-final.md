---
protocol_version: 1
debate_id: BUG-20260817-ZC7X-repair-20260821
bug_id: BUG-20260817-ZC7X
role: judge
status: ok
candidates: 3
---

# Verdict

Candidate A wins.

Its isolate-owned native lease, persistent wrapper-owner tokens, transient call pins, guarded terminal shutdown, and fail-closed cleanup rule form the most complete repair under the frozen criteria. Candidate B is marginally simpler but permits logical ownership to disappear after an unconfirmed destructor, and Candidates B and C omit protection for an in-flight ownerless native call. Those omissions are not conservative enough for a process-global runtime with a public shutdown boundary.

# Winning strategy

Implement one private isolate-local runtime manager. Its first guarded entry calls `git_libgit2_init()`, validates the result before committing state, and owns exactly one native increment for that isolate. All later entries reuse that lease; the 66 direct initialization calls disappear. Initialization failure is translated to the package's specific native error and leaves the manager uninitialized.

The manager tracks two logical pin classes without adding native reference-count transitions:

- A transient call pin protects any native operation that is not already protected by a live persistent owner, including pure/global operations. It is released in `finally` after the operation returns or throws.
- A persistent owner token protects every independently usable owned native wrapper. Successful construction transfers a provisional token into a one-shot managed cleanup payload. Explicit release and fallback finalization use the same payload. Derived owned children receive their own tokens; borrowed or fully materialized Dart views do not. Ownership transfer completes the old token without invoking its destructor.

Add a documented, idempotent `Libgit2.shutdown()` that releases only the calling isolate's lease. It is synchronous and fail-fast: if any transient or persistent pin exists, it throws `StateError` without changing Dart or native state. Once native shutdown releases this isolate's lease, the isolate becomes terminal and later git2dart entries throw rather than silently recreating an incompletely bootstrapped runtime. A positive native remaining-count is valid because other isolates or external consumers may still own leases.

Transient pins are required conservatively. Dart's usual single-isolate sequencing makes the race uncommon, but it does not prove that native callbacks or a future reentrant test seam cannot invoke shutdown while an ownerless native call is active. The pin is isolate-local bookkeeping, not a per-call native init/shutdown pair, so it closes that safety gap without counter churn. Constructors may use their provisional persistent token as their in-flight protection, and methods on a valid owned wrapper may rely on that wrapper's persistent token; an extra transient pin is unnecessary in those already-protected paths.

Destructor failure is also resolved fail-closed. The persistent owner may be released only after native destruction is confirmed or after a valid ownership transfer. A synchronous destructor failure is surfaced and leaves the token incomplete and the pin retained. A finalizer callback must not throw across the finalizer boundary; it must retain the pin and report the failure through the available internal diagnostic/test seam. Retaining a bounded lease is safer than allowing terminal shutdown while the native owner may still exist.

# Grafted insights

From Candidate B:

- Make `shuttingDown` an explicit internal transition so reentrant entry cannot observe a partially completed terminal operation.
- Treat a positive return from native shutdown as a valid remaining process count, not as failure of this isolate's release.
- Include representative root-wrapper families in the ownership tests rather than relying on a single repository example.

From Candidate C:

- If native shutdown itself cannot be confirmed, keep the manager active and surface the error instead of marking it terminal.
- Finalizer callbacks must never throw, even though their cleanup token remains fail-closed on an unconfirmed destructor.
- Test terminal post-shutdown rejection and unchanged state after a rejected live-owner shutdown explicitly.

# Rubric justification

## Root-cause elimination

Candidate A replaces the unowned increment at every direct initialization site with one owned isolate lease, pairs that lease with one guarded terminal shutdown, and surfaces initialization failure. Logical pins prevent the new shutdown path from running while native work or independently usable native owners remain live. This eliminates both the observed unbounded `init` growth and the premature-shutdown hazard introduced by balancing it.

Candidate B also collapses the 66 increments, but releasing its logical owner in `finally` after destructor failure can falsely certify that shutdown is safe. Candidate C fixes that failure mode but leaves ownerless in-flight calls uncounted. Candidate A is the only proposal that closes both residual gaps.

## Smallest coherent change

The chosen repair adds one private manager, one private cleanup-token abstraction, mechanical routing of existing initialization sites, a complete ownership classification, and one public terminal method. The ownership audit is broad but unavoidable: a root-only or init-site-only conversion cannot prove FR-NP-05 for independently usable children and transfer paths.

Transient pins add only logical counter operations to otherwise ownerless call boundaries. They do not add per-call native initialization, a second public runtime-owner object, generated binding work, binary changes, or repeated platform bootstrap. Limiting them to paths not already protected by a persistent token keeps Candidate A's safety refinement coherent and bounded.

## Regression risk

One native lease per isolate minimizes process-global counter transitions and preserves Android certificate setup and other global options across normal calls. Fail-fast shutdown avoids nondeterministic completion through finalizers. Terminal semantics avoid an unsafe second runtime epoch without a specified replay of platform/global configuration.

The highest remaining risk is misclassifying wrapper ownership. A complete inventory must distinguish owned, derived-owned, borrowed, materialized, and transferred values. One-shot cleanup, constructor rollback, destructor-before-pin-release ordering, and transient protection reduce the consequences of exception, duplicate-release, transfer, and reentrancy paths. Cross-platform and multi-isolate tests remain mandatory because isolate-local bookkeeping cannot replace validation of the process-global native count.

## Reversibility

The runtime manager, logical pins, and cleanup adapter are private and centralized. Existing call sites are mechanically rerouted rather than redesigned, and no generated FFI declaration, companion binary, or platform loader is changed. The only public addition is `Libgit2.shutdown()`, whose terminal contract is narrow and explicit. The repair can therefore be reverted largely by removing the manager/token layer and restoring the routed calls, without an ABI or native-artifact migration.

## Effective-spec/Agent Notes adherence

The isolate lease and guarded terminal release implement FR-NP-01. The one-shot cleanup token, destructor-before-release rule, child ownership, borrowed-view exclusion, constructor rollback, and distinct transfer path implement FR-NP-05 and FL-NP-02. The strategy preserves memory safety, keeps raw pointer and lifecycle work in the binding layer, uses a specific native error for initialization failure, and requires documentation plus positive and negative tests for the public API. It keeps all artifacts in English and does not justify changes to generated declarations or `git2dart_binaries`.

# Rejected alternatives

Candidate B is rejected as the winner because its `finally` rule releases a logical owner even when destruction fails. That can make the owner count reach zero while a native resource remains live, allowing unsafe terminal shutdown. It also gives pure/global calls no transient pin. Its explicit `shuttingDown` state and remaining-count interpretation are retained as useful implementation details.

Candidate C is rejected as the winner because, although it correctly retains an owner after destructor failure, it tracks only persistent wrappers. `ensureInitialized()` alone does not mark an ownerless native call as active, so a reentrant shutdown path has no logical reason to reject. Its fail-closed shutdown-state handling and non-throwing-finalizer rule are retained.

Per-call or per-wrapper native leases are rejected because they retain the same ownership-classification burden while multiplying process-global refcount transitions and exception/finalizer failure paths. Deferred automatic shutdown is rejected because finalizer timing is nondeterministic and a returned shutdown request may never complete or surface a later failure. Transparent reinitialization is rejected until the specification defines replay of Android bootstrap and all process-global configuration.

# Required tests

1. In a fresh process/isolate, repeated `Libgit2.version`, another pure query, and a global option operation contribute exactly one native increment; successful shutdown removes exactly that lease; repeated shutdown does not decrement again.
2. A negative injected initialization result throws the expected specific native error, commits no active state or pin, and permits a later successful first initialization.
3. Shutdown during an injected/reentrant ownerless native operation is rejected while its transient pin is active and succeeds after the operation releases the pin.
4. Live representative root owners reject shutdown without changing the native count and remain usable after rejection; explicit cleanup followed by shutdown succeeds.
5. A derived owned child remains protected and usable after its parent is released; shutdown remains rejected until the child is released. Borrowed/materialized values do not create spurious owners.
6. Constructor validation and native-allocation failures roll back provisional protection without leaking an owner or masking the original error.
7. The cleanup token is one-shot across explicit cleanup, repeated cleanup, and fallback finalization. Native destruction precedes pin release.
8. Injected synchronous destructor failure is surfaced and retains the pin. Injected finalizer-side destructor failure does not throw from the callback, retains the pin, and is observable through the internal test/diagnostic seam.
9. Ownership transfer, including the stream transfer case, releases exactly one logical owner without invoking the transferred destructor; later cleanup cannot double-destroy.
10. Two coordinated isolates each contribute one native lease. Shutdown of one leaves the other usable and its lease intact; shutdown of the second restores the baseline.
11. Repeated Android/iOS bootstrap adds no extra increments, and Android CA plus representative global settings survive until terminal shutdown. Every native entry after successful terminal shutdown throws before making a native call.
12. Native shutdown failure or an unexpected result does not mark the manager terminal. A positive remaining count caused by another owner is accepted.
13. Run formatting, zero-warning analysis, focused lifecycle tests, the full Flutter suite, and the Windows, Linux, macOS, Android, and iOS matrix. Public `shutdown()` must have positive and negative API coverage and `///` documentation.

# Spec impact

No effective-spec verdict change is required. Clarify the design, flow, and test specifications with: one native lease per participating isolate; transient and persistent logical pins; fail-fast terminal shutdown; destructor-before-pin-release ordering; fail-closed destructor failure; constructor rollback; explicit versus fallback cleanup; distinct transfer semantics; derived-child independence; multi-isolate native-count composition; terminal platform-configuration epochs; and the requirement that normal isolate entry points invoke shutdown in `finally` after deterministic wrapper cleanup.

The new public `Libgit2.shutdown()` contract must document idempotence, live-pin rejection, terminal post-shutdown behavior, and responsibility for calling-isolate cleanup. No generated FFI, companion binary, or platform-loader specification change is supported by the locked evidence.

# Confidence

High in the lifecycle model and the choice of Candidate A. The deterministic count evidence, process-global/isolate-local boundary, and all three candidates converge on one isolate lease plus complete wrapper ownership. Confidence in a future implementation remains conditional on a demonstrated full ownership/transfer inventory and the required platform matrix; an omitted independently usable owner would still create a premature-shutdown hole.
