# Tag

Tag create and lookup methods and some of the object getters:

```dart
// Create annotated tag
final annotated = Tag.createAnnotated(
  repo: repo,
  tagName: 'v0.1',
  target: repo['821ed6e'],
  targetType: GitObject.commit,
  tagger: repo.defaultSignature,
  message: 'tag message',
); // => Oid

// Create lightweight tag
final lightweight = Tag.createLightweight(
  repo: repo,
  tagName: 'v0.1',
  target: repo['821ed6e'],
  targetType: GitObject.commit,
); // => Oid

// Lookup tag
final tag = Tag.lookup(repo: repo, oid: repo['f0fdbf5']); // => Tag

// Get list of all the tags names in repository
repo.tags; // => ['v0.1', 'v0.2']

tag.oid; // => Oid
tag.name; // => 'v0.1'
```


For more examples see [test/tag_test.dart](../../test/tag_test.dart).
