# References and RefLog

`Reference` represents Git references such as branches, tags, and symbolic
references. `RefLog` represents reflog entries for a reference.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### References

```dart
final head = repo.head;

head.name;
head.shorthand;
head.target;
head.isBranch;
head.isTag;

final direct = Reference.create(
  repo: repo,
  name: 'refs/heads/new-branch',
  target: commit.oid,
);
final duplicate = direct.duplicate();
```

### RefLog

```dart
final reflog = RefLog(repo.head);

reflog.length;
reflog[0];
reflog.write();
```

References and reflogs wrap native handles. Call `free()` when deterministic
cleanup is needed.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [reference_test.dart](../../test/reference_test.dart)
- [reflog_test.dart](../../test/reflog_test.dart)
