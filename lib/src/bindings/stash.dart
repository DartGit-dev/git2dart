import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc, using;
import 'package:git2dart/src/bindings/checkout.dart' as checkout_bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart/src/oid.dart';
import 'package:git2dart/src/stash.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Saves the current working directory state to a new stash.
///
/// This function takes a snapshot of the current working directory and index,
/// saves it to a new stash entry, and reverts the working directory to a clean
/// state.
///
/// Parameters:
/// - [repoPointer]: Pointer to the repository
/// - [stasherPointer]: Pointer to the signature of the person performing the stash
/// - [message]: Optional description of the stashed changes
/// - [flags]: Flags to control stash behavior
///
/// Returns a pointer to the [git_oid] of the newly created stash commit.
///
/// Throws a [LibGit2Error] if an error occurs during the stash operation.
Pointer<git_oid> save({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_signature> stasherPointer,
  String? message,
  required int flags,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final messageC = message?.toChar(arena) ?? nullptr;

    final error = libgit2.git_stash_save(
      out,
      repoPointer,
      stasherPointer,
      messageC,
      flags,
    );

    checkErrorAndThrow(error);
    return out;
  });
}

/// Applies a stashed state to the working directory.
///
/// This function takes a stashed state and applies it to the current working
/// directory, without removing it from the stash list.
///
/// Parameters:
/// - [repoPointer]: Pointer to the repository
/// - [index]: The position of the stash to apply (0 being the most recent)
/// - [flags]: Flags to control the apply behavior
/// - [strategy]: Checkout strategy to use when applying changes
/// - [directory]: Optional alternative checkout path
/// - [paths]: Optional list of paths to apply the stash to
///
/// Throws a [LibGit2Error] if an error occurs during the apply operation.
void apply({
  required Pointer<git_repository> repoPointer,
  required int index,
  required int flags,
  required int strategy,
  String? directory,
  List<String>? paths,
}) {
  using((arena) {
    final options = arena<git_stash_apply_options>();
    libgit2.git_stash_apply_options_init(
      options,
      GIT_STASH_APPLY_OPTIONS_VERSION,
    );

    final checkoutOptions = checkout_bindings.initOptions(
      arena: arena,
      strategy: strategy,
      directory: directory,
      paths: paths,
    );
    final optsC = checkoutOptions[0] as Pointer<git_checkout_options>;
    options.ref.flags = flags;
    options.ref.checkout_options = optsC.ref;

    final error = libgit2.git_stash_apply(repoPointer, index, options);
    checkErrorAndThrow(error);
  });
}

/// Removes a stashed state from the stash list.
///
/// This function permanently removes a stash entry from the repository.
///
/// Parameters:
/// - [repoPointer]: Pointer to the repository
/// - [index]: The position of the stash to remove (0 being the most recent)
///
/// Throws a [LibGit2Error] if an error occurs during the drop operation.
void drop({required Pointer<git_repository> repoPointer, required int index}) {
  final error = libgit2.git_stash_drop(repoPointer, index);
  checkErrorAndThrow(error);
}

/// Applies a stashed state and removes it from the stash list.
///
/// This function combines apply and drop operations - it applies the stash
/// to the working directory and then removes it from the stash list if the
/// apply was successful.
///
/// Parameters:
/// - [repoPointer]: Pointer to the repository
/// - [index]: The position of the stash to pop (0 being the most recent)
/// - [flags]: Flags to control the pop behavior
/// - [strategy]: Checkout strategy to use when applying changes
/// - [directory]: Optional alternative checkout path
/// - [paths]: Optional list of paths to apply the stash to
///
/// Throws a [LibGit2Error] if an error occurs during the pop operation.
void pop({
  required Pointer<git_repository> repoPointer,
  required int index,
  required int flags,
  required int strategy,
  String? directory,
  List<String>? paths,
}) {
  using((arena) {
    final options = arena<git_stash_apply_options>();
    libgit2.git_stash_apply_options_init(
      options,
      GIT_STASH_APPLY_OPTIONS_VERSION,
    );

    final checkoutOptions = checkout_bindings.initOptions(
      arena: arena,
      strategy: strategy,
      directory: directory,
      paths: paths,
    );
    final optsC = checkoutOptions[0] as Pointer<git_checkout_options>;
    options.ref.flags = flags;
    options.ref.checkout_options = optsC.ref;

    final error = libgit2.git_stash_pop(repoPointer, index, options);
    checkErrorAndThrow(error);
  });
}

/// Global list to store stash entries during iteration.
/// This is used by the [list] function to collect stash entries.
final _stashList = <Stash>[];

/// Callback function used by [list] to collect stash entries.
///
/// This function is called for each stash entry in the repository and adds
/// the entry to the [_stashList].
///
/// Parameters:
/// - [index]: The position of the stash in the list
/// - [message]: The stash message
/// - [oid]: The commit OID containing the stashed changes
/// - [payload]: Unused payload pointer
///
/// Returns 0 to continue iteration.
int _stashCb(
  int index,
  Pointer<Char> message,
  Pointer<git_oid> oid,
  Pointer<Void> payload,
) {
  _stashList.add(
    Stash(
      index: index,
      message: message.toDartString(),
      oid: Oid.fromRaw(oid.ref),
    ),
  );
  return 0;
}

/// Lists all stashed states in the repository.
///
/// This function iterates over all stash entries in the repository and returns
/// them as a list of [Stash] objects, with the most recent stash first.
///
/// Parameters:
/// - [repo]: Pointer to the repository
///
/// Returns a list of [Stash] objects representing all stashed changes.
///
/// Throws a [LibGit2Error] if an error occurs while listing stashes.
List<Stash> list(Pointer<git_repository> repo) {
  const except = -1;
  // ignore: omit_local_variable_types
  final git_stash_cb callBack = Pointer.fromFunction(_stashCb, except);

  try {
    final error = libgit2.git_stash_foreach(repo, callBack, nullptr);
    checkErrorAndThrow(error);
    return _stashList.toList(growable: false);
  } finally {
    _stashList.clear();
  }
}
