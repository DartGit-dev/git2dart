import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/odb.dart' as odb_bindings;
import 'package:git2dart/src/bindings/oid.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Represents a unique identifier (SHA-1) for a Git object.
///
/// The [Oid] class provides functionality to work with Git object identifiers,
/// which are SHA-1 hashes used to uniquely identify objects in a Git repository.
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
  /// string that is 40 characters long or shorter.
  ///
  /// The [sha] parameter can be either:
  /// - A full 40-character SHA-1 hash
  /// - A partial SHA-1 hash (prefix of the full hash)
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
  /// - Be between 4 and 40 characters in length
  ///
  /// Throws a [LibGit2Error] if:
  /// - The object with the given SHA cannot be found in the repository
  /// - The partial SHA is ambiguous (matches multiple objects)
  /// - Other Git-related errors occur
  Oid.fromSHA(Repository repo, String sha) {
    if (sha.isValidSHA1()) {
      if (sha.length == 40) {
        _oidPointer = bindings.fromSHA(sha);
      } else {
        _oidPointer = odb_bindings.existsPrefix(
          odbPointer: repo.odb.pointer,
          shortOidPointer: bindings.fromStrN(sha),
          length: sha.length,
        );
      }
    } else {
      throw ArgumentError.value(
        sha,
        'sha',
        'Not a valid SHA hex string. Must be 4-40 hex characters.',
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

  /// The full 40-character hexadecimal SHA-1 hash string.
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
