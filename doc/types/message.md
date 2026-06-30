# Message

`Message` provides commit message cleanup and trailer parsing helpers.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Cleanup

```dart
final cleaned = Message.prettify(
  message: 'Subject\n\n# comment\n\nBody',
  stripComments: true,
);
```

### Trailers

```dart
final trailers = Message.trailers(
  'Subject\n\nBody\n\nReviewed-by: A User\nTicket: 42\n',
);

trailers['Reviewed-by'];
```

`prettify` delegates Git-style message cleanup to libgit2. `trailers` parses
the final trailer block into Dart strings.

## Important Options

Use the options shown in the example for this API. Related enum and flag details are collected in [Shared Git enums and options](git_types.md).

## Lifecycle and Errors

Objects that wrap native libgit2 handles use finalizers where available. In long-running code, call `free()` on objects that expose it once you are done with them. libgit2 failures surface as `LibGit2Error`.

## See Also

- [message_test.dart](../../test/message_test.dart)
