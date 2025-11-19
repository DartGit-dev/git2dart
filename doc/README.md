# git2dart Documentation

## Platform Setup

- [Android Setup](android.md) - Required initialize library for Android

## Usage Guide
- [Repository](types/repository.md)
- [Git Objects](types/git_objects.md)
- [Commit](types/commit.md)
- [Tree and TreeEntry](types/tree_and_treeentry.md)
- [Tag](types/tag.md)
- [Blob](types/blob.md)
- [Commit Walker](types/commit_walker.md)
- [Index and IndexEntry](types/index_and_indexentry.md)
- [References and RefLog](types/references_and_reflog.md)
- [Branches](types/branches.md)
- [Diff](types/diff.md)
- [Patch](types/patch.md)
- [Config files](types/config_files.md)
- [Checkout](types/checkout.md)
- [Merge](types/merge.md)
- [Stashes](types/stashes.md)
- [Worktrees](types/worktrees.md)
- [Submodules](types/submodules.md)
- [Remote](types/remote.md)
- [Reset](types/reset.md)
- [Attributes](types/attributes.md)
- [Blame](types/blame.md)
- [Describe](types/describe.md)
- [Note](types/note.md)
- [Rebase](types/rebase.md)
- [Mailmap](types/mailmap.md)
- [Credentials](types/credentials.md)
- [ODB (Object Database)](types/odb_object_database.md)
- [Packbuilder](types/packbuilder.md)
- [Signature](types/signature.md)
- [RevParse](types/revparse.md)
- [AnnotatedCommit](types/annotatedcommit.md)

# Troubleshooting

#### Linux

If you are developing on Linux using non-Debian based distrib you might encounter these errors:

- Failed to load dynamic library: libpcre.so.3: cannot open shared object file: No such file or directory
- Failed to load dynamic library: libpcreposix.so.3: cannot open shared object file: No such file or directory

That happens because dynamic library is precompiled on Ubuntu and Arch/Fedora/RedHat names for those libraries are `libpcre.so` and `libpcreposix.so`.

To fix these errors create symlinks:

```shell
sudo ln -s /usr/lib64/libpcre.so /usr/lib64/libpcre.so.3
sudo ln -s /usr/lib64/libpcreposix.so /usr/lib64/libpcreposix.so.3
```

