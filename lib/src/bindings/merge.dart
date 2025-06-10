import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Find a merge base between two commits.
///
/// Given two commits, find their merge base. This is the best common ancestor
/// of the two commits that can be used as a reference point for merging.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_oid> mergeBase({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> aPointer,
  required Pointer<git_oid> bPointer,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final error = libgit2.git_merge_base(out, repoPointer, aPointer, bPointer);

    checkErrorAndThrow(error);

    return out;
  });
}

/// Find a merge base given a list of commits.
///
/// Given a list of commits, find their merge base. This is the best common
/// ancestor of all the commits that can be used as a reference point for
/// merging.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_oidarray> mergeBasesMany({
  required Pointer<git_repository> repoPointer,
  required List<Pointer<git_oid>> commits,
}) {
  return using((arena) {
    final out = calloc<git_oidarray>();
    final commitsC = arena<git_oid>(commits.length);
    for (var i = 0; i < commits.length; i++) {
      commitsC[i] = commits[i].ref;
    }

    final error = libgit2.git_merge_bases_many(
      out,
      repoPointer,
      commits.length,
      commitsC,
    );

    checkErrorAndThrow(error);

    return out;
  });
}

/// Find a merge base in preparation for an octopus merge.
///
/// Given a list of commits, find their merge base in preparation for an
/// octopus merge. This is the best common ancestor of all the commits that
/// can be used as a reference point for merging.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_oid> mergeBaseOctopus({
  required Pointer<git_repository> repoPointer,
  required List<Pointer<git_oid>> commits,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final commitsC = arena<git_oid>(commits.length);
    for (var i = 0; i < commits.length; i++) {
      commitsC[i] = commits[i].ref;
    }

    final error = libgit2.git_merge_base_octopus(
      out,
      repoPointer,
      commits.length,
      commitsC,
    );

    checkErrorAndThrow(error);

    return out;
  });
}

/// Analyzes the given branch(es) and determines the opportunities for merging
/// them into a reference.
///
/// Analyzes the given branch(es) and determines the opportunities for merging
/// them into a reference. The analysis is returned in the form of a combination
/// of [GitMergeAnalysis] flags.
///
/// Throws a [LibGit2Error] if error occurred.
List<int> analysis({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_reference> ourRefPointer,
  required Pointer<git_annotated_commit> theirHeadPointer,
  required int theirHeadsLen,
}) {
  return using((arena) {
    final analysisOut = arena<UnsignedInt>();
    final preferenceOut = arena<UnsignedInt>();
    final theirHead = arena<Pointer<git_annotated_commit>>();
    theirHead[0] = theirHeadPointer;

    final error = libgit2.git_merge_analysis_for_ref(
      analysisOut,
      preferenceOut,
      repoPointer,
      ourRefPointer,
      theirHead,
      theirHeadsLen,
    );

    checkErrorAndThrow(error);

    return [analysisOut.value, preferenceOut.value];
  });
}

/// Merges the given commit into HEAD, writing the results into the working
/// directory.
///
/// Any changes are staged for commit and any conflicts are written to the index.
/// Callers should inspect the repository's index after this completes, resolve
/// any conflicts and prepare a commit.
///
/// For compatibility with git, the repository is put into a merging state.
/// Once the commit is done (or if the user wishes to abort), that state should
/// be cleared by calling relative method.
///
/// Throws a [LibGit2Error] if error occurred.
void merge({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_annotated_commit> theirHeadPointer,
  required int theirHeadsLen,
  required int favor,
  required int mergeFlags,
  required int fileFlags,
}) {
  return using((arena) {
    final theirHead = arena<Pointer<git_annotated_commit>>();
    theirHead[0] = theirHeadPointer;

    final mergeOpts = _initMergeOptions(
      arena: arena,
      favor: favor,
      mergeFlags: mergeFlags,
      fileFlags: fileFlags,
    );

    final checkoutOpts = arena<git_checkout_options>();
    libgit2.git_checkout_options_init(
      checkoutOpts,
      GIT_CHECKOUT_OPTIONS_VERSION,
    );

    checkoutOpts.ref.checkout_strategy =
        git_checkout_strategy_t.GIT_CHECKOUT_SAFE.value |
        git_checkout_strategy_t.GIT_CHECKOUT_RECREATE_MISSING.value;

    final error = libgit2.git_merge(
      repoPointer,
      theirHead,
      theirHeadsLen,
      mergeOpts,
      checkoutOpts,
    );
    checkErrorAndThrow(error);
  });
}

/// Merge two files as they exist in the in-memory data structures.
///
/// Using the given common ancestor as the baseline, produces a string that
/// reflects the merge result.
///
/// Note that this function does not reference a repository and any
/// configuration must be passed.
///
/// Throws a [LibGit2Error] if error occurred.
String mergeFile({
  required String ancestor,
  required String ancestorLabel,
  required String ours,
  required String oursLabel,
  required String theirs,
  required String theirsLabel,
  required int favor,
  required int flags,
}) {
  return using((arena) {
    final out = arena<git_merge_file_result>();
    final ancestorC = arena<git_merge_file_input>();
    final oursC = arena<git_merge_file_input>();
    final theirsC = arena<git_merge_file_input>();
    libgit2.git_merge_file_input_init(ancestorC, GIT_MERGE_FILE_INPUT_VERSION);
    libgit2.git_merge_file_input_init(oursC, GIT_MERGE_FILE_INPUT_VERSION);
    libgit2.git_merge_file_input_init(theirsC, GIT_MERGE_FILE_INPUT_VERSION);
    ancestorC.ref.ptr = ancestor.toChar(arena);
    ancestorC.ref.size = ancestor.length;
    Pointer<Char> ancestorLabelC = nullptr;
    oursC.ref.ptr = ours.toChar(arena);
    oursC.ref.size = ours.length;
    Pointer<Char> oursLabelC = nullptr;
    theirsC.ref.ptr = theirs.toChar(arena);
    theirsC.ref.size = theirs.length;
    Pointer<Char> theirsLabelC = nullptr;

    final opts = arena<git_merge_file_options>();
    libgit2.git_merge_file_options_init(opts, GIT_MERGE_FILE_OPTIONS_VERSION);
    opts.ref.favorAsInt = favor;
    opts.ref.flags = flags;
    if (ancestorLabel.isNotEmpty) {
      ancestorLabelC = ancestorLabel.toChar(arena);
      opts.ref.ancestor_label = ancestorLabelC;
    }
    if (oursLabel.isNotEmpty) {
      oursLabelC = oursLabel.toChar(arena);
      opts.ref.our_label = oursLabelC;
    }
    if (theirsLabel.isNotEmpty) {
      theirsLabelC = theirsLabel.toChar(arena);
      opts.ref.their_label = theirsLabelC;
    }

    final error = libgit2.git_merge_file(out, ancestorC, oursC, theirsC, opts);
    checkErrorAndThrow(error);

    return out.ref.ptr.toDartString(length: out.ref.len);
  });
}

/// Merge two files as they exist in the index.
///
/// Using the given common ancestor as the baseline, produces a string that
/// reflects the merge result containing possible conflicts.
///
/// Throws a [LibGit2Error] if error occurred.
String mergeFileFromIndex({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_index_entry>? ancestorPointer,
  required String ancestorLabel,
  required Pointer<git_index_entry> oursPointer,
  required String oursLabel,
  required Pointer<git_index_entry> theirsPointer,
  required String theirsLabel,
  required int favor,
  required int flags,
}) {
  return using((arena) {
    final out = arena<git_merge_file_result>();
    final opts = arena<git_merge_file_options>();
    Pointer<Char> ancestorLabelC = nullptr;
    Pointer<Char> oursLabelC = nullptr;
    Pointer<Char> theirsLabelC = nullptr;

    libgit2.git_merge_file_options_init(opts, GIT_MERGE_FILE_OPTIONS_VERSION);
    opts.ref.favorAsInt = favor;
    opts.ref.flags = flags;
    if (ancestorLabel.isNotEmpty) {
      ancestorLabelC = ancestorLabel.toChar(arena);
      opts.ref.ancestor_label = ancestorLabelC;
    }
    if (oursLabel.isNotEmpty) {
      oursLabelC = oursLabel.toChar(arena);
      opts.ref.our_label = oursLabelC;
    }
    if (theirsLabel.isNotEmpty) {
      theirsLabelC = theirsLabel.toChar(arena);
      opts.ref.their_label = theirsLabelC;
    }

    final error = libgit2.git_merge_file_from_index(
      out,
      repoPointer,
      ancestorPointer ?? nullptr,
      oursPointer,
      theirsPointer,
      opts,
    );
    checkErrorAndThrow(error);

    late final String result;
    if (out.ref.ptr != nullptr) {
      result = out.ref.ptr.toDartString(length: out.ref.len);
    }
    return result;
  });
}

/// Merge two commits, producing a git index that reflects the result of the
/// merge.
///
/// The index may be written as-is to the working directory or checked out.
/// If the index is to be converted to a tree, the caller should resolve any
/// conflicts that arose as part of the merge.
///
/// The returned index must be freed.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_index> mergeCommits({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> ourCommitPointer,
  required Pointer<git_commit> theirCommitPointer,
  required int favor,
  required int mergeFlags,
  required int fileFlags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final opts = _initMergeOptions(
      arena: arena,
      favor: favor,
      mergeFlags: mergeFlags,
      fileFlags: fileFlags,
    );

    final error = libgit2.git_merge_commits(
      out,
      repoPointer,
      ourCommitPointer,
      theirCommitPointer,
      opts,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Merge two trees, producing an index that reflects the result of the merge.
///
/// The index may be written as-is to the working directory or checked out.
/// If the index is to be converted to a tree, the caller should resolve any
/// conflicts that arose as part of the merge.
///
/// The returned index must be freed.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_index> mergeTrees({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree> ancestorTreePointer,
  required Pointer<git_tree> ourTreePointer,
  required Pointer<git_tree> theirTreePointer,
  required int favor,
  required int mergeFlags,
  required int fileFlags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final opts = _initMergeOptions(
      arena: arena,
      favor: favor,
      mergeFlags: mergeFlags,
      fileFlags: fileFlags,
    );

    final error = libgit2.git_merge_trees(
      out,
      repoPointer,
      ancestorTreePointer,
      ourTreePointer,
      theirTreePointer,
      opts,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Cherry-pick the given commit, producing changes in the index and working
/// directory.
///
/// Throws a [LibGit2Error] if error occurred.
void cherryPick({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> commitPointer,
}) {
  return using((arena) {
    final opts = arena<git_cherrypick_options>();
    libgit2.git_cherrypick_options_init(opts, GIT_CHERRYPICK_OPTIONS_VERSION);

    opts.ref.checkout_opts.checkout_strategy =
        git_checkout_strategy_t.GIT_CHECKOUT_SAFE.value;

    final error = libgit2.git_cherrypick(repoPointer, commitPointer, opts);

    checkErrorAndThrow(error);
  });
}

/// Cherry-pick the given commit against another commit and produce an index.
///
/// The returned index must be freed.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_index> cherryPickCommit({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> cherrypickCommitPointer,
  required Pointer<git_commit> ourCommitPointer,
  required int mainline,
  Pointer<git_merge_options>? mergeOptionsPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final error = libgit2.git_cherrypick_commit(
      out,
      repoPointer,
      cherrypickCommitPointer,
      ourCommitPointer,
      mainline,
      mergeOptionsPointer ?? nullptr,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

Pointer<git_merge_options> _initMergeOptions({
  required Arena arena,
  required int favor,
  required int mergeFlags,
  required int fileFlags,
}) {
  final opts = calloc<git_merge_options>();
  libgit2.git_merge_options_init(opts, GIT_MERGE_OPTIONS_VERSION);

  opts.ref.file_favorAsInt = favor;
  opts.ref.flags = mergeFlags;
  opts.ref.file_flags = fileFlags;

  return opts;
}
