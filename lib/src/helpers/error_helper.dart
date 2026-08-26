import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Helper function to handle libgit2 errors
@pragma("vm:prefer-inline")
void checkErrorAndThrow(int error) {
  if (error < 0) {
    throwLastError();
  }
}

/// Throws the last error reported by the native library.
Never throwLastError() {
  final error = libgit2Runtime.bindings.getLastError();
  if (error != null) {
    throw error;
  }

  throw StateError('libgit2 failed without providing an error.');
}
