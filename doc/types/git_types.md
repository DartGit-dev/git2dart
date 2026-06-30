# Shared Git Enums and Options

`git_types.dart` exports shared enums and option classes used across the public
API. Most values mirror libgit2 constants and expose the native integer through
the `value` getter.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Common groups

- Repository and references: `ReferenceType`, `GitRepositoryOpen`,
  `GitRepositoryInit`, `GitRepositoryState`, `GitDirection`
- Objects and traversal: `GitObject`, `GitFilemode`, `GitSort`, `GitRevSpec`
- Branches and status: `GitBranch`, `GitStatus`
- Checkout, reset, and index: `GitCheckout`, `GitReset`,
  `GitIndexCapability`, `GitIndexAddOption`
- Diff and patching: `GitDiff`, `GitDelta`, `GitDiffFlag`, `GitDiffStats`,
  `GitDiffFind`, `GitDiffLine`, `GitApplyLocation`
- Merge and rebase: `GitMergeAnalysis`, `GitMergePreference`, `GitMergeFlag`,
  `GitMergeFileFavor`, `GitMergeFileFlag`, `GitRebaseOperation`
- Network and credentials: `GitCredential`, `GitFeature`, `GitFetchPrune`,
  `GitRemoteAutotag`
- Path and tree helpers: `GitPathGitFile`, `GitPathFilesystem`, `GitTreeWalk`
- Attributes, blame, describe, filters, submodules, stashes, and worktrees:
  `GitAttributeCheck`, `GitBlameFlag`, `GitDescribeStrategy`,
  `GitBlobFilter`, `GitFilterMode`, `GitFilterFlag`, `GitSubmoduleIgnore`,
  `GitSubmoduleUpdate`, `GitSubmoduleRecurse`, `GitSubmoduleStatus`,
  `GitStash`, `GitStashApply`, `GitWorktree`

### Usage

```dart
final repo = Repository.init(
  path: '/tmp/example',
  flags: {GitRepositoryInit.mkpath},
);

repo.reset(oid: repo.head.target, resetType: GitReset.hard);

final filter = Filter.load(
  repo: repo,
  path: 'file.crlf',
  mode: GitFilterMode.toWorktree,
  flags: {GitFilterFlag.defaults},
);

final protected = Libgit2.isGitFile(
  path: '.gitmodules',
  gitfile: GitPathGitFile.gitmodules,
);
```

Most enums provide `fromValue` for converting native integer values back to the
Dart enum. Unknown values throw `ArgumentError`.

## Important Options

Most enum values mirror libgit2 constants and expose the native integer through `value`. Use `fromValue` when converting native results back to Dart enums.

## Lifecycle and Errors

Enums and option classes do not own native resources. Unknown native values passed to `fromValue` throw `ArgumentError`.

## See Also

- [git_types_test.dart](../../test/git_types_test.dart)
