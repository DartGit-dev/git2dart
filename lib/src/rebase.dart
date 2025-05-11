import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/rebase.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A class representing a Git rebase operation.
///
/// This class provides functionality to perform rebase operations on a Git repository,
/// including initializing a rebase, applying patches, resolving conflicts, and
/// finishing or aborting the rebase process.
class Rebase {
  /// Initializes a rebase operation to rebase the changes in [branch] relative
  /// to [upstream] onto [onto] another branch. To begin the rebase process,
  /// call [next].
  ///
  /// [repo] is the repository to perform the rebase in.
  ///
  /// [branch] is the terminal commit to rebase, default is to rebase the
  /// current branch.
  ///
  /// [upstream] is the commit to begin rebasing from, default is to rebase all
  /// reachable commits.
  ///
  /// [onto] is the branch to rebase onto, default is to rebase onto the given
  /// [upstream].
  ///
  /// Throws a [LibGit2Error] if error occurred.
  Rebase.init({
    required Repository repo,
    AnnotatedCommit? branch,
    AnnotatedCommit? upstream,
    AnnotatedCommit? onto,
  }) {
    _rebasePointer = bindings.init(
      repoPointer: repo.pointer,
      branchPointer: branch?.pointer,
      upstreamPointer: upstream?.pointer,
      ontoPointer: onto?.pointer,
    );
    _finalizer.attach(this, _rebasePointer, detach: this);
  }

  /// Opens an existing rebase that was previously started by either an
  /// invocation of [Rebase.init] or by another client.
  ///
  /// [repo] is the repository containing the rebase.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  Rebase.open(Repository repo) {
    _rebasePointer = bindings.open(repo.pointer);
    _finalizer.attach(this, _rebasePointer, detach: this);
  }

  /// Pointer to memory address for allocated rebase object.
  late final Pointer<git_rebase> _rebasePointer;

  /// List of operations that are to be applied during the rebase.
  ///
  /// Each operation represents a commit that will be applied during the rebase process.
  List<RebaseOperation> get operations {
    final operationsCount = bindings.operationsCount(_rebasePointer);
    return <RebaseOperation>[
      for (var i = 0; i < operationsCount; i++)
        RebaseOperation._(
          bindings.getOperationByIndex(rebase: _rebasePointer, index: i),
        ),
    ];
  }

  /// Index of the rebase operation that is currently being applied.
  ///
  /// If the first operation has not yet been applied (because you have called
  /// [Rebase.init] but not yet [next]) then this returns `-1`.
  int get currentOperation {
    return bindings.currentOperation(_rebasePointer);
  }

  /// Original HEAD OID for merge rebases.
  ///
  /// This represents the commit that was the HEAD before the rebase started.
  Oid get origHeadOid {
    return Oid.fromRaw(bindings.origHeadOid(_rebasePointer).ref);
  }

  /// Original HEAD ref name for merge rebases.
  ///
  /// Returns empty string if no information is available.
  String get origHeadName {
    return bindings.origHeadName(_rebasePointer);
  }

  /// Onto OID for merge rebases.
  ///
  /// This represents the commit that the rebase is being performed onto.
  Oid get ontoOid {
    return Oid.fromRaw(bindings.ontoOid(_rebasePointer).ref);
  }

  /// Onto ref name for merge rebases.
  ///
  /// This is the name of the reference that the rebase is being performed onto.
  String get ontoName {
    return bindings.ontoName(_rebasePointer);
  }

  /// Performs the next rebase operation and returns the information about it.
  ///
  /// If the operation is one that applies a patch (which is any operation
  /// except [GitRebaseOperation.exec]) then the patch will be applied and the
  /// index and working directory will be updated with the changes. If there
  /// are conflicts, you will need to address those before committing the
  /// changes.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  RebaseOperation next() {
    return RebaseOperation._(bindings.next(_rebasePointer));
  }

  /// Commits the current patch. You must have resolved any conflicts that were
  /// introduced during the patch application from the [next] invocation.
  ///
  /// [committer] is the committer of the rebase.
  ///
  /// [message] the message for this commit, can be null to use the message
  /// from the original commit.
  ///
  /// [author] is the author of the updated commit, can be null to keep the
  /// author from the original commit.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void commit({
    required Signature committer,
    String? message,
    Signature? author,
  }) {
    bindings.commit(
      rebasePointer: _rebasePointer,
      authorPointer: author?.pointer,
      committerPointer: committer.pointer,
      message: message,
    );
  }

  /// Finishes a rebase that is currently in progress once all patches have
  /// been applied.
  ///
  /// This will update the HEAD reference to point to the final commit of the
  /// rebase operation.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void finish() => bindings.finish(_rebasePointer);

  /// Aborts a rebase that is currently in progress, resetting the repository
  /// and working directory to their state before rebase began.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void abort() => bindings.abort(_rebasePointer);

  /// Releases memory allocated for rebase object.
  ///
  /// This should be called when you are done with the rebase object to prevent
  /// memory leaks.
  void free() {
    bindings.free(_rebasePointer);
    _finalizer.detach(this);
  }
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_rebase>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end

/// A class representing a single operation in a rebase process.
///
/// Each operation represents a commit that will be applied during the rebase.
class RebaseOperation {
  /// Initializes a new instance of the [RebaseOperation] class from
  /// provided pointer to rebase operation object in memory.
  const RebaseOperation._(this._rebaseOperationPointer);

  /// Pointer to memory address for allocated rebase operation object.
  final Pointer<git_rebase_operation> _rebaseOperationPointer;

  /// Type of rebase operation.
  ///
  /// This indicates what kind of operation will be performed (e.g., pick, reword,
  /// edit, squash, fixup, exec).
  GitRebaseOperation get type {
    return GitRebaseOperation.fromValue(_rebaseOperationPointer.ref.type.value);
  }

  /// [Oid] of commit being cherry-picked.
  ///
  /// This is the commit that will be applied during this operation.
  Oid get oid => Oid.fromRaw(_rebaseOperationPointer.ref.id);

  @override
  String toString() => 'RebaseOperation{type: $type, oid: $oid}';
}
