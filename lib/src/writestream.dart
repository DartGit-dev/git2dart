import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Wrapper around libgit2 `git_writestream` used for streamed blob creation.
@immutable
class BlobWriteStream {
  /// Initialize a new instance from the underlying pointer.
  @internal
  BlobWriteStream(this._pointer) {
    _finalizer.attach(this, _pointer, detach: this);
  }

  final Pointer<git_writestream> _pointer;

  /// Pointer to the underlying `git_writestream` structure.
  @internal
  Pointer<git_writestream> get pointer => _pointer;

  /// Write raw [data] into the stream.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void write(Uint8List data) {
    final writeFn =
        _pointer.ref.write
            .asFunction<
              int Function(Pointer<git_writestream>, Pointer<Char>, int)
            >();
    using((arena) {
      final buf = arena<Uint8>(data.length);
      buf.asTypedList(data.length).setAll(0, data);
      final error = writeFn(_pointer, buf.cast<Char>(), data.length);
      checkErrorAndThrow(error);
    });
  }

  /// Write UTF-8 [text] into the stream.
  void writeString(String text) {
    write(Uint8List.fromList(text.codeUnits));
  }

  /// Manually free the underlying stream if it wasn't committed.
  void free() {
    final freeFn =
        _pointer.ref.free.asFunction<void Function(Pointer<git_writestream>)>();
    freeFn(_pointer);
    _finalizer.detach(this);
  }

  @internal
  void detach() => _finalizer.detach(this);
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_writestream>>((pointer) {
  final freeFn =
      pointer.ref.free.asFunction<void Function(Pointer<git_writestream>)>();
  freeFn(pointer);
});
// coverage:ignore-end
