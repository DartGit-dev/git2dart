# git2dart Documentation

This documentation covers the public Dart API exposed by `package:git2dart`.
The package wraps libgit2 with null-safe Dart classes and keeps raw FFI details
inside `lib/src/bindings`.

## Choose a Path

| Task | Start with | Then read |
| --- | --- | --- |
| Install and run the first repository operation | [Main README](../README.md#installation) | [Repository](types/repository.md), [Git objects](types/git_objects.md) |
| Build a Flutter mobile app | [Platform-specific initialization](types/platform_specific.md) | [Android setup](android.md), [iOS setup](ios.md) |
| Work with files, status, and staged changes | [Index and IndexEntry](types/index_and_indexentry.md) | [Checkout](types/checkout.md), [Diff](types/diff.md), [Patch](types/patch.md), [Stashes](types/stashes.md) |
| Fetch, push, or authenticate with remotes | [Remote](types/remote.md) | [Callbacks](types/callbacks.md), [Credentials](types/credentials.md), [Certificates](types/certificate.md), [Refspec](types/refspec.md) |
| Read or write Git objects directly | [Git objects](types/git_objects.md) | [Blob](types/blob.md), [BlobWriteStream](types/writestream.md), [Commit](types/commit.md), [Tree and TreeEntry](types/tree_and_treeentry.md), [Tag](types/tag.md), [Object identifiers](types/oid.md) |
| Handle native resources and failures | [Error handling](types/errors.md) | [Libgit2 global options](types/libgit2.md), [Shared Git enums and options](types/git_types.md) |

## Common Entry Points

- [Complete example](../example/example.dart)
- [Repository](types/repository.md)
- [Remote](types/remote.md)
- [Android setup](android.md)
- [iOS setup](ios.md)
- [Error handling](types/errors.md)

## Platform Setup

- [Android setup](android.md)
- [iOS setup](ios.md)
- [Platform-specific initialization](types/platform_specific.md)
- [Libgit2 global options](types/libgit2.md)
- [Error handling](types/errors.md)

## Core Types

- [Repository](types/repository.md)
- [Git objects](types/git_objects.md)
- [Object identifiers](types/oid.md)
- [Commit](types/commit.md)
- [Tree and TreeEntry](types/tree_and_treeentry.md)
- [Blob](types/blob.md)
- [BlobWriteStream](types/writestream.md)
- [Tag](types/tag.md)
- [Signature](types/signature.md)
- [AnnotatedCommit](types/annotatedcommit.md)
- [Shared Git enums and options](types/git_types.md)

## Repository Data

- [Config files](types/config_files.md)
- [Index and IndexEntry](types/index_and_indexentry.md)
- [References and RefLog](types/references_and_reflog.md)
- [Branches](types/branches.md)
- [Remote](types/remote.md)
- [Refspec](types/refspec.md)
- [Callbacks](types/callbacks.md)
- [Certificates](types/certificate.md)
- [Worktrees](types/worktrees.md)
- [Submodules](types/submodules.md)
- [ODB (Object Database)](types/odb_object_database.md)
- [PackBuilder](types/packbuilder.md)
- [CommitGraph](types/commit_graph.md)

## Operations

- [Checkout](types/checkout.md)
- [Reset](types/reset.md)
- [Merge](types/merge.md)
- [Rebase](types/rebase.md)
- [Stashes](types/stashes.md)
- [Diff](types/diff.md)
- [Patch](types/patch.md)
- [Pathspec](types/pathspec.md)
- [Ignore](types/ignore.md)
- [Attributes](types/attributes.md)
- [Filter and FilterOptions](types/filter.md)
- [Blame](types/blame.md)
- [Describe](types/describe.md)
- [Note](types/note.md)
- [RevParse](types/revparse.md)
- [Commit Walker](types/commit_walker.md)
- [Mailmap](types/mailmap.md)
- [Message](types/message.md)
- [Credentials](types/credentials.md)

## Troubleshooting

- [System dependencies](../README.md#native-dependencies)
- [Android troubleshooting](android.md#troubleshooting)
- [iOS troubleshooting](ios.md#troubleshooting)
