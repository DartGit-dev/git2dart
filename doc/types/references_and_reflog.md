# References and RefLog

`Reference` represents Git references such as branches, tags, and symbolic
references. `RefLog` represents reflog entries for a reference.

## References

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

## RefLog

```dart
final reflog = RefLog(repo.head);

reflog.length;
reflog[0];
reflog.write();
```

References and reflogs wrap native handles. Call `free()` when deterministic
cleanup is needed.

See [test/reference_test.dart](../../test/reference_test.dart) and
[test/reflog_test.dart](../../test/reflog_test.dart).
