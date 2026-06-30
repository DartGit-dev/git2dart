# BlobWriteStream

`BlobWriteStream` streams blob content into the object database.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage
```dart
import 'dart:typed_data';

import 'package:git2dart/git2dart.dart';
```

Create streams through `Blob.createFromStream`:

```dart
final stream = Blob.createFromStream(repo: repo, hintPath: 'notes.txt');

stream.writeString('first line\n');
stream.write(Uint8List.fromList([0x73, 0x65, 0x63, 0x6f, 0x6e, 0x64]));

final oid = Blob.createFromStreamCommit(stream);
final blob = Blob.lookup(repo: repo, oid: oid);
```

### Lifecycle

Commit the stream with `Blob.createFromStreamCommit`. If you abandon a stream
before committing it, call `stream.free()` to release the native writestream.

After a successful commit, git2dart detaches the finalizer from the stream.

## Important Options

Use `hintPath` when filters or attributes should be inferred for the streamed blob content.

## Lifecycle and Errors

`BlobWriteStream` wraps a native writestream. Commit it with `Blob.createFromStreamCommit`; call `free()` if the stream is abandoned before commit.

## See Also

- [blob_test.dart](../../test/blob_test.dart)
