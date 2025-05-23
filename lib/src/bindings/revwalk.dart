import 'dart:ffi';

import 'package:ffi/ffi.dart' show using;
import 'package:git2dart/src/bindings/commit.dart' as commit_bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Creates a new revision walker to iterate through a repository.
///
/// The revision walker uses a custom memory pool and an internal commit cache,
/// making it relatively expensive to allocate. For maximum performance, it should
/// be reused for different walks.
///
/// The walker is not thread-safe and may only be used to walk a repository on a
/// single thread. However, multiple walkers can be used in different threads
/// walking the same repository.
///
/// The returned walker must be freed using [free].
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_revwalk> create(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_revwalk>>();
    final error = libgit2.git_revwalk_new(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Changes the sorting mode when iterating through the repository's contents.
///
/// Available sorting modes:
/// - [GIT_SORT_NONE]: No sorting
/// - [GIT_SORT_TOPOLOGICAL]: Sort by commit date
/// - [GIT_SORT_TIME]: Sort by commit date
/// - [GIT_SORT_REVERSE]: Reverse the sorting
///
/// Changing the sorting mode resets the walker.
void sorting({
  required Pointer<git_revwalk> walkerPointer,
  required int sortMode,
}) {
  libgit2.git_revwalk_sorting(walkerPointer, sortMode);
}

/// Adds a new root for the traversal.
///
/// The pushed commit will be marked as one of the roots from which to start
/// the walk. This commit may not be walked if it or a child is hidden.
///
/// At least one commit must be pushed onto the walker before a walk can be
/// started.
///
/// The given OID must belong to a committish on the walked repository.
///
/// Throws a [LibGit2Error] if an error occurs.
void push({
  required Pointer<git_revwalk> walkerPointer,
  required Pointer<git_oid> oidPointer,
}) {
  final error = libgit2.git_revwalk_push(walkerPointer, oidPointer);
  checkErrorAndThrow(error);
}

/// Pushes matching references to the revision walker.
///
/// The OIDs pointed to by the references that match the given glob pattern
/// will be pushed to the revision walker.
///
/// A leading 'refs/' is implied if not present, as well as a trailing '/\*'
/// if the glob lacks '?', '*' or '['.
///
/// Any references matching this glob which do not point to a committish will
/// be ignored.
void pushGlob({
  required Pointer<git_revwalk> walkerPointer,
  required String glob,
}) {
  using((arena) {
    final globC = glob.toChar(arena);
    libgit2.git_revwalk_push_glob(walkerPointer, globC);
  });
}

/// Pushes the repository's HEAD to the revision walker.
void pushHead(Pointer<git_revwalk> walker) =>
    libgit2.git_revwalk_push_head(walker);

/// Pushes the OID pointed to by a reference to the revision walker.
///
/// The reference must point to a committish.
///
/// Throws a [LibGit2Error] if an error occurs.
void pushRef({
  required Pointer<git_revwalk> walkerPointer,
  required String refName,
}) {
  using((arena) {
    final refNameC = refName.toChar(arena);
    final error = libgit2.git_revwalk_push_ref(walkerPointer, refNameC);
    checkErrorAndThrow(error);
  });
}

/// Pushes and hides the respective endpoints of the given range.
///
/// The range should be of the form `..` The left-hand commit will be hidden
/// and the right-hand commit pushed.
///
/// Throws a [LibGit2Error] if an error occurs.
void pushRange({
  required Pointer<git_revwalk> walkerPointer,
  required String range,
}) {
  using((arena) {
    final rangeC = range.toChar(arena);
    final error = libgit2.git_revwalk_push_range(walkerPointer, rangeC);
    checkErrorAndThrow(error);
  });
}

/// Gets the list of commits from the revision walk.
///
/// The returned commits must be freed.
///
/// The initial call to this method is not blocking when iterating through a
/// repo with a time-sorting mode.
///
/// Iterating with Topological or inverted modes makes the initial call
/// blocking to preprocess the commit list, but this block should be mostly
/// unnoticeable on most repositories (topological preprocessing times at 0.3s
/// on the git.git repo).
///
/// The revision walker is reset when the walk is over.
///
/// [limit] specifies the maximum number of commits to return. If 0, all commits
/// will be returned.
List<Pointer<git_commit>> walk({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_revwalk> walkerPointer,
  required int limit,
}) {
  final result = <Pointer<git_commit>>[];
  var error = 0;

  using((arena) {
    void next() {
      final oid = arena<git_oid>();
      error = libgit2.git_revwalk_next(oid, walkerPointer);
      if (error == 0) {
        final commit = commit_bindings.lookup(
          repoPointer: repoPointer,
          oidPointer: oid,
        );
        result.add(commit);
      }
    }

    if (limit == 0) {
      while (error == 0) {
        next();
      }
    } else {
      for (var i = 0; i < limit; i++) {
        next();
      }
    }
  });

  return result;
}

/// Marks a commit (and its ancestors) uninteresting for the output.
///
/// The given OID must belong to a committish on the walked repository.
///
/// The resolved commit and all its parents will be hidden from the output on
/// the revision walk.
///
/// Throws a [LibGit2Error] if an error occurs.
void hide({
  required Pointer<git_revwalk> walkerPointer,
  required Pointer<git_oid> oidPointer,
}) {
  final error = libgit2.git_revwalk_hide(walkerPointer, oidPointer);
  checkErrorAndThrow(error);
}

/// Hides matching references from the revision walk.
///
/// The OIDs pointed to by the references that match the given glob pattern and
/// their ancestors will be hidden from the output on the revision walk.
///
/// A leading 'refs/' is implied if not present, as well as a trailing '/\*' if
/// the glob lacks '?', '*' or '['.
///
/// Any references matching this glob which do not point to a committish will
/// be ignored.
void hideGlob({
  required Pointer<git_revwalk> walkerPointer,
  required String glob,
}) {
  using((arena) {
    final globC = glob.toChar(arena);
    libgit2.git_revwalk_hide_glob(walkerPointer, globC);
  });
}

/// Hides the repository's HEAD from the revision walk.
void hideHead(Pointer<git_revwalk> walker) =>
    libgit2.git_revwalk_hide_head(walker);

/// Hides the OID pointed to by a reference from the revision walk.
///
/// The reference must point to a committish.
///
/// Throws a [LibGit2Error] if an error occurs.
void hideRef({
  required Pointer<git_revwalk> walkerPointer,
  required String refName,
}) {
  using((arena) {
    final refNameC = refName.toChar(arena);
    final error = libgit2.git_revwalk_hide_ref(walkerPointer, refNameC);
    checkErrorAndThrow(error);
  });
}

/// Resets the revision walker for reuse.
///
/// This will clear all the pushed and hidden commits, and leave the walker in
/// a blank state (just like at creation) ready to receive new commit pushes
/// and start a new walk.
///
/// The revision walk is automatically reset when a walk is over.
void reset(Pointer<git_revwalk> walker) => libgit2.git_revwalk_reset(walker);

/// Simplifies the history by first-parent.
///
/// No parents other than the first for each commit will be enqueued.
void simplifyFirstParent(Pointer<git_revwalk> walker) {
  libgit2.git_revwalk_simplify_first_parent(walker);
}

/// Returns the repository on which this walker is operating.
Pointer<git_repository> repository(Pointer<git_revwalk> walker) {
  return libgit2.git_revwalk_repository(walker);
}

/// Frees a revision walker previously allocated.
void free(Pointer<git_revwalk> walk) => libgit2.git_revwalk_free(walk);
