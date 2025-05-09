import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/signature.dart' as bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git signature (author/committer).
///
/// This class encapsulates the information about who made a change to the repository,
/// including their name, email, and the time of the change. It is used in commits,
/// tags, and other Git operations that require attribution.
///
/// Example:
/// ```dart
/// // Create a signature with current timestamp
/// final signature = Signature.create(
///   name: 'John Doe',
///   email: 'john@example.com',
/// );
///
/// // Create a signature with specific timestamp
/// final signature = Signature.create(
///   name: 'John Doe',
///   email: 'john@example.com',
///   time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
///   offset: DateTime.now().timeZoneOffset.inMinutes,
/// );
///
/// // Get default signature from repository config
/// final signature = Signature.defaultSignature(repository);
/// ```
@immutable
class Signature extends Equatable {
  /// Initializes a new instance of [Signature] class from provided pointer to
  /// signature object in memory.
  ///
  /// This constructor is for internal use only. Instead, use one of:
  /// - [Signature.create] - to create a new signature with custom values
  /// - [Signature.defaultSignature] - to create a signature from repository config
  ///
  /// The constructor duplicates the provided pointer to ensure proper memory management.
  @internal
  Signature(Pointer<git_signature> pointer) {
    _signaturePointer = bindings.duplicate(pointer);
    _finalizer.attach(this, _signaturePointer, detach: this);
  }

  /// Creates new [Signature] from provided parameters.
  ///
  /// Creates a new signature with the specified name, email, and optional time
  /// information. If [time] is not provided, the current time will be used.
  ///
  /// Parameters:
  /// * [name] - The full name of the author/committer
  /// * [email] - The email address of the author/committer
  /// * [time] - Optional timestamp in seconds since epoch (Unix timestamp)
  /// * [offset] - Optional timezone offset in minutes (defaults to 0)
  ///
  /// Throws [LibGit2Error] if:
  /// * The name or email contains invalid characters (e.g., angle brackets)
  /// * Memory allocation fails
  /// * Other Git-related errors occur
  Signature.create({
    required String name,
    required String email,
    int? time,
    int offset = 0,
  }) {
    if (name.contains('<') ||
        name.contains('>') ||
        email.contains('<') ||
        email.contains('>')) {
      throw LibGit2Error(libgit2.git_error_last());
    }

    libgit2.git_libgit2_init();

    if (time == null) {
      _signaturePointer = bindings.now(name: name, email: email);
    } else {
      _signaturePointer = bindings.create(
        name: name,
        email: email,
        time: time,
        offset: offset,
      );
    }
    _finalizer.attach(this, _signaturePointer, detach: this);
  }

  /// Creates a new signature with default user information from repository config.
  ///
  /// This method looks up the user.name and user.email from the repository's
  /// configuration and uses the current time as the timestamp.
  ///
  /// Parameters:
  /// * [repo] - The repository to get the default signature from
  ///
  /// Throws [LibGit2Error] if:
  /// * The repository configuration is missing user.name or user.email
  /// * Memory allocation fails
  /// * Other Git-related errors occur
  Signature.defaultSignature(Repository repo) {
    _signaturePointer = bindings.defaultSignature(repo.pointer);
    _finalizer.attach(this, _signaturePointer, detach: this);
  }

  late final Pointer<git_signature> _signaturePointer;

  /// Pointer to memory address for allocated signature object.
  ///
  /// This getter is for internal use only and should not be used by external code.
  @internal
  Pointer<git_signature> get pointer => _signaturePointer;

  /// Full name of the author/committer.
  ///
  /// Returns the name that was provided when creating the signature.
  String get name => _signaturePointer.ref.name.toDartString();

  /// Email address of the author/committer.
  ///
  /// Returns the email that was provided when creating the signature.
  String get email => _signaturePointer.ref.email.toDartString();

  /// Time in seconds from epoch (Unix timestamp).
  ///
  /// Returns the timestamp when the signature was created.
  int get time => _signaturePointer.ref.when.time;

  /// Timezone offset in minutes.
  ///
  /// Returns the timezone offset that was provided when creating the signature.
  int get offset => _signaturePointer.ref.when.offset;

  /// Indicator for questionable '-0000' offsets in signature.
  ///
  /// Returns a character indicating the sign of the timezone offset.
  String get sign => String.fromCharCode(_signaturePointer.ref.when.sign);

  /// Releases memory allocated for signature object.
  ///
  /// This method should be called when the signature is no longer needed to
  /// prevent memory leaks. However, if the signature was created using one of
  /// the public constructors, the memory will be automatically freed when the
  /// object is garbage collected.
  void free() {
    bindings.free(_signaturePointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'Signature{name: $name, email: $email, time: $time, '
        'offset: $sign$offset}';
  }

  @override
  List<Object?> get props => [name, email, time, offset, sign];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_signature>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
