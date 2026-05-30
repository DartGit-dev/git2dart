# Ignore

`Ignore` exposes repository ignore helpers for in-memory rules and path checks.

## Rules

```dart
Ignore.addRule(repo: repo, rules: '*.tmp');

final ignored = Ignore.pathIsIgnored(
  repo: repo,
  path: 'generated.tmp',
);

Ignore.clearInternalRules(repo);
```

Rules added with `addRule` are not written to disk. They affect the repository
instance until `clearInternalRules` is called.

See [test/ignore_test.dart](../../test/ignore_test.dart).
