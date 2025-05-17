import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/merge.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A class that provides functionality for merging Git objects.
///
/// This class contains static methods for performing various merge operations
/// such as finding merge bases, analyzing merge possibilities, and performing
/// merges between different Git objects (commits, trees, files).
class Merge {
  const Merge._(); // coverage:ignore-line

  /// Finds a merge base between two or more commits.
  ///
  /// A merge base is a common ancestor of two or more commits that can be used
  /// as a reference point for merging.
  ///
  /// [repo] is the repository containing the commits.
  /// [commits] is a list of commit OIDs to find the merge base for.
  ///
  /// Returns the OID of the merge base commit.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static Oid base(Repository repo, Oid commitA, Oid commitB) {
    return Oid(
      bindings.mergeBase(
        repoPointer: repo.pointer,
        aPointer: commitA.pointer,
        bPointer: commitB.pointer,
      ),
    );
  }

  /// Finds a merge base between two or more commits.
  ///
  /// A merge base is a common ancestor of two or more commits that can be used
  /// as a reference point for merging.
  ///
  /// [repo] is the repository containing the commits.
  /// [commits] is a list of commit OIDs to find the merge base for.
  ///
  /// Returns the OID of the merge base commit.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static List<Oid> baseMany(Repository repo, List<Oid> commits) {
    final oidArray = bindings.mergeBasesMany(
      repoPointer: repo.pointer,
      commits: commits.map((e) => e.pointer).toList(),
    );

    final result = List.generate(
      oidArray.ref.count,
      (i) => Oid(oidArray.ref.ids + i),
    );

    return result;
  }

  /// Finds a merge base in preparation for an octopus merge.
  ///
  /// An octopus merge is a merge of more than two branches. This method finds
  /// a common ancestor that can be used as a reference point for such a merge.
  ///
  /// [repo] is the repository containing the commits.
  /// [commits] is a list of commit OIDs to find the merge base for.
  ///
  /// Returns the OID of the merge base commit.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static Oid octopusBase({
    required Repository repo,
    required List<Oid> commits,
  }) {
    return Oid(
      bindings.mergeBaseOctopus(
        repoPointer: repo.pointer,
        commits: commits.map((e) => e.pointer).toList(),
      ),
    );
  }

  /// Analyzes the given branch's [theirHead] oid and determines the
  /// opportunities for merging them into [ourRef] reference.
  ///
  /// This method performs a detailed analysis of the merge possibilities between
  /// the current branch and the target branch.
  ///
  /// [repo] is the repository to analyze.
  /// [theirHead] is the OID of the commit to merge into our branch.
  /// [ourRef] is the reference to merge into (defaults to 'HEAD').
  ///
  /// Returns a [MergeAnalysis] object containing the analysis result and
  /// merge preference.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static MergeAnalysis analysis({
    required Repository repo,
    required Oid theirHead,
    String ourRef = 'HEAD',
  }) {
    final ref = Reference.lookup(repo: repo, name: ourRef);
    final head = AnnotatedCommit.lookup(repo: repo, oid: theirHead);
    final analysisInt = bindings.analysis(
      repoPointer: repo.pointer,
      ourRefPointer: ref.pointer,
      theirHeadPointer: head.pointer,
      theirHeadsLen: 1,
    );

    final result =
        GitMergeAnalysis.values
            .where((e) => analysisInt[0] & e.value == e.value)
            .toSet();
    final preference = GitMergePreference.fromValue(analysisInt[1]);

    return MergeAnalysis._(result: result, mergePreference: preference);
  }

  /// Merges the given [commit] into HEAD, writing the results into the
  /// working directory.
  ///
  /// This method performs a merge operation and updates the working directory
  /// with the results. Any changes are staged for commit and any conflicts
  /// are written to the index.
  ///
  /// For compatibility with git, the repository is put into a merging state.
  /// Once the commit is done (or if the user wishes to abort), that state
  /// should be cleared by calling [stateCleanup] method of [Repository] object.
  ///
  /// [repo] is the repository to merge.
  /// [commit] is the commit to merge.
  /// [favor] is one of the [GitMergeFileFavor] flags for handling conflicting
  /// content. Defaults to [GitMergeFileFavor.normal].
  /// [mergeFlags] is a combination of [GitMergeFlag] flags. Defaults to
  /// [GitMergeFlag.findRenames].
  /// [fileFlags] is a combination of [GitMergeFileFlag] flags. Defaults to
  /// [GitMergeFileFlag.defaults].
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static void commit({
    required Repository repo,
    required AnnotatedCommit commit,
    GitMergeFileFavor favor = GitMergeFileFavor.normal,
    Set<GitMergeFlag> mergeFlags = const {GitMergeFlag.findRenames},
    Set<GitMergeFileFlag> fileFlags = const {GitMergeFileFlag.defaults},
  }) {
    bindings.merge(
      repoPointer: repo.pointer,
      theirHeadPointer: commit.pointer,
      theirHeadsLen: 1,
      favor: favor.value,
      mergeFlags: mergeFlags.fold(0, (acc, e) => acc | e.value),
      fileFlags: fileFlags.fold(0, (acc, e) => acc | e.value),
    );
  }

  /// Merges two commits, producing an index that reflects the result of the
  /// merge.
  ///
  /// This method performs a merge between two commits and returns an index
  /// containing the result. The index may be written as-is to the working
  /// directory or checked out.
  ///
  /// [repo] is the repository that contains the given commits.
  /// [ourCommit] is the commit that reflects the destination tree.
  /// [theirCommit] is the commit to merge into [ourCommit].
  /// [favor] is one of the [GitMergeFileFavor] flags for handling conflicting
  /// content. Defaults to [GitMergeFileFavor.normal].
  /// [mergeFlags] is a combination of [GitMergeFlag] flags. Defaults to
  /// [GitMergeFlag.findRenames].
  /// [fileFlags] is a combination of [GitMergeFileFlag] flags. Defaults to
  /// [GitMergeFileFlag.defaults].
  ///
  /// Returns an [Index] object containing the merge result.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static Index commits({
    required Repository repo,
    required Commit ourCommit,
    required Commit theirCommit,
    GitMergeFileFavor favor = GitMergeFileFavor.normal,
    Set<GitMergeFlag> mergeFlags = const {GitMergeFlag.findRenames},
    Set<GitMergeFileFlag> fileFlags = const {GitMergeFileFlag.defaults},
  }) {
    return Index(
      bindings.mergeCommits(
        repoPointer: repo.pointer,
        ourCommitPointer: ourCommit.pointer,
        theirCommitPointer: theirCommit.pointer,
        favor: favor.value,
        mergeFlags: mergeFlags.fold(0, (acc, e) => acc | e.value),
        fileFlags: fileFlags.fold(0, (acc, e) => acc | e.value),
      ),
    );
  }

  /// Merges two trees, producing an index that reflects the result of the
  /// merge.
  ///
  /// This method performs a merge between two trees and returns an index
  /// containing the result. The index may be written as-is to the working
  /// directory or checked out.
  ///
  /// [repo] is the repository that contains the given trees.
  /// [ancestorTree] is the common ancestor between the trees, or null if none.
  /// [ourTree] is the tree that reflects the destination tree.
  /// [theirTree] is the tree to merge into [ourTree].
  /// [favor] is one of the [GitMergeFileFavor] flags for handling conflicting
  /// content. Defaults to [GitMergeFileFavor.normal].
  /// [mergeFlags] is a combination of [GitMergeFlag] flags. Defaults to
  /// [GitMergeFlag.findRenames].
  /// [fileFlags] is a combination of [GitMergeFileFlag] flags. Defaults to
  /// [GitMergeFileFlag.defaults].
  ///
  /// Returns an [Index] object containing the merge result.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static Index trees({
    required Repository repo,
    Tree? ancestorTree,
    required Tree ourTree,
    required Tree theirTree,
    GitMergeFileFavor favor = GitMergeFileFavor.normal,
    Set<GitMergeFlag> mergeFlags = const {GitMergeFlag.findRenames},
    Set<GitMergeFileFlag> fileFlags = const {GitMergeFileFlag.defaults},
  }) {
    return Index(
      bindings.mergeTrees(
        repoPointer: repo.pointer,
        ancestorTreePointer: ancestorTree?.pointer ?? nullptr,
        ourTreePointer: ourTree.pointer,
        theirTreePointer: theirTree.pointer,
        favor: favor.value,
        mergeFlags: mergeFlags.fold(0, (acc, e) => acc | e.value),
        fileFlags: fileFlags.fold(0, (acc, e) => acc | e.value),
      ),
    );
  }

  /// Merges two files as they exist in the in-memory data structures.
  ///
  /// This method merges two files using the given common ancestor as the
  /// baseline, producing a string that reflects the merge result.
  ///
  /// Note that this function does not reference a repository and configuration
  /// must be passed as [favor] and [flags].
  ///
  /// [ancestor] is the contents of the ancestor file.
  /// [ancestorLabel] is optional label for the ancestor file side of the
  /// conflict. Defaults to empty string.
  /// [ours] is the contents of the file in "our" side.
  /// [oursLabel] is optional label for our file side of the conflict.
  /// Defaults to empty string.
  /// [theirs] is the contents of the file in "their" side.
  /// [theirsLabel] is optional label for their file side of the conflict.
  /// Defaults to empty string.
  /// [favor] is one of the [GitMergeFileFavor] flags for handling conflicting
  /// content. Defaults to [GitMergeFileFavor.normal].
  /// [flags] is a combination of [GitMergeFileFlag] flags. Defaults to
  /// [GitMergeFileFlag.defaults].
  ///
  /// Returns a string containing the merged file contents.
  static String file({
    required String ancestor,
    String ancestorLabel = '',
    required String ours,
    String oursLabel = '',
    required String theirs,
    String theirsLabel = '',
    GitMergeFileFavor favor = GitMergeFileFavor.normal,
    Set<GitMergeFileFlag> flags = const {GitMergeFileFlag.defaults},
  }) {
    libgit2.git_libgit2_init();

    return bindings.mergeFile(
      ancestor: ancestor,
      ancestorLabel: ancestorLabel,
      ours: ours,
      oursLabel: oursLabel,
      theirs: theirs,
      theirsLabel: theirsLabel,
      favor: favor.value,
      flags: flags.fold(0, (acc, e) => acc | e.value),
    );
  }

  /// Merges two files as they exist in the index.
  ///
  /// This method merges two files from the index using the given common
  /// ancestor as the baseline, producing a string that reflects the merge
  /// result containing possible conflicts.
  ///
  /// [repo] is the repository containing the files.
  /// [ancestor] is the index entry for the ancestor file, or null if none.
  /// [ancestorLabel] is optional label for the ancestor file side of the
  /// conflict. Defaults to empty string.
  /// [ours] is the index entry for our file.
  /// [oursLabel] is optional label for our file side of the conflict.
  /// Defaults to empty string.
  /// [theirs] is the index entry for their file.
  /// [theirsLabel] is optional label for their file side of the conflict.
  /// Defaults to empty string.
  /// [favor] is one of the [GitMergeFileFavor] flags for handling conflicting
  /// content. Defaults to [GitMergeFileFavor.normal].
  /// [flags] is a combination of [GitMergeFileFlag] flags. Defaults to
  /// [GitMergeFileFlag.defaults].
  ///
  /// Returns a string containing the merged file contents.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static String fileFromIndex({
    required Repository repo,
    required IndexEntry? ancestor,
    String ancestorLabel = '',
    required IndexEntry ours,
    String oursLabel = '',
    required IndexEntry theirs,
    String theirsLabel = '',
    GitMergeFileFavor favor = GitMergeFileFavor.normal,
    Set<GitMergeFileFlag> flags = const {GitMergeFileFlag.defaults},
  }) {
    return bindings.mergeFileFromIndex(
      repoPointer: repo.pointer,
      ancestorPointer: ancestor?.pointer,
      ancestorLabel: ancestorLabel,
      oursPointer: ours.pointer,
      oursLabel: oursLabel,
      theirsPointer: theirs.pointer,
      theirsLabel: theirsLabel,
      favor: favor.value,
      flags: flags.fold(0, (acc, e) => acc | e.value),
    );
  }

  /// Cherry-picks the provided [commit], producing changes in the index and
  /// working directory.
  ///
  /// This method applies the changes from the given commit to the current
  /// branch. Any changes are staged for commit and any conflicts are written
  /// to the index.
  ///
  /// [repo] is the repository to cherry-pick in.
  /// [commit] is the commit to cherry-pick.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static void cherryPick({required Repository repo, required Commit commit}) {
    bindings.cherryPick(
      repoPointer: repo.pointer,
      commitPointer: commit.pointer,
    );
  }
}

/// A class that represents the result of a merge analysis.
class MergeAnalysis {
  const MergeAnalysis._({required this.result, required this.mergePreference});

  /// The set of merge opportunities identified during analysis.
  final Set<GitMergeAnalysis> result;

  /// The user's stated preference for how the merge should be performed.
  final GitMergePreference mergePreference;
}
