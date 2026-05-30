# Message

`Message` provides commit message cleanup and trailer parsing helpers.

## Cleanup

```dart
final cleaned = Message.prettify(
  message: 'Subject\n\n# comment\n\nBody',
  stripComments: true,
);
```

## Trailers

```dart
final trailers = Message.trailers(
  'Subject\n\nBody\n\nReviewed-by: A User\nTicket: 42\n',
);

trailers['Reviewed-by'];
```

`prettify` delegates Git-style message cleanup to libgit2. `trailers` parses
the final trailer block into Dart strings.

See [test/message_test.dart](../../test/message_test.dart).
