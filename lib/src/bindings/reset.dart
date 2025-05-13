import 'dart:ffi';

import 'package:ffi/ffi.dart' show using;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Performs a reset operation on the repository, moving the HEAD and optionally
/// updating the index and working tree to match the specified commit.
///
/// The reset operation can be performed in three modes:
/// - [git_reset_t.GIT_RESET_SOFT]: Only moves the HEAD to the target commit
/// - [git_reset_t.GIT_RESET_MIXED]: Moves HEAD and updates the index to match the target commit
/// - [git_reset_t.GIT_RESET_HARD]: Moves HEAD, updates index, and updates working tree to match
///
/// Parameters:
/// - [repoPointer]: Pointer to the repository to reset
/// - [targetPointer]: Pointer to the target commit object to reset to
/// - [resetType]: Type of reset to perform (soft, mixed, or hard)
/// - [strategy]: Optional checkout strategy flags for working tree updates
/// - [checkoutDirectory]: Optional alternative directory for checkout
/// - [pathspec]: Optional list of paths to limit the reset operation
///
/// Throws a [LibGit2Error] if the reset operation fails.
void reset({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_object> targetPointer,
  required git_reset_t resetType,
  int? strategy,
  String? checkoutDirectory,
  List<String>? pathspec,
}) {
  using((arena) {
    final opts = arena<git_checkout_options>();
    libgit2.git_checkout_options_init(opts, GIT_CHECKOUT_OPTIONS_VERSION);

    if (strategy != null) {
      opts.ref.checkout_strategy = strategy;
    }
    if (checkoutDirectory != null) {
      opts.ref.target_directory = checkoutDirectory.toChar(arena);
    }

    if (pathspec != null) {
      final pathPointers = pathspec.map((e) => e.toChar(arena)).toList();
      final strArray = arena<Pointer<Char>>(pathspec.length);
      for (var i = 0; i < pathspec.length; i++) {
        strArray[i] = pathPointers[i];
      }
      opts.ref.paths.strings = strArray;
      opts.ref.paths.count = pathspec.length;
    }

    final error = libgit2.git_reset(
      repoPointer,
      targetPointer,
      resetType,
      opts,
    );
    checkErrorAndThrow(error);
  });
}

/// Updates specific entries in the index from the target commit tree.
///
/// This function allows for more granular control over the reset operation by
/// only updating specific paths in the index. It can be used to:
/// - Update specific files to match the target commit
/// - Remove specific files from the index
/// - Reset specific paths to their state in the target commit
///
/// Parameters:
/// - [repoPointer]: Pointer to the repository to reset
/// - [targetPointer]: Pointer to the target commit object, or null to remove entries
/// - [pathspec]: List of paths to update in the index
///
/// Throws a [LibGit2Error] if the reset operation fails.
void resetDefault({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_object>? targetPointer,
  required List<String> pathspec,
}) {
  using((arena) {
    final pathspecC = arena<git_strarray>();
    final pathPointers = pathspec.map((e) => e.toChar(arena)).toList();
    final strArray = arena<Pointer<Char>>(pathspec.length);

    for (var i = 0; i < pathspec.length; i++) {
      strArray[i] = pathPointers[i];
    }

    pathspecC.ref.strings = strArray;
    pathspecC.ref.count = pathspec.length;

    final error = libgit2.git_reset_default(
      repoPointer,
      targetPointer ?? nullptr,
      pathspecC,
    );

    checkErrorAndThrow(error);
  });
}
