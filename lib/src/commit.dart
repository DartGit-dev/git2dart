import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/commit.dart' as bindings;
import 'package:git2dart/src/bindings/graph.dart' as graph_bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git commit object.
///
/// This class provides methods to interact with Git commits, including creating,
/// modifying, and retrieving commit information. It wraps the libgit2 commit
/// functionality in a more Dart-friendly way.
@immutable
class Commit extends Equatable {
  /// Initializes a new instance of [Commit] class from provided pointer to
  /// commit object in memory.
  ///
  /// This constructor is for internal use only. Use [Commit.lookup] instead
  /// to create commit instances.
  ///
  /// [commitPointer] is a pointer to the underlying libgit2 commit object.
  @internal
  Commit(this._commitPointer) {
    _finalizer.attach(this, _commitPointer, detach: this);
  }

  /// Creates a new commit instance by looking up a commit object in the repository.
  ///
  /// [repo] is the repository to search in.
  /// [oid] is the object ID of the commit to look up.
  ///
  /// Throws a [LibGit2Error] if the commit cannot be found or if an error occurs.
  Commit.lookup({required Repository repo, required Oid oid}) {
    _commitPointer = bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: oid.pointer,
    );
    _finalizer.attach(this, _commitPointer, detach: this);
  }

  late final Pointer<git_commit> _commitPointer;

  /// Gets the pointer to the underlying libgit2 commit object.
  ///
  /// This is for internal use only.
  @internal
  Pointer<git_commit> get pointer => _commitPointer;

  /// Creates a new commit in the repository.
  ///
  /// [repo] is the repository where to store the commit.
  /// [updateRef] is the name of the reference that will be updated to point to
  /// this commit. If the reference is not direct, it will be resolved to a
  /// direct reference. Use "HEAD" to update the HEAD of the current branch and
  /// make it point to this commit. If the reference doesn't exist yet, it will
  /// be created. If it does exist, the first parent must be the tip of this
  /// branch.
  /// [author] is the signature with author and author time of commit.
  /// [committer] is the signature with committer and commit time of commit.
  /// [messageEncoding] is the encoding for the message in the commit,
  /// represented with a standard encoding name (e.g. "UTF-8"). If null, no
  /// encoding header is written and UTF-8 is assumed.
  /// [message] is the full message for this commit. It will not be cleaned up
  /// automatically (i.e. excess whitespace will not be removed and no trailing
  /// newline will be added).
  /// [tree] is an instance of a [Tree] object that will be used as the tree
  /// for the commit. This tree object must also be owned by the given [repo].
  /// [parents] is a list of [Commit] objects that will be used as the parents
  /// for this commit. This array may be empty if parent count is 0
  /// (root commit). All the given commits must be owned by the [repo].
  ///
  /// Returns the [Oid] of the newly created commit.
  ///
  /// Throws a [LibGit2Error] if an error occurs during commit creation.
  static Oid create({
    required Repository repo,
    required String updateRef,
    required Signature author,
    required Signature committer,
    String? messageEncoding,
    required String message,
    required Tree tree,
    required List<Commit> parents,
  }) {
    return Oid(
      bindings.create(
        repoPointer: repo.pointer,
        updateRef: updateRef,
        authorPointer: author.pointer,
        committerPointer: committer.pointer,
        messageEncoding: messageEncoding,
        message: message,
        treePointer: tree.pointer,
        parentCount: parents.length,
        parents: parents.map((e) => e.pointer).toList(),
      ),
    );
  }

  /// Creates a commit and writes it into a buffer instead of the object database.
  ///
  /// This method works similarly to [create] but instead of writing the commit
  /// to the object database, it writes the contents into a buffer.
  ///
  /// All parameters have the same meaning as in [create].
  ///
  /// Returns the commit data as a string.
  ///
  /// Throws a [LibGit2Error] if an error occurs during buffer creation.
  static String createBuffer({
    required Repository repo,
    required Signature author,
    required Signature committer,
    String? messageEncoding,
    required String message,
    required Tree tree,
    required List<Commit> parents,
  }) {
    return bindings.createBuffer(
      repoPointer: repo.pointer,
      authorPointer: author.pointer,
      committerPointer: committer.pointer,
      messageEncoding: messageEncoding,
      message: message,
      treePointer: tree.pointer,
      parentCount: parents.length,
      parents: parents.map((e) => e.pointer).toList(),
    );
  }

  /// Amends an existing commit by replacing only non-null values.
  ///
  /// This creates a new commit that is exactly the same as the old commit,
  /// except that any non-null values will be updated. The new commit has the
  /// same parents as the old commit.
  ///
  /// [repo] is the repository where the commit exists.
  /// [commit] is the commit to amend.
  /// [updateRef] works as in [create], updating the ref to point to the newly
  /// rewritten commit. If you want to amend a commit that is not currently the
  /// tip of the branch and then rewrite the following commits to reach a ref,
  /// pass this as null and update the rest of the commit chain and ref separately.
  /// [author] is the new author signature (if null, keeps the original).
  /// [committer] is the new committer signature (if null, keeps the original).
  /// [tree] is the new tree (if null, keeps the original).
  /// [message] is the new commit message (if null, keeps the original).
  /// [messageEncoding] is the new message encoding (if null, keeps the original).
  ///
  /// Returns the [Oid] of the amended commit.
  ///
  /// Throws a [LibGit2Error] if an error occurs during amendment.
  static Oid amend({
    required Repository repo,
    required Commit commit,
    required String? updateRef,
    Signature? author,
    Signature? committer,
    Tree? tree,
    String? message,
    String? messageEncoding,
  }) {
    return Oid(
      bindings.amend(
        repoPointer: repo.pointer,
        commitPointer: commit.pointer,
        authorPointer: author?.pointer,
        committerPointer: committer?.pointer,
        treePointer: tree?.pointer,
        updateRef: updateRef,
        message: message,
        messageEncoding: messageEncoding,
      ),
    );
  }

  /// Reverts the commit, producing changes in the index and working directory.
  ///
  /// [mainline] is the parent of the commit if it is a merge (i.e. 1, 2, etc.).
  /// [mergeFavor] is one of the optional [GitMergeFileFavor] flags for
  /// handling conflicting content.
  /// [mergeFlags] is optional combination of [GitMergeFlag] flags.
  /// [mergeFileFlags] is optional combination of [GitMergeFileFlag] flags.
  /// [checkoutStrategy] is optional combination of [GitCheckout] flags.
  /// [checkoutDirectory] is optional alternative checkout path to workdir.
  /// [checkoutPaths] is optional list of files to checkout (by default all
  /// paths are processed).
  ///
  /// Throws a [LibGit2Error] if an error occurs during revert.
  void revert({
    int mainline = 0,
    GitMergeFileFavor? mergeFavor,
    Set<GitMergeFlag>? mergeFlags,
    Set<GitMergeFileFlag>? mergeFileFlags,
    Set<GitCheckout>? checkoutStrategy,
    String? checkoutDirectory,
    List<String>? checkoutPaths,
  }) {
    bindings.revert(
      repoPointer: bindings.owner(_commitPointer),
      commitPointer: _commitPointer,
      mainline: mainline,
      mergeFavor: mergeFavor?.value,
      mergeFlags: mergeFlags?.fold(0, (acc, e) => acc! | e.value),
      mergeFileFlags: mergeFileFlags?.fold(0, (acc, e) => acc! | e.value),
      checkoutStrategy: checkoutStrategy?.fold(0, (acc, e) => acc! | e.value),
      checkoutDirectory: checkoutDirectory,
      checkoutPaths: checkoutPaths,
    );
  }

  /// Reverts the commit against another commit, producing an index that
  /// reflects the result of the revert.
  ///
  /// [commit] is the commit to revert against.
  /// [mainline] is the parent of the commit if it is a merge (i.e. 1, 2, etc.).
  /// [mergeFavor] is one of the optional [GitMergeFileFavor] flags for
  /// handling conflicting content.
  /// [mergeFlags] is optional combination of [GitMergeFlag] flags.
  /// [mergeFileFlags] is optional combination of [GitMergeFileFlag] flags.
  ///
  /// Returns an [Index] object representing the result of the revert.
  ///
  /// Throws a [LibGit2Error] if an error occurs during revert.
  Index revertTo({
    required Commit commit,
    int mainline = 0,
    GitMergeFileFavor? mergeFavor,
    Set<GitMergeFlag>? mergeFlags,
    Set<GitMergeFileFlag>? mergeFileFlags,
  }) {
    return Index(
      bindings.revertCommit(
        repoPointer: bindings.owner(_commitPointer),
        revertCommitPointer: _commitPointer,
        ourCommitPointer: commit.pointer,
        mainline: mainline,
        mergeFavor: mergeFavor?.value,
        mergeFlags: mergeFlags?.fold(0, (acc, e) => acc! | e.value),
        mergeFileFlags: mergeFileFlags?.fold(0, (acc, e) => acc! | e.value),
      ),
    );
  }

  /// Gets the encoding for the commit message.
  ///
  /// Returns a string representing a standard encoding name (e.g. "UTF-8").
  /// If the encoding header in the commit is missing, UTF-8 is assumed.
  String get messageEncoding => bindings.messageEncoding(_commitPointer);

  /// Gets the full commit message.
  ///
  /// The returned message will be slightly prettified by removing any potential
  /// leading newlines.
  String get message => bindings.message(_commitPointer);

  /// Gets the short "summary" of the commit message.
  ///
  /// The returned message is the summary of the commit, comprising the first
  /// paragraph of the message with whitespace trimmed and squashed.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  String get summary => bindings.summary(_commitPointer);

  /// Gets the long "body" of the commit message.
  ///
  /// The returned message is the body of the commit, comprising everything but
  /// the first paragraph of the message. Leading and trailing whitespaces are
  /// trimmed.
  ///
  /// Returns an empty string if the message only consists of a summary.
  String get body => bindings.body(_commitPointer);

  /// Gets the [Oid] of the commit.
  Oid get oid => Oid(bindings.id(_commitPointer));

  /// Gets the commit time (i.e. committer time).
  int get time => bindings.time(_commitPointer);

  /// Gets the commit timezone offset in minutes.
  ///
  /// This represents the committer's preferred timezone.
  int get timeOffset => bindings.timeOffset(_commitPointer);

  /// Gets the committer of the commit.
  Signature get committer => Signature(bindings.committer(_commitPointer));

  /// Gets the author of the commit.
  Signature get author => Signature(bindings.author(_commitPointer));

  /// Gets the list of parent commit [Oid]s.
  List<Oid> get parents {
    final parentCount = bindings.parentCount(_commitPointer);
    return <Oid>[
      for (var i = 0; i < parentCount; i++)
        Oid(bindings.parentId(commitPointer: _commitPointer, position: i)),
    ];
  }

  /// Gets the specified parent commit.
  ///
  /// [position] is the 0-based index of the parent to retrieve.
  ///
  /// Returns a [Commit] object representing the parent.
  ///
  /// Throws a [LibGit2Error] if an error occurs or if the parent doesn't exist.
  Commit parent(int position) {
    return Commit(
      bindings.parent(commitPointer: _commitPointer, position: position),
    );
  }

  /// Gets the tree pointed to by the commit.
  Tree get tree => Tree(bindings.tree(_commitPointer));

  /// Gets the [Oid] of the tree pointed to by the commit.
  Oid get treeOid => Oid(bindings.treeOid(_commitPointer));

  /// Gets an arbitrary header field from the commit.
  ///
  /// [field] is the name of the header field to retrieve.
  ///
  /// Returns the value of the header field.
  ///
  /// Throws a [LibGit2Error] if an error occurs or if the field doesn't exist.
  String headerField(String field) {
    return bindings.headerField(commitPointer: _commitPointer, field: field);
  }

  /// Gets the nth generation ancestor of the commit.
  ///
  /// This follows only the first parents. Passing 0 as the generation number
  /// returns another instance of the base commit itself.
  ///
  /// [n] is the generation number of the ancestor to retrieve.
  ///
  /// Returns a [Commit] object representing the ancestor.
  ///
  /// Throws a [LibGit2Error] if an error occurs or if the ancestor doesn't exist.
  Commit nthGenAncestor(int n) {
    return Commit(bindings.nthGenAncestor(commitPointer: _commitPointer, n: n));
  }

  /// Checks if this commit is a descendant of another commit.
  ///
  /// [ancestor] is the potential ancestor commit to check against.
  ///
  /// Returns true if this commit is a descendant of the ancestor commit.
  ///
  /// Note that a commit is not considered a descendant of itself, in contrast
  /// to `git merge-base --is-ancestor`.
  bool descendantOf(Oid ancestor) {
    return graph_bindings.descendantOf(
      repoPointer: bindings.owner(_commitPointer),
      commitPointer: bindings.id(_commitPointer),
      ancestorPointer: ancestor.pointer,
    );
  }

  /// Creates an in-memory copy of the commit.
  ///
  /// Returns a new [Commit] instance that is a copy of this commit.
  Commit duplicate() => Commit(bindings.duplicate(_commitPointer));

  /// Releases memory allocated for the commit object.
  ///
  /// This should be called when the commit object is no longer needed.
  void free() {
    bindings.free(_commitPointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'Commit{oid: $oid, message: $message, '
        'messageEncoding: $messageEncoding, time: $time, committer: $committer,'
        ' author: $author}';
  }

  @override
  List<Object?> get props => [oid];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_commit>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
