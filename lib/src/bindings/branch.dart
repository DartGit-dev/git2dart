import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/bindings/reference.dart' as reference_bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Return a list of branches. The returned references must be freed with
/// [free].
///
/// Throws a [LibGit2Error] if error occured.
List<Pointer<git_reference>> list({
  required Pointer<git_repository> repoPointer,
  required int flags,
}) {
  return using((arena) {
    final iterator = arena<Pointer<git_branch_iterator>>();
    final iteratorError = libgit2.git_branch_iterator_new(
      iterator,
      repoPointer,
      git_branch_t.fromValue(flags),
    );

    checkErrorAndThrow(iteratorError);

    final result = <Pointer<git_reference>>[];
    var error = 0;

    while (error == 0) {
      final reference = arena<Pointer<git_reference>>();
      final refType = arena<UnsignedInt>();
      error = libgit2.git_branch_next(reference, refType, iterator.value);
      if (error == 0) {
        result.add(reference.value);
      } else {
        break;
      }
    }

    libgit2.git_branch_iterator_free(iterator.value);
    return result;
  });
}

/// Lookup a branch by its name in a repository. The returned reference must be
/// freed with [free].
///
/// The branch name will be checked for validity.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_reference> lookup({
  required Pointer<git_repository> repoPointer,
  required String branchName,
  required int branchType,
}) {
  return using((arena) {
    final out = arena<Pointer<git_reference>>();
    final branchNameC = branchName.toChar();
    final error = libgit2.git_branch_lookup(
      out,
      repoPointer,
      branchNameC,
      git_branch_t.fromValue(branchType),
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a new branch pointing at a target commit. The returned reference
/// must be freed with [free].
///
/// A new direct reference will be created pointing to this target commit.
/// If force is true and a reference already exists with the given name, it'll
/// be replaced.
///
/// The branch name will be checked for validity.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_reference> create({
  required Pointer<git_repository> repoPointer,
  required String branchName,
  required Pointer<git_commit> targetPointer,
  required bool force,
}) {
  return using((arena) {
    final out = arena<Pointer<git_reference>>();
    final branchNameC = branchName.toChar();
    final forceC = force ? 1 : 0;
    final error = libgit2.git_branch_create(
      out,
      repoPointer,
      branchNameC,
      targetPointer,
      forceC,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Delete an existing branch reference.
///
/// Note that if the deletion succeeds, the reference object will not be valid
/// anymore, and should be freed immediately with [free].
///
/// Throws a [LibGit2Error] if error occured.
void delete(Pointer<git_reference> branch) {
  final error = libgit2.git_branch_delete(branch);
  checkErrorAndThrow(error);
}

/// Move/rename an existing local branch reference.
///
/// The new branch name will be checked for validity.
///
/// Note that if the move succeeds, the old reference object will not be valid
/// anymore, and should be freed immediately with [free].
///
/// Throws a [LibGit2Error] if error occured.
void rename({
  required Pointer<git_reference> branchPointer,
  required String newBranchName,
  required bool force,
}) {
  using((arena) {
    final out = arena<Pointer<git_reference>>();
    final newBranchNameC = newBranchName.toChar();
    final forceC = force ? 1 : 0;
    final error = libgit2.git_branch_move(
      out,
      branchPointer,
      newBranchNameC,
      forceC,
    );

    reference_bindings.free(out.value);
    checkErrorAndThrow(error);
  });
}

/// Check if a branch is the current HEAD.
///
/// Given a reference object, this will check if the branch it refers to is
/// the current HEAD branch.
///
/// Returns true if the branch is the HEAD branch, false otherwise.
///
/// Throws a [LibGit2Error] if error occurred.
bool isHead(Pointer<git_reference> ref) {
  final result = libgit2.git_branch_is_head(ref);
  checkErrorAndThrow(result);
  return result == 1;
}

/// Check if a branch is checked out in any linked worktree.
///
/// This will iterate over all known linked repositories (usually in the form
/// of worktrees) and report whether any HEAD is pointing at the current
/// branch.
///
/// Returns true if the branch is checked out in any worktree, false otherwise.
///
/// Throws a [LibGit2Error] if error occurred.
bool isCheckedOut(Pointer<git_reference> ref) {
  final result = libgit2.git_branch_is_checked_out(ref);
  checkErrorAndThrow(result);
  return result == 1;
}

/// Get the branch name.
///
/// Throws a [LibGit2Error] if error occurred.
String getName(Pointer<git_reference> ref) {
  return using((arena) {
    final out = arena<Pointer<Char>>();
    final error = libgit2.git_branch_name(out, ref);

    checkErrorAndThrow(error);
    return out.value.cast<Utf8>().toDartString();
  });
}

/// Find the remote name of a remote-tracking branch.
///
/// This will return the name of the remote whose fetch refspec is matching the
/// given branch. E.g. given a branch "refs/remotes/test/master", it will extract
/// the "test" part.
///
/// Throws a [LibGit2Error] if refspecs from multiple remotes match or if error
/// occured.
String remoteName({
  required Pointer<git_repository> repoPointer,
  required String branchName,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final branchNameC = branchName.toChar();
    final error = libgit2.git_branch_remote_name(out, repoPointer, branchNameC);

    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Get the upstream of a branch. The returned reference must be freed with
/// [free].
///
/// Given a reference, this will return a new reference object corresponding to
/// its remote tracking branch. The reference must be a local branch.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_reference> getUpstream(Pointer<git_reference> branch) {
  return using((arena) {
    final out = arena<Pointer<git_reference>>();
    final error = libgit2.git_branch_upstream(out, branch);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Set the upstream configuration for a local branch.
///
/// Throws a [LibGit2Error] if error occurred.
void setUpstream({
  required Pointer<git_reference> refPointer,
  required String? branchName,
}) {
  using((arena) {
    final branchNameC = branchName?.toChar() ?? nullptr;
    final error = libgit2.git_branch_set_upstream(refPointer, branchNameC);
    checkErrorAndThrow(error);
  });
}

/// Get the upstream name of a branch.
///
/// Given a local branch, this will return its remote-tracking branch
/// information, as a full reference name, ie. "feature/nice" would become
/// "refs/remotes/origin/feature/nice", depending on that branch's configuration.
///
/// Throws a [LibGit2Error] if error occured.
String upstreamName({
  required Pointer<git_repository> repoPointer,
  required String branchName,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final branchNameC = branchName.toChar();
    final error = libgit2.git_branch_upstream_name(
      out,
      repoPointer,
      branchNameC,
    );

    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Retrieve the upstream remote of a local branch.
///
/// This will return the currently configured "branch.*.remote" for a given
/// branch. This branch must be local.
///
/// Throws a [LibGit2Error] if error occured.
String upstreamRemote({
  required Pointer<git_repository> repoPointer,
  required String branchName,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final branchNameC = branchName.toChar();
    final error = libgit2.git_branch_upstream_remote(
      out,
      repoPointer,
      branchNameC,
    );

    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Retrieve the upstream merge of a local branch.
///
/// This will return the currently configured "branch.*.merge" for a given
/// branch. This branch must be local.
///
/// Throws a [LibGit2Error] if error occured.
String upstreamMerge({
  required Pointer<git_repository> repoPointer,
  required String branchName,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final branchNameC = branchName.toChar();
    final error = libgit2.git_branch_upstream_merge(
      out,
      repoPointer,
      branchNameC,
    );

    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Free the given reference to release memory.
void free(Pointer<git_reference> ref) => reference_bindings.free(ref);
