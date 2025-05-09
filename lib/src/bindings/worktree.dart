import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/error.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Creates a new working tree for the repository.
///
/// This function creates the required data structures inside the repository
/// and checks out the current HEAD at the specified path.
///
/// [repoPointer] is the repository to add the worktree to.
/// [name] is the name of the new worktree.
/// [path] is the filesystem path where the worktree will be created.
/// [refPointer] is an optional reference to checkout (if null, HEAD is used).
///
/// Returns a pointer to the newly created worktree. The returned worktree
/// must be freed with [free].
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_worktree> create({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String path,
  Pointer<git_reference>? refPointer,
}) {
  final out = calloc<Pointer<git_worktree>>();
  final nameC = name.toChar();
  final pathC = path.toChar();

  final opts = calloc<git_worktree_add_options>();
  libgit2.git_worktree_add_options_init(opts, GIT_WORKTREE_ADD_OPTIONS_VERSION);

  opts.ref.ref = nullptr;
  if (refPointer != null) {
    opts.ref.ref = refPointer;
  }

  final error = libgit2.git_worktree_add(out, repoPointer, nameC, pathC, opts);

  final result = out.value;

  calloc.free(out);
  calloc.free(nameC);
  calloc.free(pathC);
  calloc.free(opts);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Looks up a working tree by its name in the given repository.
///
/// [repoPointer] is the repository containing the worktree.
/// [name] is the name of the worktree to look up.
///
/// Returns a pointer to the found worktree. The returned worktree
/// must be freed with [free].
///
/// Throws a [LibGit2Error] if an error occurs or if the worktree is not found.
Pointer<git_worktree> lookup({
  required Pointer<git_repository> repoPointer,
  required String name,
}) {
  final out = calloc<Pointer<git_worktree>>();
  final nameC = name.toChar();
  final error = libgit2.git_worktree_lookup(out, repoPointer, nameC);

  final result = out.value;

  calloc.free(out);
  calloc.free(nameC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Checks if a worktree is prunable.
///
/// A worktree is not prunable in the following scenarios:
/// - The worktree is linking to a valid on-disk worktree
/// - The worktree is locked
///
/// [wt] is the worktree to check.
///
/// Returns true if the worktree is prunable, false otherwise.
///
/// Throws a [LibGit2Error] if an error occurs.
bool isPrunable(Pointer<git_worktree> wt) {
  final opts = calloc<git_worktree_prune_options>();
  libgit2.git_worktree_prune_options_init(
    opts,
    GIT_WORKTREE_PRUNE_OPTIONS_VERSION,
  );

  final result = libgit2.git_worktree_is_prunable(wt, opts);

  calloc.free(opts);

  return result > 0 || false;
}

/// Prunes a working tree by removing its git data structures from disk.
///
/// [worktreePointer] is the worktree to prune.
/// [flags] is an optional combination of prune flags.
///
/// Throws a [LibGit2Error] if an error occurs.
void prune({required Pointer<git_worktree> worktreePointer, int? flags}) {
  final opts = calloc<git_worktree_prune_options>();
  libgit2.git_worktree_prune_options_init(
    opts,
    GIT_WORKTREE_PRUNE_OPTIONS_VERSION,
  );

  if (flags != null) opts.ref.flags = flags;

  final error = libgit2.git_worktree_prune(worktreePointer, opts);
  calloc.free(opts);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Lists all working trees in the repository.
///
/// [repo] is the repository to list worktrees from.
///
/// Returns a list of pointers to worktrees. Each worktree in the returned list
/// must be freed with [free].
///
/// Throws a [LibGit2Error] if an error occurs.
List<Pointer<git_worktree>> list(Pointer<git_repository> repo) {
  final out = calloc<git_strarray>();
  final error = libgit2.git_worktree_list(out, repo);

  if (error < 0) {
    calloc.free(out);
    throw LibGit2Error(libgit2.git_error_last());
  }

  final result = <Pointer<git_worktree>>[];
  for (var i = 0; i < out.ref.count; i++) {
    final worktree = calloc<Pointer<git_worktree>>();
    final name = out.ref.strings[i].toDartString();
    final nameC = name.toChar();
    final lookupError = libgit2.git_worktree_lookup(worktree, repo, nameC);

    if (lookupError < 0) {
      calloc.free(worktree);
      calloc.free(nameC);
      continue;
    }

    result.add(worktree.value);
    calloc.free(worktree);
    calloc.free(nameC);
  }

  calloc.free(out);
  return result;
}

/// Gets the name of a worktree.
///
/// [wt] is the worktree to get the name from.
///
/// Returns the name of the worktree.
String name(Pointer<git_worktree> wt) {
  return libgit2.git_worktree_name(wt).toDartString();
}

/// Gets the filesystem path of a worktree.
///
/// [wt] is the worktree to get the path from.
///
/// Returns the filesystem path of the worktree.
String path(Pointer<git_worktree> wt) {
  return libgit2.git_worktree_path(wt).toDartString();
}

/// Checks if a worktree is locked.
///
/// A worktree may be locked if the linked working tree is stored on a portable
/// device which is not available.
///
/// [wt] is the worktree to check.
///
/// Returns true if the worktree is locked, false otherwise.
bool isLocked(Pointer<git_worktree> wt) {
  final reason = calloc<git_buf>();
  final result = libgit2.git_worktree_is_locked(reason, wt) == 1 || false;
  calloc.free(reason);
  return result;
}

/// Locks a worktree if it is not already locked.
///
/// [worktree] is the worktree to lock.
/// [reason] is an optional reason for locking the worktree.
///
/// Throws a [LibGit2Error] if an error occurs.
void lock(Pointer<git_worktree> worktree, [String? reason]) {
  final reasonC = reason?.toChar() ?? nullptr;
  final error = libgit2.git_worktree_lock(worktree, reasonC);

  if (reasonC != nullptr) {
    calloc.free(reasonC);
  }

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Unlocks a locked worktree.
///
/// [worktree] is the worktree to unlock.
///
/// Throws a [LibGit2Error] if an error occurs.
void unlock(Pointer<git_worktree> worktree) {
  final error = libgit2.git_worktree_unlock(worktree);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Checks if a worktree is valid.
///
/// A valid worktree requires both the git data structures inside the linked
/// parent repository and the linked working copy to be present.
///
/// [wt] is the worktree to validate.
///
/// Returns true if the worktree is valid, false otherwise.
bool isValid(Pointer<git_worktree> wt) {
  return libgit2.git_worktree_validate(wt) == 0 || false;
}

/// Validates a worktree configuration.
///
/// [worktree] is the worktree to validate.
///
/// Throws a [LibGit2Error] if the worktree is invalid.
void validate(Pointer<git_worktree> worktree) {
  final error = libgit2.git_worktree_validate(worktree);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Frees a previously allocated worktree.
///
/// [wt] is the worktree to free.
void free(Pointer<git_worktree> wt) => libgit2.git_worktree_free(wt);
