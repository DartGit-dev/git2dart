import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Parse N characters of a hex formatted object id into a git_oid.
///
/// This function is useful when working with partial SHA-1 or SHA-256 hashes.
/// It will parse the first [hex.length] characters of the provided [hex] string.
///
/// Example:
/// ```dart
/// final oid = fromStrN('1234567'); // Parses first 7 characters
/// ```
///
/// Note: The function assumes the input string contains valid hexadecimal
/// characters. Input validation should be done before calling this function.
Pointer<git_oid> fromStrN(
  String hex, {
  git_oid_t type = git_oid_t.GIT_OID_SHA1,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final hexC = hex.toChar(arena);

    final error = libgit2.git_oid_fromstrn(
      out,
      hexC,
      hex.length,
      type,
    );
    checkErrorAndThrow(error);

    return out;
  });
}

/// Parse a full hex formatted object id into a git_oid.
///
/// This function expects a full SHA-1 or SHA-256 hash string. For
/// partial hashes, use [fromStrN] instead.
///
/// Example:
/// ```dart
/// final oid = fromSHA('1234567890123456789012345678901234567890');
/// ```
///
/// Note: The function assumes the input string is the correct length for the
/// provided [type] (40 characters for SHA-1 and 64 characters for SHA-256) and
/// contains valid hexadecimal characters. Input validation should be done
/// before calling this function.
Pointer<git_oid> fromSHA(
  String hex, {
  git_oid_t type = git_oid_t.GIT_OID_SHA1,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final hexC = hex.toChar(arena);

    final error = libgit2.git_oid_fromstr(out, hexC, type);
    checkErrorAndThrow(error);

    return out;
  });
}

/// Copy a raw hash into a git_oid structure.
///
/// This function is useful when working with raw SHA-1 or SHA-256 hash
/// values, typically obtained from internal Git operations or when
/// implementing custom Git functionality.
///
/// The input [raw] must be of the correct length for the chosen [type]
/// (20 bytes for SHA-1, 32 bytes for SHA-256).
///
/// Example:
/// ```dart
/// final raw = Array<UnsignedChar>(20); // 20-byte array
/// // Fill raw with hash bytes...
/// final oid = fromRaw(raw);
/// ```
Pointer<git_oid> fromRaw(
  Array<UnsignedChar> raw, {
  git_oid_t type = git_oid_t.GIT_OID_SHA1,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
  final length =
      type == git_oid_t.GIT_OID_SHA256 ? 32 : 20;
  final rawC = arena<UnsignedChar>(length);

  for (var i = 0; i < length; i++) {
      rawC[i] = raw[i];
    }

    libgit2.git_oid_fromraw(out, rawC, type);
    return out;
  });
}

/// Format a git_oid into a hexadecimal string.
///
/// This function converts a git_oid structure into its string representation.
/// The resulting length depends on the underlying hash type (40 characters for
/// SHA-1, 64 characters for SHA-256).
///
/// Example:
/// ```dart
/// final sha = toSHA(oidPointer); // Returns e.g. "1234567890123456789012345678901234567890"
/// ```
String toSHA(Pointer<git_oid> id) {
  return using((arena) {
    final type = id.ref.type;
    final length =
        type == git_oid_t.GIT_OID_SHA256.value
            ? GIT_OID_SHA256_HEXSIZE
            : GIT_OID_SHA1_HEXSIZE;
    final out = arena<Char>(length);
    libgit2.git_oid_fmt(out, id);
    return out.toDartString(length: length);
  });
}

/// Compare two oid structures.
///
/// This function implements a three-way comparison between two object IDs.
/// It can be used for sorting and ordering OIDs.
///
/// Returns:
/// - < 0 if a is less than b
/// - 0 if a equals b
/// - > 0 if a is greater than b
///
/// Example:
/// ```dart
/// final result = compare(aPointer: oid1, bPointer: oid2);
/// if (result < 0) print('oid1 is less than oid2');
/// else if (result > 0) print('oid1 is greater than oid2');
/// else print('oid1 equals oid2');
/// ```
int compare({
  required Pointer<git_oid> aPointer,
  required Pointer<git_oid> bPointer,
}) {
  return libgit2.git_oid_cmp(aPointer, bPointer);
}

/// Create a copy of an oid structure.
///
/// This function creates a new git_oid structure and copies the contents
/// of the source oid into it. The caller is responsible for freeing the
/// allocated memory.
///
/// Example:
/// ```dart
/// final copy = copy(sourceOid);
/// // Use copy...
/// calloc.free(copy);
/// ```
Pointer<git_oid> copy(Pointer<git_oid> src) {
  final out = calloc<git_oid>();
  final error = libgit2.git_oid_cpy(out, src);

  checkErrorAndThrow(error);

  return out;
}

/// Check two oid structures for equality.
bool equal({
  required Pointer<git_oid> aPointer,
  required Pointer<git_oid> bPointer,
}) {
  return libgit2.git_oid_equal(aPointer, bPointer) == 1;
}

/// Compare the first [length] hexadecimal characters of two oid structures.
int ncmp({
  required Pointer<git_oid> aPointer,
  required Pointer<git_oid> bPointer,
  required int length,
}) {
  return libgit2.git_oid_ncmp(aPointer, bPointer, length);
}

/// Check if an oid is all zeros.
bool isZero(Pointer<git_oid> id) => libgit2.git_oid_is_zero(id) == 1;

/// Convert an oid into its loose-object path string (e.g. `aa/bb...`).
String pathFormat(Pointer<git_oid> id) {
  return using((arena) {
    final length = id.ref.type == git_oid_t.GIT_OID_SHA256.value
        ? GIT_OID_SHA256_HEXSIZE + 1
        : GIT_OID_SHA1_HEXSIZE + 1;
    final out = arena<Char>(length + 1);
    libgit2.git_oid_pathfmt(out, id);
    return out.toDartString(length: length);
  });
}
