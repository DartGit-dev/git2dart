import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Creates an annotated commit from the given commit id.
///
/// The returned annotated commit must be freed with [free].
/// An annotated commit contains information about how it was looked up,
/// which may be useful for functions like merge or rebase to provide context
/// to the operation. For example, conflict files will include the name of the
/// source or target branches being merged.
///
/// It is therefore preferable to use the most specific function (e.g. [fromRef])
/// instead of this one when that data is known.
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_annotated_commit> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_annotated_commit>>();
    final error = libgit2.git_annotated_commit_lookup(
      out,
      repoPointer,
      oidPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Creates an annotated commit from the given reference.
///
/// The returned annotated commit must be freed with [free].
/// This is the preferred method to create an annotated commit as it preserves
/// the reference information.
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_annotated_commit> fromRef({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_reference> referencePointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_annotated_commit>>();
    final error = libgit2.git_annotated_commit_from_ref(
      out,
      repoPointer,
      referencePointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Creates an annotated commit from a revision string.
///
/// The returned annotated commit must be freed with [free].
/// See `man gitrevisions`, or http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions
/// for information on the syntax accepted.
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_annotated_commit> fromRevSpec({
  required Pointer<git_repository> repoPointer,
  required String revspec,
}) {
  return using((arena) {
    final out = arena<Pointer<git_annotated_commit>>();
    final revspecC = revspec.toChar(arena);
    final error = libgit2.git_annotated_commit_from_revspec(
      out,
      repoPointer,
      revspecC,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Creates an annotated commit from the given fetch head data.
///
/// The returned annotated commit must be freed with [free].
/// This is used to create an annotated commit from the information stored in
/// the fetch head.
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_annotated_commit> fromFetchHead({
  required Pointer<git_repository> repoPointer,
  required String branchName,
  required String remoteUrl,
  required Pointer<git_oid> oid,
}) {
  return using((arena) {
    final out = arena<Pointer<git_annotated_commit>>();
    final branchNameC = branchName.toChar(arena);
    final remoteUrlC = remoteUrl.toChar(arena);
    final error = libgit2.git_annotated_commit_from_fetchhead(
      out,
      repoPointer,
      branchNameC,
      remoteUrlC,
      oid,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Gets the commit ID that the given annotated commit refers to.
///
/// Returns a pointer to the OID of the commit.
Pointer<git_oid> oid(Pointer<git_annotated_commit> commit) =>
    libgit2.git_annotated_commit_id(commit);

/// Gets the reference name that the given annotated commit refers to.
///
/// Returns an empty string if no reference name is associated with the commit.
String refName(Pointer<git_annotated_commit> commit) {
  final result = libgit2.git_annotated_commit_ref(commit);
  return result == nullptr ? '' : result.toDartString();
}

/// Frees an annotated commit.
///
/// This should be called when the annotated commit is no longer needed.
void free(Pointer<git_annotated_commit> commit) {
  libgit2.git_annotated_commit_free(commit);
}
