---
protocol_version: 1
debate_id: BUG-20260817-ZC7X-repair-20260821
bug_id: BUG-20260817-ZC7X
role: solver
solver_id: agent-2
engine: local
round: 1
status: ok
started_at: 2026-08-21T23:21:00+07:00
finished_at: 2026-08-21T23:23:43+07:00
---

## Fix strategy

Retain the round-0 core: one native initialization lease per Dart isolate,
plus one logical owner token for every independently usable native wrapper.
After comparing the other proposals, make shutdown synchronous, fail-fast,
idempotent, and terminal for that isolate. Do not defer shutdown to a finalizer,
silently cancel it on later use, or perform native init/shutdown for every
wrapper and pure call.

Implement one private `_Libgit2Runtime` with four explicit states:
`uninitialized`, `active`, `shuttingDown`, and `terminated`.

1. `ensureInitialized()` is the only path to `git_libgit2_init()`. It calls the
   native function once when moving from `uninitialized` to `active`, checks a
   negative return immediately with the existing error translation, and leaves
   the state `uninitialized` on failure. Repeated current entry points reuse
   the same isolate lease instead of incrementing the native counter.
2. `acquireOwner()` ensures the runtime before the first native call and
   creates a logical token. Successful native construction transfers that
   token into a managed finalizer payload. Constructor validation/native
   failure releases the token without registering an owner. The isolate's one
   native lease itself remains owned until explicit shutdown.
3. Replace existing pointer-only finalizers with a small private managed
   finalizer adapter. Its token contains the pointer, destructor, logical
   owner, and one-shot state. Explicit `free()` and fallback finalization use
   the same cleanup operation: destroy the native object first, then release
   the logical owner in `finally`. Repeated cleanup cannot run the destructor
   or decrement the owner count twice.
4. Classify every ownership-producing path, rather than changing only the 18
   constructors that currently call init:
   - standalone/root owned objects acquire before native construction;
   - derived owned or duplicated objects acquire a new logical token while the
     source wrapper keeps the isolate runtime alive during construction;
   - truly borrowed or fully materialized Dart views acquire no owner and must
     not outlive an undocumented parent boundary;
   - transferred ownership detaches the old finalizer and releases its logical
     owner without running the destructor. `BlobWriteStream.detach()` is the
     concrete transfer case that must use this path.
5. Route all 66 direct init sites through the manager. Pure queries and
   `Merge.file` call `ensureInitialized()` but do not create owner tokens.
   Persistent global options also reuse the isolate lease. This preserves
   Android CA and other process-global settings between calls.
6. Add documented `Libgit2.shutdown()`. If the isolate never initialized or
   already terminated, it is a no-op. If any logical owner remains, it throws
   `StateError` and does not call native shutdown. Otherwise it calls
   `git_libgit2_shutdown()` exactly once, surfaces a negative result, and marks
   the isolate terminal only after success. A positive remaining native count
   is valid because another isolate or external consumer may own another
   lease.
7. All later git2dart native entry points in the terminated isolate throw a
   clear `StateError`. Reinitialization is deliberately excluded from this
   repair because it would require replaying Android bootstrap and every
   process-global option. A separately specified runtime-generation API can be
   added later if consumers demonstrate that need.

This is the smallest coherent safe repair despite the ownership audit. A
partial registry cannot prove shutdown safety, while native leases on every
call and wrapper add the same audit plus far more native counter transitions.
No generated FFI declaration, companion binary, or platform loader changes.

## Causa raiz proposta

The cause remains confirmed: 66 public entry points acquire process-global,
reference-counted initialization without assigning the increment to a call,
wrapper, isolate, or application shutdown path. Initialization failures are
also ignored. Pointer finalizers currently own only native destructors, so no
existing lifecycle boundary can prove that native shutdown is safe.

The key repair implication is that a repository lease is not a lifetime proof
for children. A derived `Commit`, `Remote`, `Diff`, iterator, duplicate, or
stream can have its own finalizer and can survive the wrapper used to create
it. Therefore the package must protect one isolate lease with exact logical
owner tokens until every independently usable owned wrapper has completed its
destructor or transferred ownership.

## Teste

1. Convert the deterministic reproduction into a fresh-isolate regression:
   repeated `Libgit2.version`, another pure query, and a global option call add
   only one package-owned native initialization. Terminal shutdown removes
   exactly that one increment; a second shutdown does not decrement again.
2. Cover initialization failure through an injected private native adapter.
   A negative init result must throw `LibGit2Error`, cache no active state, and
   permit a later first initialization attempt.
3. For representative root families (`Repository`, `Config`, and one
   standalone `Diff`, `Patch`, `Mailmap`, `Odb`, or `Signature`), assert that
   shutdown with a live owner throws synchronously and leaves the native probe
   count unchanged. Explicit free followed by shutdown must balance once.
4. Add the discriminating parent/child test: create a repository and a commit
   or remote, free the repository, verify the child remains usable, and verify
   shutdown is rejected until the child is freed.
5. Test constructor rollback with `Config.open` on a missing path and an
   injected native allocation failure. Neither path may leave a logical owner.
6. Test one-shot cleanup directly: explicit free twice and explicit free
   followed by attempted finalizer cleanup cannot double-destroy or underflow
   the live-owner count. Destructor failure must still release the logical
   owner but surface the destructor error where synchronous.
7. Test `BlobWriteStream` transfer: successful commit releases the prior
   stream owner without calling its destructor; later cleanup cannot call it.
8. Coordinate two isolates with barriers. Each contributes one native lease.
   After the first isolate frees its owners and shuts down, the second remains
   usable and the process count retains its lease; final shutdown restores the
   baseline.
9. Keep repeated platform-bootstrap coverage and prove Android SSL settings
   survive ordinary later operations. After terminal shutdown, later use must
   fail rather than reinitialize with missing bootstrap state.
10. Run formatting, zero-warning analysis, the focused lifecycle suite, the
    full Flutter suite, and Windows, Linux, macOS, Android, and iOS CI.

## Impacto sobre a spec

FR-NP-01 gains one explicit isolate owner for native initialization/shutdown.
FR-NP-05 and FL-NP-02 gain an exact ordering rule: owned wrapper destructor,
then logical owner release; transfer releases the prior logical owner without
destruction; borrowed views never enter the owner state machine.

The runtime test specification should add repeated-call stability, negative
initialization, live-owner shutdown rejection, parent/child independence,
constructor rollback, transfer, one-shot cleanup, and multi-isolate tests. The
public `Libgit2.shutdown()` symbol requires documentation plus positive and
negative coverage. Terminal isolate semantics and the residual requirement
that normal isolate entry points call shutdown before exit should be explicit.
The effective spec needs clarification, not a verdict change.

## Riscos e efeitos colaterais

- The owner inventory is the principal implementation risk. The round-0 scan
  found 39 finalizer declarations across 30 files. Every independently usable
  owned result must be classified; missing one permits premature shutdown,
  while treating a borrowed view as owned can block shutdown.
- Dart finalizers are nondeterministic. They may delay successful shutdown, so
  deterministic callers must use existing `free()` methods. They never perform
  native shutdown automatically, which keeps delay fail-safe.
- Abrupt isolate termination can still strand one bounded native lease because
  an isolate-local Dart manager has no guaranteed shutdown hook. Solving that
  would require a compatible native shim or process coordinator and is outside
  the smallest repair. Normal isolate lifetimes must use `try/finally`.
- Terminal shutdown is conservative and opt-in. It prevents silent loss of
  Android CA and global options, but does not support multiple runtime epochs
  inside one isolate.
- Cleanup must be routed through the managed token. Merely adding logical
  decrement after existing `free()` calls would preserve double-free and
  underflow hazards.
- Global options and callbacks remain process-global and unsynchronized across
  isolates. This repair balances lifetime but does not close the documented
  concurrency gap.
- The adapter touches many wrapper files, but the change is mechanical,
  internal, and reversible; generated declarations and native artifacts remain
  untouched.

## Evidence

- Locked `problema.md`: 66 `git_libgit2_init()` calls, zero shutdown calls,
  deterministic count growth, process-global native state, isolate-local Dart
  statics, and unsafe premature shutdown are fixed facts.
- `bug.md`, `evidence/static-analysis.md`, `evidence/reproduction.md`,
  `evidence/reproduction_test.dart`, and `evidence/root-cause.md`, as assembled
  in the locked problem, establish the confirmed unbalanced lifecycle.
- The locked effective specification requires FR-NP-01 initialization/shutdown,
  FR-NP-05 one owner/destructor path, and FL-NP-02 explicit, fallback, and
  transfer release semantics.
- Frozen round-0 proposal 1 demonstrates the value of one native lease per
  isolate and a managed finalizer registry, while also exposing the need to
  define what a deferred shutdown call actually guarantees.
- Frozen round-0 proposal 3 demonstrates that global setters/platform
  bootstrap cannot be treated as temporary calls and that transfer requires a
  distinct ownership path.
- Official libgit2 contracts linked from the locked problem require init before
  other libgit2 calls and return the remaining initialization count from the
  matched shutdown operation.

## Confidence

high — all three round-0 proposals converge on explicit ownership and complete
wrapper classification. The revised isolate-lease design removes the observed
unbounded increments with fewer native transitions and a smaller public API
than per-call/per-wrapper native leases. Confidence is not absolute because
the 39-finalizer ownership inventory and abrupt isolate termination remain
real implementation limits that require audit evidence rather than assertion.

## Critique of the other proposals

### Proposal 1

The isolate lease, centralized manager, native error handling, managed
finalizers, and cross-isolate test are strong and align with the smallest
coherent direction. Deferring shutdown while wrappers remain is safer than
premature teardown, but its proposed observable contract is underspecified.
A synchronous `shutdown()` that merely records a request returns before the
requested operation happened and cannot surface a later native shutdown
failure. A future that waits for finalization may never complete because Dart
finalizers are not guaranteed. Silently canceling the request when a new owner
appears also tells the caller neither that shutdown failed nor that cleanup is
still owed. Fail-fast rejection gives the caller a deterministic correction:
free owners, then retry.

The proposal's reinitialization generation is also unsafe without a replay
contract for Android CA setup and all process-global options. Automatic later
use could successfully reinitialize libgit2 but run with lost platform/global
configuration. Terminal shutdown is a smaller and safer first repair.

### Proposal 3

The proposal correctly rejects a blind native shutdown, distinguishes
call/object/application lifetimes, requires constructor rollback, protects
derived children, and identifies platform/global settings as persistent. Its
opaque owner is safer than an untracked raw decrement.

However, a native lease for every pure call and every wrapper is not the
smallest low-risk repair. It retains the full ownership audit while adding
native counter transitions to every constructor, destructor, query, exception
path, and finalizer. The hybrid also needs a difficult classification between
stateless calls and operations whose effects depend on retained global state.
An application-scope owner introduces another public object and dependency
relationship that must still be connected to all wrappers or independently
leased around them. One isolate-owned native lease plus logical wrapper tokens
uses libgit2's process counter only at isolate boundaries, preserves global
settings, and provides the same premature-shutdown protection with fewer
failure points.
