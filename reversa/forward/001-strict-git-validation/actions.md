# Actions: Strict Git Validation

> Identifier: `001-strict-git-validation`  
> Source: `requirements.md`, `roadmap.md`, `investigation.md`, and `data-delta.md`  
> Scope: local Dart validation only; no bindings, binaries, OpenSSL, or FFI changes.

## Phase 1 — Test-first ODB contract

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-001 | Add table-driven public-boundary tests for `Odb.write`, `Odb.writeDirect`, `Odb.hash`, and `Odb.hashFile`. Iterate `GitObject.values`; prove only `commit`, `tree`, `blob`, and `tag` pass local validation and every other enum value throws `ArgumentError`. Use a deliberately unusable native receiver where practical to prove rejected inputs do not invoke a native operation. Covers FR-01, FR-02, and FR-05. | none | parallel with A-002 and A-003 | `test/odb_test.dart` | High | [X] |

## Phase 2 — Test-first reference-name contract

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-002 | Add data-driven valid-name tests for `HEAD`, `ORIG_HEAD`, `refs/heads/main`, `refs/tags/v1.0`, and `refs/remotes/origin/main`, asserting local validation accepts each representative before the existing native path. Covers FR-04. | none | parallel with A-001 and A-003 | `test/reference_test.dart` | High | [X] |
| A-003 | Add data-driven invalid-name tests for every affected public input position: `create`, `createMatching`, `lookup`, `delete`, `remove`, `rename`, `setTarget`, `ensureLog`, and `nameToId`, including `setTarget` direct-target and symbolic target/current-target positions. Cover `..`, `@{`, prohibited characters, empty components, leading-dot components, and `.lock` component suffixes; require `ArgumentError` and use an unusable native receiver where possible to prove FFI is not reached. Covers FR-03 and FR-05. | none | parallel with A-001 and A-002 | `test/reference_test.dart` | High | [X] |

## Phase 3 — Local validation implementation and public docs

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-004 | Replace the partial writable-object deny-list with one finite allow-list accepting exactly `commit`, `tree`, `blob`, and `tag` for `write`, `writeDirect`, `hash`, and `hashFile`. Preserve valid native behavior, throw `ArgumentError` for every other enum value, and update public API documentation to state accepted types and local failure behavior. Covers FR-01, FR-02, and FR-06. | A-001 | parallel with A-005 after its own test prerequisites | `lib/src/odb.dart` | High | [X] |
| A-005 | Add one private reference-name validator implementing the approved Git syntax rules and documented `HEAD`-style top-level exception; otherwise require a non-empty `refs/` hierarchy. Invoke it before every name parameter in `create`, `createMatching`, `lookup`, `delete`, `remove`, `rename`, `setTarget`, `ensureLog`, and `nameToId`, including symbolic target/current-target inputs. Preserve valid native errors after syntax validation succeeds, and update affected public documentation to promise `ArgumentError` for invalid names. Covers FR-03 through FR-06. | A-002, A-003 | parallel with A-004 after its own test prerequisites | `lib/src/reference.dart` | High | [X] |

## Phase 4 — Focused regression verification

| ID | Description | Dependencies | Parallelism | Target file | Confidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| A-006 | Run `flutter test -j 1 test/odb_test.dart` after A-004. Record and resolve only failures caused by finite ODB-type validation. Covers FR-01, FR-02, and FR-05. | A-004 | parallel with A-007 | `test/odb_test.dart` | High | [X] |
| A-007 | Run `flutter test -j 1 test/reference_test.dart` after A-005. Confirm invalid syntax raises `ArgumentError` before native execution and representative valid names retain existing native behavior. Covers FR-03 through FR-06. | A-005 | parallel with A-006 | `test/reference_test.dart` | High | [X] |
| A-008 | Run `dart format --output=none --set-exit-if-changed lib/src/odb.dart lib/src/reference.dart test/odb_test.dart test/reference_test.dart`, `flutter analyze`, and `flutter test -j 1 test/odb_test.dart test/reference_test.dart`. Verify the diff is limited to the four planned files and contains no bindings, binaries, OpenSSL, FFI, secrets, worktree, commit, or push changes. Covers roadmap exit criteria. | A-006, A-007 | sequential final gate | `lib/src/odb.dart`, `lib/src/reference.dart`, `test/odb_test.dart`, `test/reference_test.dart` | High | [X] |

## Execution notes

Reserved for `/reversa-coding` to record implementation-specific decisions, failures, and deviations from this plan.

## Change history

- 2026-08-24 — Reformatted the approved eight-action plan into phase tables with required checkpoint columns.
