# Native Runtime and Platform Boundary Depth Inspection

## Scope and Feature Map

### Specifications

- `reversa/sdd/native-runtime-and-platform-boundary/` with requirements, design, tasks, flows, edge cases, questions, and tests.
- Cross-cutting architecture and domain rules for native ownership, callbacks, global options, and platform loading.
- ADR-001, ADR-003, ADR-004, and ADR-005.

### Code

- Runtime and global options: `lib/src/libgit2.dart`.
- Platform bootstrap: `lib/src/platform_specific.dart`.
- Error and marshalling helpers: `lib/src/helpers/error_helper.dart`, `lib/src/extensions.dart`, and `lib/src/error.dart`.
- Callback bridge: `lib/src/bindings/remote_callbacks.dart` and its remote, clone, and submodule call sites.
- Persistent ownership: representative wrappers and binding adapters across `lib/src/`.

### Tests

- `test/libgit2_test.dart`, `test/platform_specific_test.dart`, `test/callbacks_test.dart`.
- Remote, credential, and explicit release coverage in feature tests.
- Missing characterization groups include shutdown balance, native negative option results, initializer mismatch, callback overlap, exception cleanup, repeated release, sanitizer runs, and repeated mobile initialization.

### Data and External Contracts

- Process-global libgit2 options and initialization counter.
- Native handles, arenas, finalizers, manual buffers, and callback payloads.
- `git2dart_binaries` ABI declarations and native artifacts as a consumed dependency only. No state from the companion repository was used.
- Android CA material and iOS native symbol loading.

### Existing Bugs and Dedupe

The registry was empty before this inspection. All seven findings have distinct failure mechanisms and test surfaces, so none was merged as a duplicate. They form one structural native lifecycle and callback-state cluster.

## Findings by Lens

### Specification Conformity

```yaml
- finding_id: F-SPEC-01
  lens: specification-conformity
  summary: Repeated libgit2 initialization has no matching shutdown lifecycle.
  confidence: high
  evidence: [lib/src/libgit2.dart:20, repository-wide init/shutdown search, FR-NP-01]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: BUG-20260817-ZC7X
- finding_id: F-SPEC-02
  lens: specification-conformity
  summary: Global option calls violate the immediate negative-result translation rule.
  confidence: high
  evidence: [lib/src/libgit2.dart:95-568, BR-NP-03, ADR-004]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: BUG-20260817-DQPX
- finding_id: F-SPEC-03
  lens: specification-conformity
  summary: Options initializer failures are not checked before structure use.
  confidence: high
  evidence: [lib/src/bindings, FR-NP-03, FR-NP-04, FR-NP-09]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: BUG-20260817-QWMA
```

### Data Flow and Ownership

```yaml
- finding_id: F-DATA-01
  lens: data-flow
  summary: Native extension strings lose their required disposer.
  confidence: high
  evidence: [lib/src/libgit2.dart:521-535, correct repository disposal patterns]
  suspected_severity: medium
  signals: [data-corruption=false, operational-risk]
  promoted_to: BUG-20260817-3PON
- finding_id: F-DATA-02
  lens: data-flow
  summary: Credential callback allocations have no release owner.
  confidence: high
  evidence: [lib/src/bindings/remote_callbacks.dart:185-201, lib/src/bindings/remote_callbacks.dart:290-297]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: BUG-20260817-47ZS
- finding_id: F-DATA-03
  lens: data-flow
  summary: Borrowed callback objects can escape through user closures without a runtime guard.
  confidence: medium
  evidence: [lib/src/remote.dart:402-443, native edge case EC-NP-14]
  suspected_severity: high
  signals: [intermittency, operational-risk]
  promoted_to: null
```

### Contracts and Integrations

```yaml
- finding_id: F-CONTRACT-01
  lens: contracts-and-integrations
  summary: ABI options version failures do not stop dependent calls.
  confidence: high
  evidence: [unchecked options initializer inventory, native test matrix]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: BUG-20260817-QWMA
- finding_id: F-CONTRACT-02
  lens: contracts-and-integrations
  summary: Current five-platform ABI and loader execution remains unavailable.
  confidence: high
  evidence: [confidence-report.md, focused runner blocker]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: null
```

### Error States and Edge Cases

```yaml
- finding_id: F-ERROR-01
  lens: error-states-and-edge-cases
  summary: Remote failure exits before sensitive callback cleanup.
  confidence: high
  evidence: [restricted canonical evidence]
  suspected_severity: high
  signals: [security, operational-risk]
  promoted_to: BUG-20260817-O3B3
- finding_id: F-ERROR-02
  lens: error-states-and-edge-cases
  summary: A null git_error_last fallback is not implemented or characterized.
  confidence: medium
  evidence: [lib/src/helpers/error_helper.dart:5-8, EC-NP-08]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: null
- finding_id: F-ERROR-03
  lens: error-states-and-edge-cases
  summary: Callback exception mapping and cleanup remain uncharacterized.
  confidence: medium
  evidence: [remote callback bridges, EC-NP-15]
  suspected_severity: high
  signals: [intermittency, operational-risk]
  promoted_to: null
- finding_id: F-ERROR-04
  lens: error-states-and-edge-cases
  summary: Repeated and post-free wrapper behavior has no universal guard.
  confidence: high
  evidence: [representative wrapper free methods, EC-NP-25]
  suspected_severity: high
  signals: [operational-risk]
  promoted_to: null
```

### Test Coverage

```yaml
- finding_id: F-TEST-01
  lens: test-coverage
  summary: Existing tests cover successful global options but not native negative results.
  confidence: high
  evidence: [test/libgit2_test.dart]
  suspected_severity: medium
  signals: [operational-risk]
  promoted_to: null
- finding_id: F-TEST-02
  lens: test-coverage
  summary: Platform tests prove only completion on the current host and do not characterize repeated or concurrent mobile initialization.
  confidence: high
  evidence: [test/platform_specific_test.dart:5-20, Q12]
  suspected_severity: medium
  signals: [intermittency, operational-risk]
  promoted_to: null
- finding_id: F-TEST-03
  lens: test-coverage
  summary: No sanitizer, overlap, ABI mismatch, or post-free characterization exists.
  confidence: high
  evidence: [native test specification, repository test inventory]
  suspected_severity: high
  signals: [intermittency, operational-risk]
  promoted_to: null
```

### Concurrency and Consistency

```yaml
- finding_id: F-CONC-01
  lens: concurrency-and-consistency
  summary: Overlapping operations overwrite process-static callback state.
  confidence: high
  evidence: [lib/src/bindings/remote_callbacks.dart:21-312, all plug call sites]
  suspected_severity: high
  signals: [intermittency, operational-risk]
  promoted_to: BUG-20260817-CIKD
- finding_id: F-CONC-02
  lens: concurrency-and-consistency
  summary: Process-global option mutation has no snapshot, lock, or supported concurrency contract.
  confidence: high
  evidence: [lib/src/libgit2.dart, Q1]
  suspected_severity: high
  signals: [intermittency, operational-risk]
  promoted_to: null
```

## Conditional Lenses

- Security and trust was activated because callback state can hold credential objects. The promoted security finding is restricted and details are omitted here.
- Configuration and platform drift was activated for global options, ABI versioning, and mobile initialization.
- Observability was activated because ignored return codes convert native failure into apparent success.
- Performance was not activated as a separate lens. Resource retention findings were handled by ownership and lifecycle lenses.

## Clusters

The strongest cluster is native lifecycle and process-global state. BUG-20260817-ZC7X, BUG-20260817-DQPX, BUG-20260817-QWMA, BUG-20260817-3PON, BUG-20260817-47ZS, and BUG-20260817-CIKD converge on missing centralized ownership of runtime state, fallible status handling, and callback resources. The restricted finding belongs to the same cluster but is excluded from public detail.

## Confidence Update

The formal extraction metrics remain unchanged at 78.6 percent overall and 67.1 percent for this unit because original specifications are read-only. Diagnostic confidence increased for seven concrete paths: six high-severity and one medium-severity canonical bugs now carry static causal evidence. Q12, sanitizer certification, live overlap reproduction, and the five-platform ABI matrix remain gaps.

## Not Covered

- Fresh Flutter tests did not run. Both `flutter test` and `dart --version` stalled without output.
- Read-only diagnostics found stale Flutter cache lock files with no active Dart or Flutter process. They were not removed because they are outside the repository.
- No sanitizer, fault-injection, external network, mobile device, or ABI mismatch harness was used.
- No source or test file was created or modified.
