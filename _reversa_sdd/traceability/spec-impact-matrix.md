# Spec Impact Matrix

> This matrix predicts the architectural blast radius of specification changes. `D` means direct impact, `I` means indirect/contract impact, and `—` means no normal impact identified. It is a planning aid, not proof that every source call path has been dynamically exercised.

## Feature-to-Component Impact

| Specification unit | Public facade | Repository lifecycle | Objects and ODB | Worktree and index | References and remotes | History and integration | Native boundary | Platform/runtime | Tests and CI |
| --- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Repository lifecycle | D | D | I | I | I | I | D | I | D |
| Git objects and object database | D | I | D | I | I | I | D | I | D |
| Working tree and index | D | I | I | D | — | I | D | I | D |
| References and remotes | D | I | I | — | D | I | D | D | D |
| History and integration operations | D | D | D | D | I | D | D | I | D |
| Native runtime and platform boundary | I | I | I | I | I | I | D | D | D |

## Component Coupling Matrix

| Changed component | Directly impacted dependents | Typical regression surface | Confidence |
| --- | --- | --- | --- |
| Public API facade | Consumer imports and all published symbols | API availability, semantic versioning, documentation | 🟢 CONFIRMED |
| Repository lifecycle | Most repository-associated wrappers and integration operations | open/init/clone, state, status, reset, worktrees | 🟢 CONFIRMED |
| Objects and ODB | Index/tree flows, refs, revision parsing, merge/rebase, pack building | OID conversion, object kind dispatch, ownership | 🟢 CONFIRMED |
| Working tree and index | Checkout, diff apply, merge, rebase, stash | conflict state, filesystem mutation, tree serialization | 🟢 CONFIRMED |
| References and remotes | Branch tracking, fetch/push, clone, submodules | ref updates, callbacks, authentication, trust | 🟢 CONFIRMED |
| History and integration | Repository state, index/workdir, objects, refs | merge/rebase sequencing, graph traversal, cleanup | 🟢 CONFIRMED |
| Shared types/errors | Every high-level and binding component | enum values, bitmasks, exception compatibility | 🟢 CONFIRMED |
| Native binding adapters | Corresponding wrapper plus native runtime | allocation, conversion, result interpretation | 🟢 CONFIRMED |
| Callback infrastructure | Clone, remote operations, submodules | credentials, certificates, transfer/update progress | 🟢 CONFIRMED |
| Platform/global runtime | Android/iOS startup and process-wide behavior | CA location, symbol loading, global options | 🟢 CONFIRMED |
| `git2dart_binaries` dependency | Every binding and supported platform | declaration compatibility, ABI, native packaging | 🟢 CONFIRMED |

## High-Risk Change Scenarios

| Change scenario | Required specification review | Required implementation/test review | Risk |
| --- | --- | --- | --- |
| Upgrade `git2dart_binaries` | Native boundary, dependency ADR, all changed declarations | API comparison report, affected adapters, desktop/mobile tests | Very high |
| Change OID representation or hash support | Objects/ODB, refs/remotes, history, ERD, domain rules | parse/lookup/shorten, object creation, remote advertisement tests | Very high |
| Change callback bridge | Remotes, permissions, state machine, container/component diagrams | credentials, certificate, progress, concurrency and lifetime tests | Very high |
| Change ownership/finalizer policy | Native boundary, ADR-003, every affected entity | success/error path leak and double-free tests | Very high |
| Change index conflict semantics | Worktree/index, merge/rebase state machines | conflict, REUC, write-tree, merge/rebase tests | High |
| Add destructive repository operation | Repository/domain/permissions | negative tests, force/default behavior, state cleanup | High |
| Change platform initialization | Containers, external integrations, deployment applicability | Android/iOS device tests and packaging | High |
| Change public export | Facade and affected feature specification | static analysis, API compatibility, positive/negative tests | High |
| Change CI publication policy | Quality/delivery architecture and permissions | workflow validation, dry-run, secret/branch control review | High |

## External Integration Impact

| Integration | Affected specs/components | Contract-sensitive changes | Validation gap |
| --- | --- | --- | --- |
| libgit2 / generated declarations | Native boundary and every binding-backed feature | Function signatures, struct layouts, enum values, ownership | Full ABI compatibility is not proven by static version constraints alone |
| Local filesystem/Git format | Repository, objects, worktree/index, submodules | Paths, permissions, object format, worktree semantics | Cross-platform edge cases require runtime tests |
| HTTPS/SSH remotes | References/remotes, callbacks, platform runtime | Credentials, certificates, proxy, refspec, pack limits | Default suite skips network-dependent tests |
| Android/iOS runtime | Platform bootstrap, native packaging | CA extraction, static symbols, device ABI | Requires device/emulator validation |
| GitHub Actions/pub.dev | Tests, CI, publication permissions | Action versions, branch conditions, tokens, dry-run | External branch protection and approval rules not inspected |

## Traceability Baseline

| Architectural unit | Primary extracted evidence | Expected Writer specification unit |
| --- | --- | --- |
| Repository lifecycle | `code-analysis.md`, repository flowcharts, `domain.md` | `repository-lifecycle` |
| Git objects and ODB | `data-dictionary.md`, object/ODB flowcharts, ADR-003 | `git-objects-and-object-database` |
| Working tree and index | conflict state machine, diff/index flowcharts | `working-tree-and-index` |
| References and remotes | remote state machine, `permissions.md`, ADR-006 | `references-and-remotes` |
| History and integration | repository/rebase state machines, merge/rebase flowcharts | `history-and-integration-operations` |
| Native runtime/platform | native lifecycle, ADR-001/003/004/005, dependencies | `native-runtime-and-platform-boundary` |

