# Attributes

Manage gitattributes:

```dart
// Get multiple attributes for a path
final values = repo.getAttributesMany(
  path: 'file.sh',
  names: ['text', 'eol'],
); // => [null, 'lf']

// Iterate over attributes
final attrs = repo.foreachAttributes(path: 'file.dart');
attrs.first.key; // => 'text'
attrs.first.value; // => 'set'

// Flush attribute cache
repo.cacheFlush();

// Add attribute macro
repo.addMacro(name: 'binary', values: '-diff -text');

// Extended attribute lookup with options
final opts = AttrOptions();
repo.getAttributesManyExt(
  options: opts,
  path: 'file.dart',
  names: ['text'],
);
opts.free();
```

---

