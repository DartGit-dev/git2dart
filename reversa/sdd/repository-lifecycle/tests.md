# Repository Lifecycle — Test Specification

> 🟢 **CONFIRMED** — This specification separates legacy test evidence from tests still required for full confidence. A listed legacy test proves intent and prior coverage, not a fresh pass in the current extraction.

## Test Strategy

| Layer | Purpose | Fixture policy | Confidence |
| --- | --- | --- | --- |
| Wrapper unit/integration | Verify typed behavior against real libgit2 repository state. | Use isolated temporary repositories from `test/helpers/util.dart`. | 🟢 CONFIRMED |
| Negative native behavior | Verify translated errors for invalid path, state, target, or operation. | Create controlled invalid/missing repository/worktree state. | 🟢 CONFIRMED |
| Ownership characterization | Verify explicit/finalizer cleanup and error-path resource handling. | Use native instrumentation or destructor counters where feasible. | 🔴 GAP |
| Cross-platform | Verify path, loader, filesystem, Android CA, and iOS static-link behavior. | Run through the declared GitHub Actions platform matrix. | 🟢 CONFIRMED as policy; 🔴 GAP for a fresh run |
| Live remote | Verify clone callbacks, HTTPS/SSH, credentials, and certificate decisions. | Run only in a controlled network suite with disposable remotes/secrets. | 🔴 GAP |

## Legacy Coverage Map

| Area | Legacy evidence | Positive behavior | Negative behavior | Confidence |
| --- | --- | --- | --- | --- |
| Init/open/discover | `test/repository_test.dart:37-74`, `119-132` | Basic, bare, extended open, discovery | Not found / invalid search | 🟢 CONFIRMED |
| Config/index/ODB | `test/repository_test.dart:29-102` | Live and snapshot access, replacement | Replacement failure | 🟢 CONFIRMED |
| HEAD | `test/repository_test.dart:165-246` | Symbolic, OID, unborn, detach | Invalid type, missing target, detach failure | 🟢 CONFIRMED |
| Metadata/status/state | `test/repository_test.dart:134-164`, `248-337` | Namespace, workdir, OID type, status, cleanup | Invalid workdir/path, bare status, cleanup failure | 🟢 CONFIRMED |
| Attributes/graph | `test/repository_test.dart:349-457` | Lookup, multiple, iteration, helpers, ahead/behind | Callback/binding errors | 🟢 CONFIRMED |
| Ownership/value | `test/repository_test.dart:459-468` | Manual release, equality/string | No repeated-free contract | 🟢 CONFIRMED / 🔴 GAP |
| Worktrees | `test/worktree_test.dart:32-238` | Create, lookup, lock, prune, open, validate | Invalid names/paths, lookup/list/head errors | 🟢 CONFIRMED |
| Commit-on-HEAD | `lib/src/extensions/repository.dart` | Flow exists in code | Dedicated test not identified | 🔴 GAP |

## Required Scenarios

| ID | Scenario | Expected assertion | Requirement | Confidence |
| --- | --- | --- | --- | --- |
| TS-RL-01 | Initialize non-bare and bare repositories | Returned wrapper reports expected paths and bare state. | FR-RL-01 | 🟢 CONFIRMED |
| TS-RL-02 | Open standard, extended, and bare repositories | Each valid mode acquires the intended repository. | FR-RL-03 | 🟢 CONFIRMED |
| TS-RL-03 | Discover from nested path and enforce ceiling | Valid path resolves; excluded/missing repository throws. | FR-RL-02 | 🟢 CONFIRMED |
| TS-RL-04 | Set HEAD using String and Oid | String is symbolic; Oid is detached. | FR-RL-06 | 🟢 CONFIRMED |
| TS-RL-05 | Set HEAD using invalid runtime type | `ArgumentError` is thrown before native dispatch. | FR-RL-06 | 🟢 CONFIRMED |
| TS-RL-06 | Read multi-bit and renamed status | All non-zero flags are present and renamed path uses new path. | FR-RL-09 | 🟢 CONFIRMED |
| TS-RL-07 | Read current and bare status | Current maps to empty set; bare status throws. | FR-RL-09 | 🟢 CONFIRMED |
| TS-RL-08 | Cleanup active repository state | Success returns state to none; injected failure throws. | FR-RL-14 | 🟢 CONFIRMED |
| TS-RL-09 | Execute reset/default reset | Valid projections change; missing target fails; null default target is accepted. | FR-RL-11 | 🟢 CONFIRMED |
| TS-RL-10 | Access and replace child subsystems | Typed wrappers are returned; invalid replacement throws. | FR-RL-08 | 🟢 CONFIRMED |
| TS-RL-11 | Walk history with sorting | Returned commits follow selected traversal from supplied OID. | FR-RL-10 | 🟢 CONFIRMED |
| TS-RL-12 | Evaluate attributes and graph distance | Values/counts match repository fixtures; invalid callback path throws. | FR-RL-12/13 | 🟢 CONFIRMED |
| TS-RL-13 | Worktree full lifecycle | Create/list/lookup/lock/unlock/validate/prune/open/free behave as specified. | FR-RL-15/17 | 🟢 CONFIRMED |
| TS-RL-14 | Worktree invalid inputs | Invalid name/path/lookup/head/list conditions throw. | FR-RL-15 | 🟢 CONFIRMED |
| TS-RL-15 | Commit on HEAD | Tree content, parent, signatures, message, and HEAD advance are verified. | FR-RL-16 | 🔴 GAP |
| TS-RL-16 | Commit-on-HEAD failure after partial staging | Error and residual index state are captured and documented. | FR-RL-16 | 🔴 GAP |
| TS-RL-17 | Manual release and finalizer detachment | Native destructor is not invoked twice in supported lifecycle. | FR-RL-17 | 🟢 CONFIRMED for manual test; 🔴 GAP for instrumentation |
| TS-RL-18 | Repeated free/post-free method | Behavior is characterized before any safety guarantee is made. | G-RL-02 | 🔴 GAP |
| TS-RL-19 | SHA-1/SHA-256 matrix | Open/status/log/reset/hash/describe/pack results are recorded per format. | G-RL-03 | 🔴 GAP |
| TS-RL-20 | Live clone matrix | HTTPS/SSH, credentials, certificate callback, proxy, and five platforms are recorded. | G-RL-04 | 🔴 GAP |
| TS-RL-21 | Concurrent operation characterization | Shared repository/global/callback state is tested for isolation or explicitly rejected. | G-RL-01 | 🔴 GAP |

## Acceptance-Test Examples

🟢 **CONFIRMED**

```gherkin
Dado a temporary directory and valid repository initialization options
Quando Repository.init creates the repository and Repository.open reopens it
Então both wrappers expose the same repository metadata path and expected bare state
```

🟢 **CONFIRMED**

```gherkin
Dado a repository with one renamed path and multiple status bits
Quando Repository.status materializes the native status list
Então the new path is mapped to every applicable non-zero GitStatus value
```

🟢 **CONFIRMED**

```gherkin
Dado a valid linked worktree
Quando it is locked, unlocked, validated, opened, and pruned when eligible
Então each native administrative transition is observable through the typed API
```

🔴 **GAP**

```gherkin
Dado a repository wrapper already released explicitly
Quando free or another repository method is invoked again
Então the intended supported behavior must be decided and verified before compatibility is claimed
```

## Quality Gates

- 🟢 **CONFIRMED** — Format checks must pass with no changes required.
- 🟢 **CONFIRMED** — `flutter analyze` must report zero warnings/information under the project policy.
- 🟢 **CONFIRMED** — Repository/worktree tests must pass on Linux, macOS, Windows, Android, and iOS targets declared by CI.
- 🟢 **CONFIRMED** — Default test success must be reported separately from live-network success because `remote_fetch` is skipped by default.
- 🔴 **GAP** — No fresh test execution was performed during Writer generation.

## Test Data and Cleanup

- 🟢 **CONFIRMED** — Tests should use temporary repositories and the in-memory/fixture helper rather than user repositories.
- 🟢 **CONFIRMED** — Each test must release wrappers or remove its isolated temporary fixture through the test helper lifecycle.
- 🟢 **CONFIRMED** — Tests requiring network or secrets must use disposable credentials/remotes and must not log secrets.
- 🟡 **INFERRED** — Native leak characterization may require a dedicated instrumented binary unavailable in the normal package test job.

