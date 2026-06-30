# Filter and FilterOptions

`Filter` applies Git attribute filters such as CRLF conversion. `FilterOptions`
controls how a filter list is loaded.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Loading filters

```dart
final filter = Filter.load(
  repo: repo,
  path: 'file.crlf',
  mode: GitFilterMode.toWorktree,
);

final output = filter.applyToData('line\n');
print(output);

filter.free();
```

Use `GitFilterMode.toWorktree` for smudge filters and
`GitFilterMode.toOdb` for clean filters. The aliases `GitFilterMode.smudge`
and `GitFilterMode.clean` are also available.

### Extended options

```dart
final options = FilterOptions(
  flags: {
    GitFilterFlag.noSystemAttributes,
    GitFilterFlag.attributesFromCommit,
  },
  commit: repo.head.target,
);

final filter = Filter.loadExt(
  repo: repo,
  path: 'file.crlf',
  mode: GitFilterMode.toWorktree,
  options: options,
);

options.free();
filter.free();
```

Filters can be applied to arbitrary data, files, or blobs:

```dart
filter.applyToData('line\n');
filter.applyToFile(repo: repo, path: '/absolute/path/to/file.crlf');
filter.applyToBlob(blob);
```

### Lifecycle and errors

`Filter` and `FilterOptions` allocate native resources. They use finalizers, but
call `free()` when you are done with them in long-running code. Invalid paths,
attributes, or libgit2 failures throw `LibGit2Error`.

## Important Options

Use `GitFilterMode` for clean/smudge direction and `GitFilterFlag` with `FilterOptions` when attributes must be loaded from a specific source.

## Lifecycle and Errors

`Filter` and `FilterOptions` allocate native resources. They use finalizers, but call `free()` when you are done in long-running code.

## See Also

- [filter_test.dart](../../test/filter_test.dart)
- [filter_options_test.dart](../../test/filter_options_test.dart)
