# RevParse

Parse revision specifications:

```dart
// Parse single revision spec
final commit = RevParse.single(repo: repo, spec: 'HEAD') as Commit;
final tree = RevParse.single(repo: repo, spec: 'HEAD^{tree}') as Tree;
final blob = RevParse.single(repo: repo, spec: 'HEAD:README.md') as Blob;

// Parse extended revision spec (returns object and reference)
final result = RevParse.ext(repo: repo, spec: 'master');
result.object; // => Commit
result.reference; // => Reference

// Parse revision range
final range = RevParse.range(repo: repo, spec: 'HEAD~10..HEAD');
range.from; // => Commit
range.to; // => Commit
range.flags; // => {GitRevSpec.range}

// Parse merge base
final range = RevParse.range(repo: repo, spec: 'HEAD...feature');
range.flags; // => {GitRevSpec.range, GitRevSpec.mergeBase}
```

---


For more examples see [test/revparse_test.dart](../../test/revparse_test.dart).
