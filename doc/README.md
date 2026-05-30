# git2dart Documentation

This documentation covers the public Dart API exposed by `package:git2dart`.
The package wraps libgit2 with null-safe Dart classes and keeps raw FFI details
inside `lib/src/bindings`.

## Platform Setup

- [Android setup](android.md)
- [iOS setup](ios.md)

## Core Types

- [Repository](types/repository.md)
- [Git objects and Oid](types/git_objects.md)
- [Commit](types/commit.md)
- [Tree and TreeEntry](types/tree_and_treeentry.md)
- [Blob](types/blob.md)
- [Tag](types/tag.md)
- [Signature](types/signature.md)
- [AnnotatedCommit](types/annotatedcommit.md)

## Repository Data

- [Config files](types/config_files.md)
- [Index and IndexEntry](types/index_and_indexentry.md)
- [References and RefLog](types/references_and_reflog.md)
- [Branches](types/branches.md)
- [Remote](types/remote.md)
- [Worktrees](types/worktrees.md)
- [Submodules](types/submodules.md)
- [ODB (Object Database)](types/odb_object_database.md)
- [Packbuilder](types/packbuilder.md)
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
- [Blame](types/blame.md)
- [Describe](types/describe.md)
- [Note](types/note.md)
- [RevParse](types/revparse.md)
- [Commit Walker](types/commit_walker.md)
- [Mailmap](types/mailmap.md)
- [Message](types/message.md)
- [Credentials](types/credentials.md)

## Troubleshooting

### Linux

The bundled native libraries are built on Ubuntu. On distributions that expose
PCRE under different library names, loading libgit2 can fail with messages like:

- `Failed to load dynamic library: libpcre.so.3`
- `Failed to load dynamic library: libpcreposix.so.3`

Create compatibility symlinks for your distribution when needed:

```shell
sudo ln -s /usr/lib64/libpcre.so /usr/lib64/libpcre.so.3
sudo ln -s /usr/lib64/libpcreposix.so /usr/lib64/libpcreposix.so.3
```
