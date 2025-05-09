import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/annotated.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing an annotated commit in Git.
///
/// An annotated commit contains information about how it was looked up,
/// which may be useful for functions like merge or rebase to provide context
/// to the operation. For example, conflict files will include the name of the
/// source or target branches being merged.
@immutable
class AnnotatedCommit extends Equatable {
  late final Pointer<git_annotated_commit> _annotatedCommitPointer;

  /// Creates an annotated commit by looking up the given commit [oid].
  ///
  /// It is preferable to use [AnnotatedCommit.fromReference] instead of this
  /// constructor, as it preserves more information about how the commit was
  /// looked up.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  AnnotatedCommit.lookup({required Repository repo, required Oid oid}) {
    _annotatedCommitPointer = bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: oid.pointer,
    );
    _finalizer.attach(this, _annotatedCommitPointer, detach: this);
  }

  /// Creates an annotated commit from the given [reference].
  ///
  /// This is the preferred method to create an annotated commit as it preserves
  /// the reference information.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  AnnotatedCommit.fromReference({
    required Repository repo,
    required Reference reference,
  }) {
    _annotatedCommitPointer = bindings.fromRef(
      repoPointer: repo.pointer,
      referencePointer: reference.pointer,
    );
    _finalizer.attach(this, _annotatedCommitPointer, detach: this);
  }

  /// Creates an annotated commit from a revision string.
  ///
  /// See `man gitrevisions`, or http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions
  /// for information on the syntax accepted.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  AnnotatedCommit.fromRevSpec({
    required Repository repo,
    required String spec,
  }) {
    _annotatedCommitPointer = bindings.fromRevSpec(
      repoPointer: repo.pointer,
      revspec: spec,
    );
    _finalizer.attach(this, _annotatedCommitPointer, detach: this);
  }

  /// Creates an annotated commit from the given fetch head data.
  ///
  /// [repo] is the repository that contains the given commit.
  /// [branchName] is the name of the (remote) branch.
  /// [remoteUrl] is the URL of the remote.
  /// [oid] is the commit object ID of the remote branch.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  AnnotatedCommit.fromFetchHead({
    required Repository repo,
    required String branchName,
    required String remoteUrl,
    required Oid oid,
  }) {
    _annotatedCommitPointer = bindings.fromFetchHead(
      repoPointer: repo.pointer,
      branchName: branchName,
      remoteUrl: remoteUrl,
      oid: oid.pointer,
    );
    _finalizer.attach(this, _annotatedCommitPointer, detach: this);
  }

  /// Pointer to the memory address for the allocated commit object.
  ///
  /// Note: For internal use only.
  @internal
  Pointer<git_annotated_commit> get pointer => _annotatedCommitPointer;

  /// The commit OID that this annotated commit refers to.
  Oid get oid => Oid.fromRaw(bindings.oid(_annotatedCommitPointer).ref);

  /// The reference name that this annotated commit refers to.
  ///
  /// Returns an empty string if no reference name is associated with the commit.
  String get refName => bindings.refName(_annotatedCommitPointer);

  /// Releases memory allocated for the commit object.
  ///
  /// This should be called when the annotated commit is no longer needed.
  void free() {
    bindings.free(_annotatedCommitPointer);
    _finalizer.detach(this);
  }

  @override
  List<Object?> get props => [oid];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_annotated_commit>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
