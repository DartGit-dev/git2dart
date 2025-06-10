import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Extension methods for String to C char pointer conversion.
extension ToChar on String {
  /// Creates a zero-terminated UTF-8 encoded C string from this Dart String.
  ///
  /// The returned pointer is managed by the provided [arena] and will be automatically
  /// freed when the arena is disposed. The string is automatically null-terminated.
  ///
  /// Returns a [Pointer<Char>] to the allocated memory containing the UTF-8 encoded string.
  Pointer<Char> toChar(Arena arena) => toNativeUtf8Arena(arena).cast<Char>();
  Pointer<Char> toCharAlloc() => toNativeUtf8().cast<Char>();

  Pointer<Utf8> toNativeUtf8Arena(Arena arena) {
    final units = utf8.encode(this);
    final result = arena<Uint8>(units.length + 1);
    final nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}

/// Extension methods for validating SHA-256 strings.
extension IsValidSHA256 on String {
  /// Returns `true` if the string is a valid SHA-256 hex string.
  bool isValidSHA256() {
    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegExp.hasMatch(this) &&
        (GIT_OID_MINPREFIXLEN <= length && GIT_OID_SHA256_HEXSIZE >= length);
  }
}
