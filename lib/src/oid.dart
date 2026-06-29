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

  /// Initializes a new instance by parsing a possibly shortened hexadecimal
  /// object id.
  ///
  /// Missing trailing digits are zero-filled by libgit2.
  Oid.fromSHAParse(String sha) {
    if (!sha.isValidSHA1() && !sha.isValidSHA256()) {
      throw ArgumentError.value(
        sha,
        'sha',
        'Not a valid SHA hex string. Must be 4-64 hex characters.',
      );
    }

    final type =
        sha.length > GIT_OID_SHA1_HEXSIZE
            ? git_oid_t.GIT_OID_SHA256
            : git_oid_t.GIT_OID_SHA1;
    _oidPointer = bindings.fromStrP(sha, type: type);
  }

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
        type == git_oid_t.GIT_OID_SHA1
            ? GIT_OID_SHA1_HEXSIZE
            : GIT_OID_SHA256_HEXSIZE;

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

  /// Formats this Oid into a string buffer with [length] bytes.
  String toStr(int length) => bindings.toStr(id: _oidPointer, length: length);

  /// Formats this Oid into exactly [length] hexadecimal characters.
  String toStrN(int length) => bindings.toStrN(id: _oidPointer, length: length);

  /// Formats this Oid using libgit2's thread-local formatter.
  String toStrS() => bindings.toStrS(_oidPointer);

  /// Compares this Oid to a hexadecimal object id string.
  int compareToHex(String hex) => bindings.strcmp(id: _oidPointer, hex: hex);

  /// Returns whether this Oid equals a hexadecimal object id string.
  bool equalsHex(String hex) => bindings.streq(id: _oidPointer, hex: hex);

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

/// Calculates short unique prefixes for a set of SHA-1 object ids.
class OidShortener {
  /// Creates an OID shortener with [minLength] as the minimum abbreviation.
  OidShortener({int minLength = GIT_OID_MINPREFIXLEN}) {
    _shortenerPointer = bindings.shortenNew(minLength);
    _shortenerFinalizer.attach(this, _shortenerPointer, detach: this);
  }

  late final Pointer<git_oid_shorten> _shortenerPointer;

  /// Adds [oid] and returns the minimum unique prefix length so far.
  int add(Oid oid) =>
      bindings.shortenAdd(shortenerPointer: _shortenerPointer, hex: oid.sha);

  /// Adds [sha] and returns the minimum unique prefix length so far.
  int addHex(String sha) =>
      bindings.shortenAdd(shortenerPointer: _shortenerPointer, hex: sha);

  /// Releases memory allocated for this shortener.
  void free() {
    bindings.shortenFree(_shortenerPointer);
    _shortenerFinalizer.detach(this);
  }
}

final _shortenerFinalizer = Finalizer<Pointer<git_oid_shorten>>(
  (pointer) => bindings.shortenFree(pointer),
);
