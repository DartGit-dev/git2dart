// coverage:ignore-file

import 'dart:ffi';

import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Details of the last error that occurred.
class LibGit2Error {
  /// Note: For internal use.
  @internal
  LibGit2Error(this._errorPointer);

  final Pointer<git_error> _errorPointer;

  @override
  String toString() => _errorPointer.ref.message.toDartString();
}
