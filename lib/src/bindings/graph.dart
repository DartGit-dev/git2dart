import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Determine if a commit is the descendant of another commit.
///
/// Note that a commit is not considered a descendant of itself, in contrast to
/// `git merge-base --is-ancestor`.
bool descendantOf({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> commitPointer,
  required Pointer<git_oid> ancestorPointer,
}) {
  final result = libgit2.git_graph_descendant_of(
    repoPointer,
    commitPointer,
    ancestorPointer,
  );

  return result == 1 || false;
}

/// Count the number of unique commits between two commit objects.
///
/// There is no need for branches containing the commits to have any upstream
/// relationship, but it helps to think of one as a branch and the other as its
/// upstream, the ahead and behind values will be what git would report for the
/// branches.
List<int> aheadBehind({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> localPointer,
  required Pointer<git_oid> upstreamPointer,
}) {
  return using((arena) {
    final ahead = arena<Size>();
    final behind = arena<Size>();

    final error = libgit2.git_graph_ahead_behind(
      ahead,
      behind,
      repoPointer,
      localPointer,
      upstreamPointer,
    );

    checkErrorAndThrow(error);

    return [ahead.value, behind.value];
  });
}
