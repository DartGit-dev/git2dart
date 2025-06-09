import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/odb.dart' as odb_bindings;
import 'package:git2dart/src/bindings/oid.dart' as bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Represents a unique identifier for a Git object.
///
/// The [Oid] class provides functionality to work with Git object identifiers,
/// which can be either SHA-1 or SHA-256 hashes.
@immutable
class Oid extends Equatable {
  /// Initializes a new instance of [Oid] class from provided
  /// pointer to Oid object in memory.
  ///
  /// Note: For internal use. Use [Oid.fromSHA] instead.
  @internal
  Oid(this._oidPointer);

  /// Initializes a new instance of [Oid] class by determining if an object can
  /// be found in the ODB of [repo]sitory with provided hexadecimal [sha]
  /// string that is between 4 and 64 characters long.
  ///
  /// The [sha] parameter can be either:
  /// - A full SHA-1 (40 characters) or SHA-256 (64 characters) hash
  /// - A partial hash prefix
  ///
  /// Example:
  /// ```dart
  /// // Full SHA
  /// final oid = Oid.fromSHA(
  ///   repo: repo,
  ///   sha: '1234567890123456789012345678901234567890',
  /// );
  ///
  /// // Partial SHA
  /// final oid = Oid.fromSHA(
  ///   repo: repo,
  ///   sha: '123456',
  /// );
  /// ```
  ///
  /// Throws [ArgumentError] if provided [sha] hex string is not valid.
  /// A valid SHA hex string must:
  /// - Contain only hexadecimal characters (0-9, a-f, A-F)
  /// - Be between 4 and 64 characters in length
  ///
  /// Throws a [LibGit2Error] if:
  /// - The object with the given SHA cannot be found in the repository
  /// - The partial SHA is ambiguous (matches multiple objects)
  /// - Other Git-related errors occur
  Oid.fromSHA(Repository repo, String sha) {
    late git_oid_t type;
    if (sha.isValidSHA1()) {
      type = git_oid_t.GIT_OID_SHA1;
    } else if (sha.isValidSHA256()) {
      type = git_oid_t.GIT_OID_SHA256;
    } else {
      throw ArgumentError.value(
        sha,
        'sha',
        'Not a valid SHA hex string. Must be 4-64 hex characters.',
      );
    }

    final fullLength =
        type == git_oid_t.GIT_OID_SHA1 ? GIT_OID_SHA1_HEXSIZE : GIT_OID_SHA256_HEXSIZE;

    if (sha.length == fullLength) {
      _oidPointer = bindings.fromSHA(sha, type: type);
    } else {
      _oidPointer = odb_bindings.existsPrefix(
        odbPointer: repo.odb.pointer,
        shortOidPointer: bindings.fromStrN(sha, type: type),
        length: sha.length,
      );
    }
  }

  /// Initializes a new instance of [Oid] class from provided raw git_oid
  /// structure.
  ///
  /// Note: For internal use.
  @internal
  Oid.fromRaw(git_oid raw) {
    _oidPointer = bindings.fromRaw(raw.id);
  }

  late final Pointer<git_oid> _oidPointer;

  /// Pointer to memory address for allocated oid object.
  ///
  /// Note: For internal use.
  @internal
  Pointer<git_oid> get pointer => _oidPointer;

  /// Returns the hexadecimal string representation of this Oid.
  String get sha => bindings.toSHA(_oidPointer);

  /// Compares this Oid with another for sorting purposes.
  ///
  /// Returns true if this Oid is less than the [other].
  bool operator <(Oid other) {
    return bindings.compare(
          aPointer: _oidPointer,
          bPointer: other._oidPointer,
        ) <
        0;
  }

  /// Compares this Oid with another for sorting purposes.
  ///
  /// Returns true if this Oid is less than or equal to the [other].
  bool operator <=(Oid other) {
    return bindings.compare(
          aPointer: _oidPointer,
          bPointer: other._oidPointer,
        ) <=
        0;
  }

  /// Compares this Oid with another for sorting purposes.
  ///
  /// Returns true if this Oid is greater than the [other].
  bool operator >(Oid other) {
    return bindings.compare(
          aPointer: _oidPointer,
          bPointer: other._oidPointer,
        ) >
        0;
  }

  /// Compares this Oid with another for sorting purposes.
  ///
  /// Returns true if this Oid is greater than or equal to the [other].
  bool operator >=(Oid other) {
    return bindings.compare(
          aPointer: _oidPointer,
          bPointer: other._oidPointer,
        ) >=
        0;
  }

  @override
  String toString() => 'Oid{sha: $sha}';

  @override
  List<Object?> get props => [sha];
}
