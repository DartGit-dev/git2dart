// coverage:ignore-file

import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Extension methods for String to C char pointer conversion.
extension ToChar on String {
  /// Creates a zero-terminated UTF-8 encoded C string from this Dart String.
  ///
  /// The returned pointer must be freed using [calloc.free] when no longer needed.
  /// The string is automatically null-terminated.
  ///
  /// Returns a [Pointer<Char>] to the allocated memory containing the UTF-8 encoded string.
  Pointer<Char> toChar() => toNativeUtf8().cast<Char>();
}
