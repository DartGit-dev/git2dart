# Code-to-Spec Matrix

> 🟢 **CONFIRMED** — Every Dart source file under `lib/` is assigned to a primary feature specification. `Direct` means the unit documents the file's principal behavior; `Supporting` means the file is cross-cutting or used by another primary feature. This is structural mapping, not dynamic execution proof.

## Public Facade and Shared Runtime

| Legacy file | Primary unit | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/git2dart.dart` | `native-runtime-and-platform-boundary/` | Supporting public export boundary | 🟢 CONFIRMED |
| `lib/src/error.dart` | `native-runtime-and-platform-boundary/` | Direct error types | 🟢 CONFIRMED |
| `lib/src/extensions.dart` | `native-runtime-and-platform-boundary/` | Direct marshalling helpers | 🟢 CONFIRMED |
| `lib/src/git_types.dart` | `native-runtime-and-platform-boundary/` | Direct enum/flag vocabulary | 🟢 CONFIRMED |
| `lib/src/helpers/error_helper.dart` | `native-runtime-and-platform-boundary/` | Direct native error translation | 🟢 CONFIRMED |
| `lib/src/libgit2.dart` | `native-runtime-and-platform-boundary/` | Direct runtime/global options | 🟢 CONFIRMED |
| `lib/src/platform_specific.dart` | `native-runtime-and-platform-boundary/` | Direct mobile bootstrap | 🟢 CONFIRMED |

## Repository Lifecycle

| Legacy file | Primary unit | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/src/repository.dart` | `repository-lifecycle/` | Direct aggregate/lifecycle operations | 🟢 CONFIRMED |
| `lib/src/worktree.dart` | `repository-lifecycle/` | Direct linked-worktree lifecycle | 🟢 CONFIRMED |
| `lib/src/config.dart` | `repository-lifecycle/` | Supporting repository configuration | 🟢 CONFIRMED |
| `lib/src/extensions/repository.dart` | `repository-lifecycle/` | Direct convenience flow | 🟢 CONFIRMED |
| `lib/src/bindings/repository.dart` | `repository-lifecycle/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/worktree.dart` | `repository-lifecycle/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/config.dart` | `repository-lifecycle/` | Supporting native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/status.dart` | `repository-lifecycle/` | Direct status adapter | 🟢 CONFIRMED |
| `lib/src/bindings/reset.dart` | `repository-lifecycle/` | Direct reset adapter | 🟢 CONFIRMED |
| `lib/src/bindings/graph.dart` | `repository-lifecycle/` | Supporting ahead/behind adapter | 🟢 CONFIRMED |
| `lib/src/bindings/describe.dart` | `repository-lifecycle/` | Supporting describe adapter | 🟢 CONFIRMED |

## Git Objects and Object Database

| Legacy file | Primary unit | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/src/annotated.dart` | `git-objects-and-object-database/` | Direct annotated commit | 🟢 CONFIRMED |
| `lib/src/blob.dart` | `git-objects-and-object-database/` | Direct blob | 🟢 CONFIRMED |
| `lib/src/commit.dart` | `git-objects-and-object-database/` | Direct commit | 🟢 CONFIRMED |
| `lib/src/commit_graph.dart` | `git-objects-and-object-database/` | Direct commit graph | 🟢 CONFIRMED |
| `lib/src/odb.dart` | `git-objects-and-object-database/` | Direct ODB | 🟢 CONFIRMED |
| `lib/src/oid.dart` | `git-objects-and-object-database/` | Direct OID | 🟢 CONFIRMED |
| `lib/src/signature.dart` | `git-objects-and-object-database/` | Direct signature | 🟢 CONFIRMED |
| `lib/src/tag.dart` | `git-objects-and-object-database/` | Direct tag | 🟢 CONFIRMED |
| `lib/src/tree.dart` | `git-objects-and-object-database/` | Direct tree/entry/update | 🟢 CONFIRMED |
| `lib/src/treebuilder.dart` | `git-objects-and-object-database/` | Direct tree builder | 🟢 CONFIRMED |
| `lib/src/writestream.dart` | `git-objects-and-object-database/` | Direct blob stream | 🟢 CONFIRMED |
| `lib/src/bindings/annotated.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/blob.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/commit.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/commit_graph.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/object.dart` | `git-objects-and-object-database/` | Supporting polymorphic object adapter | 🟢 CONFIRMED |
| `lib/src/bindings/odb.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/oid.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/signature.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/tag.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/tree.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/treebuilder.dart` | `git-objects-and-object-database/` | Direct native adapter | 🟢 CONFIRMED |

## Working Tree and Index

| Legacy file | Primary unit | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/src/attr_options.dart` | `working-tree-and-index/` | Direct attribute options | 🟢 CONFIRMED |
| `lib/src/checkout.dart` | `working-tree-and-index/` | Direct checkout | 🟢 CONFIRMED |
| `lib/src/diff.dart` | `working-tree-and-index/` | Direct diff/apply | 🟢 CONFIRMED |
| `lib/src/filter.dart` | `working-tree-and-index/` | Direct filter | 🟢 CONFIRMED |
| `lib/src/ignore.dart` | `working-tree-and-index/` | Direct ignore | 🟢 CONFIRMED |
| `lib/src/index.dart` | `working-tree-and-index/` | Direct index/conflict | 🟢 CONFIRMED |
| `lib/src/patch.dart` | `working-tree-and-index/` | Direct patch/hunk/line | 🟢 CONFIRMED |
| `lib/src/pathspec.dart` | `working-tree-and-index/` | Direct pathspec | 🟢 CONFIRMED |
| `lib/src/stash.dart` | `working-tree-and-index/` | Direct stash | 🟢 CONFIRMED |
| `lib/src/bindings/attr.dart` | `working-tree-and-index/` | Direct attribute adapter | 🟢 CONFIRMED |
| `lib/src/bindings/checkout.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/diff.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/filter.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/ignore.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/index.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/patch.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/pathspec.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/stash.dart` | `working-tree-and-index/` | Direct native adapter | 🟢 CONFIRMED |

## References and Remotes

| Legacy file | Primary unit | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/src/branch.dart` | `references-and-remotes/` | Direct branch | 🟢 CONFIRMED |
| `lib/src/callbacks.dart` | `references-and-remotes/` | Direct callback contract | 🟢 CONFIRMED |
| `lib/src/certificate.dart` | `references-and-remotes/` | Direct certificate projection | 🟢 CONFIRMED |
| `lib/src/credentials.dart` | `references-and-remotes/` | Direct credentials | 🟢 CONFIRMED |
| `lib/src/reference.dart` | `references-and-remotes/` | Direct reference | 🟢 CONFIRMED |
| `lib/src/reflog.dart` | `references-and-remotes/` | Direct reflog | 🟢 CONFIRMED |
| `lib/src/refspec.dart` | `references-and-remotes/` | Direct refspec | 🟢 CONFIRMED |
| `lib/src/remote.dart` | `references-and-remotes/` | Direct remote transport | 🟢 CONFIRMED |
| `lib/src/bindings/branch.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/certificate.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/credentials.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/refdb.dart` | `references-and-remotes/` | Supporting ref database adapter | 🟢 CONFIRMED |
| `lib/src/bindings/reference.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/reflog.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/refspec.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/remote_callbacks.dart` | `references-and-remotes/` | Direct callback bridge | 🟢 CONFIRMED |
| `lib/src/bindings/remote.dart` | `references-and-remotes/` | Direct native adapter | 🟢 CONFIRMED |

## History and Integration Operations

| Legacy file | Primary unit | Coverage | Confidence |
| --- | --- | --- | --- |
| `lib/src/blame.dart` | `history-and-integration-operations/` | Direct blame | 🟢 CONFIRMED |
| `lib/src/mailmap.dart` | `history-and-integration-operations/` | Direct mailmap | 🟢 CONFIRMED |
| `lib/src/merge.dart` | `history-and-integration-operations/` | Direct merge/cherry-pick/revert | 🟢 CONFIRMED |
| `lib/src/message.dart` | `history-and-integration-operations/` | Direct message/trailer | 🟢 CONFIRMED |
| `lib/src/note.dart` | `history-and-integration-operations/` | Direct note | 🟢 CONFIRMED |
| `lib/src/packbuilder.dart` | `history-and-integration-operations/` | Direct packbuilder | 🟢 CONFIRMED |
| `lib/src/rebase.dart` | `history-and-integration-operations/` | Direct rebase | 🟢 CONFIRMED |
| `lib/src/revparse.dart` | `history-and-integration-operations/` | Direct revision parse | 🟢 CONFIRMED |
| `lib/src/revwalk.dart` | `history-and-integration-operations/` | Direct revision walk | 🟢 CONFIRMED |
| `lib/src/submodule.dart` | `history-and-integration-operations/` | Direct submodule | 🟢 CONFIRMED |
| `lib/src/bindings/blame.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/mailmap.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/merge.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/message.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/note.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/packbuilder.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/rebase.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/revparse.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/revwalk.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |
| `lib/src/bindings/submodule.dart` | `history-and-integration-operations/` | Direct native adapter | 🟢 CONFIRMED |

## Mapping Summary

| Metric | Value | Confidence |
| --- | --- | --- |
| Dart source files under `lib/` | 95 | 🟢 CONFIRMED from repository scan |
| Files assigned to a unit | 95 | 🟢 CONFIRMED |
| Structurally mapped coverage | 100% | 🟢 CONFIRMED |
| Files marked `n/a` | 0 | 🟢 CONFIRMED |
| Dynamic behavior coverage | Not calculated | 🔴 GAP |

🟢 **CONFIRMED** — Test files are traced through each unit's `tests.md`; CI/configuration and external generated declarations are covered by `architecture.md`, `dependencies.md`, ADRs, and the native-runtime unit.

🔴 **GAP** — Structural 100% mapping does not resolve dynamic gaps for network behavior, concurrency, SHA-256 completeness, native memory instrumentation, recovery, or fresh platform tests.

