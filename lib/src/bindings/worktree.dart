import 'dart:ffi';

import 'package:ffi/ffi.dart' show using;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
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
  return using((arena) {
    final out = arena<Pointer<git_worktree>>();
    final nameC = name.toChar(arena);
    final pathC = path.toChar(arena);

    final opts = arena<git_worktree_add_options>();
    libgit2.git_worktree_add_options_init(
      opts,
      GIT_WORKTREE_ADD_OPTIONS_VERSION,
    );

    opts.ref.ref = refPointer ?? nullptr;

    final error = libgit2.git_worktree_add(
      out,
      repoPointer,
      nameC,
      pathC,
      opts,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
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
  return using((arena) {
    final out = arena<Pointer<git_worktree>>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_worktree_lookup(out, repoPointer, nameC);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Open a worktree from a repository by path.
Pointer<git_worktree> openFromRepository({
  required Pointer<git_repository> repoPointer,
  required String path,
}) {
  return using((arena) {
    final out = arena<Pointer<git_worktree>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_worktree_open_from_repository(
      out,
      repoPointer,
      pathC,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Open a repository from an existing worktree.
Pointer<git_repository> repositoryFromWorktree(Pointer<git_worktree> wt) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final error = libgit2.git_repository_open_from_worktree(out, wt);
    checkErrorAndThrow(error);
    return out.value;
  });
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
  return using((arena) {
    final opts = arena<git_worktree_prune_options>();
    libgit2.git_worktree_prune_options_init(
      opts,
      GIT_WORKTREE_PRUNE_OPTIONS_VERSION,
    );
    return libgit2.git_worktree_is_prunable(wt, opts) > 0;
  });
}

/// Prunes a working tree by removing its git data structures from disk.
///
/// [worktreePointer] is the worktree to prune.
/// [flags] is an optional combination of prune flags.
///
/// Throws a [LibGit2Error] if an error occurs.
void prune({required Pointer<git_worktree> worktreePointer, int? flags}) {
  using((arena) {
    final opts = arena<git_worktree_prune_options>();
    libgit2.git_worktree_prune_options_init(
      opts,
      GIT_WORKTREE_PRUNE_OPTIONS_VERSION,
    );

    if (flags != null) {
      opts.ref.flags = flags;
    }

    final error = libgit2.git_worktree_prune(worktreePointer, opts);
    checkErrorAndThrow(error);
  });
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
  return using((arena) {
    final out = arena<git_strarray>();
    final error = libgit2.git_worktree_list(out, repo);
    checkErrorAndThrow(error);

    final result = <Pointer<git_worktree>>[];
    for (var i = 0; i < out.ref.count; i++) {
      final name = out.ref.strings[i].toDartString();
      try {
        final worktree = lookup(repoPointer: repo, name: name);
        result.add(worktree);
      } catch (_) {
        // Skip invalid worktrees
        continue;
      }
    }
    return result;
  });
}

/// Gets the name of a worktree.
///
/// [wt] is the worktree to get the name from.
///
/// Returns the name of the worktree.
String name(Pointer<git_worktree> wt) =>
    libgit2.git_worktree_name(wt).toDartString();

/// Gets the filesystem path of a worktree.
///
/// [wt] is the worktree to get the path from.
///
/// Returns the filesystem path of the worktree.
String path(Pointer<git_worktree> wt) =>
    libgit2.git_worktree_path(wt).toDartString();

/// Checks if a worktree is locked.
///
/// A worktree may be locked if the linked working tree is stored on a portable
/// device which is not available.
///
/// [wt] is the worktree to check.
///
/// Returns true if the worktree is locked, false otherwise.
bool isLocked(Pointer<git_worktree> wt) {
  return using((arena) {
    final reason = arena<git_buf>();
    return libgit2.git_worktree_is_locked(reason, wt) == 1;
  });
}

/// Locks a worktree if it is not already locked.
///
/// [worktree] is the worktree to lock.
/// [reason] is an optional reason for locking the worktree.
///
/// Throws a [LibGit2Error] if an error occurs.
void lock(Pointer<git_worktree> worktree, [String? reason]) {
  using((arena) {
    final reasonC = reason != null ? reason.toChar(arena) : nullptr;
    final error = libgit2.git_worktree_lock(worktree, reasonC);
    checkErrorAndThrow(error);
  });
}

/// Unlocks a locked worktree.
///
/// [worktree] is the worktree to unlock.
///
/// Throws a [LibGit2Error] if an error occurs.
void unlock(Pointer<git_worktree> worktree) {
  final error = libgit2.git_worktree_unlock(worktree);
  checkErrorAndThrow(error);
}

/// Checks if a worktree is valid.
///
/// A valid worktree requires both the git data structures inside the linked
/// parent repository and the linked working copy to be present.
///
/// [wt] is the worktree to validate.
///
/// Returns true if the worktree is valid, false otherwise.
bool isValid(Pointer<git_worktree> wt) =>
    libgit2.git_worktree_validate(wt) == 0;

/// Validates a worktree configuration.
///
/// [worktree] is the worktree to validate.
///
/// Throws a [LibGit2Error] if the worktree is invalid.
void validate(Pointer<git_worktree> worktree) {
  final error = libgit2.git_worktree_validate(worktree);
  checkErrorAndThrow(error);
}

/// Frees a previously allocated worktree.
///
/// [wt] is the worktree to free.
void free(Pointer<git_worktree> wt) => libgit2.git_worktree_free(wt);
