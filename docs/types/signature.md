# Signature

Create and manage signatures for commits and tags:

```dart
// Create signature with current time
final sig = Signature.create(
  name: 'Author Name',
  email: 'author@example.com',
);

// Create signature with specific time
final sig = Signature.create(
  name: 'Author Name',
  email: 'author@example.com',
  time: 1234567890, // seconds since epoch
  offset: 120, // timezone offset in minutes
);

// Access signature properties
sig.name; // => 'Author Name'
sig.email; // => 'author@example.com'
sig.time; // => 1234567890
sig.offset; // => 120
sig.sign; // => '+0200'
```

---


For more examples see [test/signature_test.dart](../../test/signature_test.dart).
