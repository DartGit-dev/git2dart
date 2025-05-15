import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Helper function to handle libgit2 errors
@pragma("vm:prefer-inline")
void checkErrorAndThrow(int error) {
  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}
