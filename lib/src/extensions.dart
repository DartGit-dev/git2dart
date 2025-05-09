// coverage:ignore-file

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Git object type constants
const int GIT_OBJECT_COMMIT = 1;
const int GIT_OBJECT_TREE = 2;
const int GIT_OBJECT_BLOB = 3;
const int GIT_OBJECT_TAG = 4;
const int GIT_OBJECT_OFS_DELTA = 6;
const int GIT_OBJECT_REF_DELTA = 7;

/// Extension methods for String validation and conversion.
extension IsValidSHA on String {
  /// Validates if the string is a valid Git SHA-1 hash.
  ///
  /// A valid SHA-1 hash must:
  /// - Contain only hexadecimal characters (0-9, a-f, A-F)
  /// - Have a length between [GIT_OID_MINPREFIXLEN] and [GIT_OID_HEXSZ]
  ///
  /// Returns `true` if the string is a valid SHA-1 hash, `false` otherwise.
  bool isValidSHA() {
    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegExp.hasMatch(this) &&
        (GIT_OID_MINPREFIXLEN <= length && GIT_OID_HEXSZ >= length);
  }
}

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

/// Extension methods for C char pointer to Dart String conversion.
extension ToDartString on Pointer<Char> {
  /// Converts a UTF-8 encoded C string to a Dart String.
  ///
  /// Decodes the UTF-8 code units of this zero-terminated byte array as
  /// Unicode code points and creates a Dart string containing those code points.
  ///
  /// If [length] is provided:
  /// - Zero-termination is ignored
  /// - The result can contain NUL characters
  /// - Only the specified number of bytes will be decoded
  ///
  /// If [length] is not provided:
  /// - The string is read until the first NUL character
  /// - NUL characters are not included in the result
  ///
  /// Returns a Dart [String] containing the decoded UTF-8 characters.
  String toDartString({int? length}) =>
      cast<Utf8>().toDartString(length: length);
}

/// Extension methods for Git object type validation.
extension IsValidGitObjectType on int {
  /// Validates if the integer represents a valid Git object type.
  ///
  /// Valid Git object types are:
  /// - [GIT_OBJECT_COMMIT]
  /// - [GIT_OBJECT_TREE]
  /// - [GIT_OBJECT_BLOB]
  /// - [GIT_OBJECT_TAG]
  /// - [GIT_OBJECT_OFS_DELTA]
  /// - [GIT_OBJECT_REF_DELTA]
  ///
  /// Returns `true` if the integer represents a valid Git object type, `false` otherwise.
  bool isValidGitObjectType() {
    return this >= GIT_OBJECT_COMMIT && this <= GIT_OBJECT_REF_DELTA;
  }
}

/// Extension methods for Git reference name validation.
extension IsValidRefName on String {
  /// Validates if the string is a valid Git reference name.
  ///
  /// A valid reference name must:
  /// - Not be empty
  /// - Not contain control characters
  /// - Not contain spaces, tilde (~), caret (^), colon (:), question mark (?), asterisk (*), or open bracket ([)
  /// - Not end with a dot (.), slash (/), or dot followed by slash (./)
  /// - Not contain two consecutive dots (..)
  /// - Not contain a sequence of dots and slashes (./)
  ///
  /// Returns `true` if the string is a valid reference name, `false` otherwise.
  bool isValidRefName() {
    if (isEmpty) return false;

    final invalidChars = RegExp(r'[\s~^:?*[]');
    if (invalidChars.hasMatch(this)) return false;

    if (endsWith('.') || endsWith('/') || endsWith('./')) return false;
    if (contains('..')) return false;
    if (contains('./')) return false;

    return true;
  }
}
