import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/revwalk.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A revision walker for traversing the commit history of a repository.
///
/// The revision walker provides a way to traverse the commit history of a repository
/// in various orders and with different filtering options. It's useful for operations
/// like viewing commit history, finding merge bases, or analyzing repository structure.
///
/// Example usage:
/// ```dart
/// final repo = Repository.open('path/to/repo');
/// final walker = RevWalk(repo);
///
/// // Configure walker
/// walker.sorting({GitSort.time, GitSort.reverse});
/// walker.pushHead();
///
/// // Get commits
/// final commits = walker.walk(limit: 10);
/// ```
class RevWalk {
  /// Initializes a new instance of the [RevWalk] class.
  ///
  /// Creates a new revision walker for the given repository. The walker uses a custom
  /// memory pool and internal commit cache, making it relatively expensive to allocate.
  /// For maximum performance, it should be reused for different walks.
  ///
  /// The walker is not thread-safe and may only be used to walk a repository on a
  /// single thread. However, multiple walkers can be used in different threads
  /// walking the same repository.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  RevWalk(Repository repo) {
    _revWalkPointer = bindings.create(repo.pointer);
    _finalizer.attach(this, _revWalkPointer, detach: this);
  }

  late final Pointer<git_revwalk> _revWalkPointer;

  /// Pointer to memory address for allocated [RevWalk] object.
  ///
  /// Note: For internal use only.
  @internal
  Pointer<git_revwalk> get pointer => _revWalkPointer;

  /// Returns the list of commits from the revision walk.
  ///
  /// The commits are returned in the order specified by the current sorting mode.
  /// By default, commits are returned in reverse chronological order (newest first).
  ///
  /// [limit] is optional number of commits to walk (by default walks through
  /// all of the commits pushed onto the walker).
  ///
  /// The walker is automatically reset after the walk is complete.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  List<Commit> walk({int limit = 0}) {
    final pointers = bindings.walk(
      repoPointer: bindings.repository(_revWalkPointer),
      walkerPointer: _revWalkPointer,
      limit: limit,
    );

    return pointers.map((e) => Commit(e)).toList();
  }

  /// Changes the sorting mode when iterating through the repository's contents
  /// to provided [sorting] combination of [GitSort] modes.
  ///
  /// Available sorting modes:
  /// - [GitSort.none]: No sorting
  /// - [GitSort.topological]: Sort by commit date
  /// - [GitSort.time]: Sort by commit date
  /// - [GitSort.reverse]: Reverse the sorting
  ///
  /// Changing the sorting mode resets the walker.
  void sorting(Set<GitSort> sorting) {
    bindings.sorting(
      walkerPointer: _revWalkPointer,
      sortMode: sorting.fold(0, (acc, e) => acc | e.value),
    );
  }

  /// Adds a new root commit [oid] for the traversal.
  ///
  /// The pushed commit will be marked as one of the roots from which to start
  /// the walk. This commit may not be walked if it or a child is hidden.
  ///
  /// At least one commit must be pushed onto the walker before a walk can be
  /// started.
  ///
  /// The given [oid] must belong to a committish on the walked repository.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void push(Oid oid) {
    bindings.push(walkerPointer: _revWalkPointer, oidPointer: oid.pointer);
  }

  /// Adds matching references for the traversal.
  ///
  /// The OIDs pointed to by the references that match the given [glob] pattern
  /// will be pushed to the revision walker.
  ///
  /// A leading "refs/" is implied if not present as well as a trailing "/\*"
  /// if the glob lacks "?", "*" or "[".
  ///
  /// Any references matching this glob which do not point to a committish will
  /// be ignored.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void pushGlob(String glob) {
    bindings.pushGlob(walkerPointer: _revWalkPointer, glob: glob);
  }

  /// Adds the repository's HEAD for the traversal.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void pushHead() => bindings.pushHead(_revWalkPointer);

  /// Adds the oid pointed to by a [reference] for the traversal.
  ///
  /// The reference must point to a committish.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void pushReference(String reference) {
    bindings.pushRef(walkerPointer: _revWalkPointer, refName: reference);
  }

  /// Adds and hide the respective endpoints of the given [range] for the
  /// traversal.
  ///
  /// The range should be of the form `<commit1>..<commit2>`. The left-hand commit
  /// will be hidden and the right-hand commit pushed.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void pushRange(String range) {
    bindings.pushRange(walkerPointer: _revWalkPointer, range: range);
  }

  /// Marks a commit [oid] (and its ancestors) uninteresting for the output.
  ///
  /// The given [oid] must belong to a committish on the walked repository.
  ///
  /// The resolved commit and all its parents will be hidden from the output on
  /// the revision walk.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void hide(Oid oid) {
    bindings.hide(walkerPointer: _revWalkPointer, oidPointer: oid.pointer);
  }

  /// Hides matching references.
  ///
  /// The OIDs pointed to by the references that match the given [glob] pattern
  /// and their ancestors will be hidden from the output on the revision walk.
  ///
  /// A leading "refs/" is implied if not present as well as a trailing "/\*" if
  /// the glob lacks "?", "*" or "[".
  ///
  /// Any references matching this glob which do not point to a committish will
  /// be ignored.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void hideGlob(String glob) {
    bindings.hideGlob(walkerPointer: _revWalkPointer, glob: glob);
  }

  /// Hides the repository's HEAD and its ancestors.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void hideHead() => bindings.hideHead(_revWalkPointer);

  /// Hides the oid pointed to by a [reference].
  ///
  /// The reference must point to a committish.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void hideReference(String reference) {
    bindings.hideRef(walkerPointer: _revWalkPointer, refName: reference);
  }

  /// Resets the revision walker for reuse.
  ///
  /// This will clear all the pushed and hidden commits, and leave the walker
  /// in a blank state (just like at creation) ready to receive new commit
  /// pushes and start a new walk.
  ///
  /// The revision walk is automatically reset when a walk is over.
  void reset() => bindings.reset(_revWalkPointer);

  /// Simplify the history by first-parent.
  ///
  /// No parents other than the first for each commit will be enqueued.
  /// This is useful for viewing the history of a branch without seeing
  /// merge commits.
  void simplifyFirstParent() => bindings.simplifyFirstParent(_revWalkPointer);

  /// Releases memory allocated for [RevWalk] object.
  ///
  /// This method should be called when the walker is no longer needed to
  /// prevent memory leaks.
  void free() {
    bindings.free(_revWalkPointer);
    _finalizer.detach(this);
  }
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_revwalk>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
