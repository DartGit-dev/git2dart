# RevParse

Revparse helpers resolve Git revision specifications to objects or ranges.

## Single Object

```dart
final object = RevParse.single(repo: repo, spec: 'HEAD^{commit}');
```

## Extended Parse

```dart
final result = RevParse.ext(repo: repo, spec: 'HEAD~1');

result.object;
result.reference;
```

## Ranges

```dart
final range = RevParse.range(repo: repo, spec: 'main..feature');
range.from;
range.to;
```

Revision syntax follows Git revision rules.

See [test/revparse_test.dart](../../test/revparse_test.dart).
