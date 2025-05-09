// coverage:ignore-file

import 'dart:ffi';

import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Represents an error that occurred in libgit2.
///
/// This class provides access to the last error that occurred in libgit2 operations.
/// It wraps the native `git_error` structure and provides a Dart-friendly interface
/// to access error information.
class LibGit2Error {
  /// Creates a new instance of [LibGit2Error] from a native error pointer.
  ///
  /// Note: This constructor is for internal use only.
  @internal
  LibGit2Error(this._errorPointer);

  final Pointer<git_error> _errorPointer;

  /// Gets the error message associated with this error.
  String get message => _errorPointer.ref.message.toDartString();

  /// Gets the error class associated with this error.
  int get errorClass => _errorPointer.ref.klass;

  @override
  String toString() => message;

  /// Gets the last error that occurred.
  ///
  /// Returns null if no error has occurred.
  static LibGit2Error? getLastError() {
    final error = libgit2.git_error_last();
    return error == nullptr ? null : LibGit2Error(error);
  }
}
