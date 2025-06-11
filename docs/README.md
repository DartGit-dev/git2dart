# git2dart
![Pub Version](https://img.shields.io/pub/v/git2dart)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/git2dart)
![Pub Likes](https://img.shields.io/pub/likes/git2dart)

## Dart bindings to libgit2

git2dart package provides ability to use [libgit2](https://github.com/libgit2/libgit2) in Dart/Flutter.

This is a hardfork of [libgit2dart](https://github.com/SkinnyMind/libgit2dart)

Currently supported platforms are 64-bit Windows, Linux and macOS on both Flutter and Dart VM.

## Table of Contents

- [Getting Started](#getting-started)
- [System Dependencies](#system-dependencies)
- [Usage](#usage)

## Getting Started

1. Add package as a dependency in your `pubspec.yaml`
2. Import:

```dart
import 'package:git2dart/git2dart.dart';
```

3. Verify installation (should return string with version of libgit2 shipped with package):

```dart
...
print(Libgit2.version);
...
```

**Note**: The following steps only required if you are using package in Dart application (Flutter application will have libgit2 library bundled automatically when you build for release).

## System Dependencies

To use git2dart, you need to have the following system dependencies installed:

### Linux

```shell
sudo apt-get install libssl-dev libpcre3
```

### macOS

```shell
brew install openssl
```

### Windows

```powershell
choco install openssl -y
```

## Usage

git2dart provides you ability to manage Git repository. You can read and write objects (commit, tag, tree and blob), walk a tree, access the staging area, manage config and lots more.

Let's look at some of the classes and methods (you can also check [example](example/example.dart)).

# git2dart Documentation
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
- [Running Tests](types/running_tests.md)
- [Contributing](types/contributing.md)
- [Development](types/development.md)
- [Licence](types/license.md)

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

