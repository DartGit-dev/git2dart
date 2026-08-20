# Domain Model and Implicit Rules

> Detective interpretation for documentation level **Detailed**. Git history and code are treated as different evidence sources. Commit messages establish intent only where corroborated by the resulting code or documentation.

## Domain Purpose

`git2dart` provides an idiomatic, null-safe Dart model over libgit2 while preserving native performance and explicit memory safety. The domain is not a hosted Git service: it has no users, authorization database, HTTP endpoints, or server-side RBAC. Its consumers are Dart and Flutter applications that operate on local or remote Git repositories.

## Glossary

| Term | Meaning in this system | Confidence |
| --- | --- | --- |
| Repository | Aggregate root wrapping a `git_repository*` and exposing Git state and child objects | 🟢 CONFIRMED |
| OID | SHA-based immutable Git object identifier; APIs accept full or sufficiently long hexadecimal prefixes | 🟢 CONFIRMED |
| Git object | Immutable commit, tree, blob, or annotated tag stored in an object database | 🟢 CONFIRMED |
| Reference | Mutable direct OID name or symbolic name pointing to another reference | 🟢 CONFIRMED |
| Index | Mutable staging area and three-way conflict store between objects and working directory | 🟢 CONFIRMED |
| Working directory | Materialized filesystem view associated with a non-bare repository | 🟢 CONFIRMED |
| Refspec | Fetch/push mapping between source and destination reference patterns | 🟢 CONFIRMED |
| Binding | Hand-written adapter that performs C calls, allocation, conversion, and error checks | 🟢 CONFIRMED |
| Companion binaries | `git2dart_binaries`, which supplies native libgit2 artifacts and generated declarations | 🟢 CONFIRMED |
| Owned pointer | Native object that must be released explicitly or by an attached finalizer | 🟢 CONFIRMED |
| Borrowed pointer | Native view valid only while its parent object/callback remains alive | 🟢 CONFIRMED |

## Implicit Domain Rules

### Object and repository integrity

1. 🟢 A commit tree and all parent commits must belong to the target repository; strict native object creation is enabled by default.
2. 🟢 A root commit has zero parents; parent ordering is preserved for non-root and merge commits.
3. 🟢 Git objects are immutable; amend, tree update, and commit creation return new OIDs instead of mutating stored objects.
4. 🟢 Only concrete object types (commit, tree, blob, tag) may be written or hashed through ODB APIs; pseudo/delta types are rejected.
5. 🟢 `Index.writeTree` requires a conflict-free index.
6. 🟢 Working-directory mutations require a non-bare repository.

### References and history

7. 🟢 Direct references carry OIDs; symbolic references carry reference names. Compare-and-set updates require expected and desired targets of the same representation.
8. 🟢 Strict symbolic reference validation is enabled by default, though the global API can disable it.
9. 🟢 Revision walking requires at least one root and automatically resets after a completed walk.
10. 🟢 Range `A..B` semantics hide A and its ancestors and push B.
11. 🟢 Merge analysis must precede policy selection when the caller needs to distinguish up-to-date, fast-forward, unborn, and normal merge outcomes.
12. 🟢 A normal workdir merge leaves the repository in merge state until explicit cleanup.
13. 🟢 Rebase applies one operation at a time; conflicts must be resolved before committing that operation.

### Network and trust

14. 🟢 Remote credentials are typed by mechanism: plaintext user/password, SSH key files, SSH agent, or in-memory SSH keys.
15. 🟢 Default certificate validation remains active unless the caller supplies `certificateCheck`; the callback receives native validity and returns the final trust decision.
16. 🟢 Certificate and progress wrapper objects passed to callbacks are borrowed and must not escape their native callback lifetime.
17. 🟢 Android consumers must initialize SSL certificate support before cloning/fetching; iOS consumers must initialize platform support so statically linked symbols are loaded.
18. 🟢 Pack maximum object size is bounded by a configurable non-negative value to limit memory exposure to declared object sizes from untrusted remotes.

### Memory and ABI safety

19. 🟢 Negative libgit2 results become `LibGit2Error` through the shared error helper.
20. 🟢 Short-lived native inputs/outputs should use an arena; persistent wrappers pair explicit `free()` with a finalizer safety net.
21. 🟢 No raw native pointer is part of the package barrel's public consumer API; pointer accessors are marked internal.
22. 🟢 `git2dart_binaries` is constrained to a compatible minor line, and dependency upgrades have a dedicated public-API comparison workflow.
23. 🟡 Process-global libgit2 options and static callback bridge fields imply that conflicting concurrent configuration/callback installations should be serialized unless proven safe by dynamic testing.

### Testing and delivery

24. 🟢 The normal quality gate is formatting, zero-warning analysis, and Flutter tests across desktop and mobile targets.
25. 🟢 Tests tagged `remote_fetch` are skipped by default because they require network access; therefore the normal suite is not independent proof of live remote interoperability.
26. 🟢 Generated FFI declarations are not regenerated in this repository.
27. 🟡 The broad expansion commits show a preference for thin, directly testable wrappers that mirror libgit2 capabilities rather than a higher-level Git workflow abstraction.

## Git Archaeology Timeline

| Date | Commit | Evidence and interpretation | Confidence |
| --- | --- | --- | --- |
| 2025-05-13 | `cc3efa9` | Reworked 46 files around `using`/arena and centralized error checks; establishes deterministic temporary memory as a design rule | 🟢 |
| 2025-05-17 | `62f9f82` | Dart 3 and libgit2 1.9 migration removed deprecated API and fixed merge OID-array count | 🟢 |
| 2025-05-17 | `37c3c41` | Continued arena migration and remote credential/error hardening | 🟢 |
| 2025-05-17 | `ca11459` | Standardized OID operations on SHA-1-era bindings and simplified merge/OID signatures; later code restored SHA-256-aware validation where supported | 🟢 |
| 2025-06-09 | `13a11d7`, `da99657` | Isolated network-dependent tests behind `remote_fetch` | 🟢 |
| 2025-06-10 | `f4d4a44` | Added a finalizer to streaming blob writes, reinforcing persistent-resource ownership policy | 🟢 |
| 2025-06-11 | `6c10aeb` | Expanded worktree operations with corresponding tests | 🟢 |
| 2025-11-20 | `bbd2bd3` lineage | Added Android SSL initialization through companion binaries | 🟢 |
| 2026-01-01 | `45f21a7` | Added Android execution to CI, turning mobile support into an enforced platform target | 🟢 |
| 2026-05-30 | `83ca090` | Added iOS support and unified `PlatformSpecific.initialize()` | 🟢 |
| 2026-06-29 | `b422c95` | Added caller-controlled certificate trust callback, especially for SSH environments without usable `known_hosts` | 🟢 |
| 2026-06-29 | `b62d34f` | Added 4,125 lines across 68 files to expand binding coverage with focused tests | 🟢 |
| 2026-07-21 | `a725bac` | Added pack object-size safety option and a dependency API comparison tool/skill | 🟢 |

No explicit revert commit was found in the inspected history. Several test-only fixes reveal expected cross-platform behavior, especially normalized paths and repository status transitions.

## Log Evidence

`test_run.log` records a historical run ending with `919` passing tests and `24` skipped tests. Its filesystem timestamp is 2026-06-29, so it is prior evidence only and does not prove the current worktree or current dependency baseline passes. No application/runtime business logs exist because this repository is a library.

## Gaps Requiring Human or Dynamic Validation

- 🔴 Whether static callback bridge fields are safe for overlapping remote operations with distinct callbacks.
- 🔴 Live SSH/HTTPS behavior on each target platform with current native binaries.
- 🔴 Complete allocation/free audit across every native error branch.
- 🔴 Whether SHA-256 object-format repositories are fully supported end to end, beyond validation and selected bindings.
- 🔴 Whether `remote_fetch` tests are exercised in a separate trusted network CI job.

