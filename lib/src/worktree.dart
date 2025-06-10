import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/worktree.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git worktree.
///
/// A worktree is a linked working copy of a Git repository. It allows you to
/// have multiple working directories for the same repository, each with its
/// own branch checked out.
@immutable
class Worktree extends Equatable {
  /// Creates a new worktree.
  ///
  /// Creates a new working tree for the repository at the specified path.
  /// If [ref] is provided, it will be used instead of creating a new branch.
  ///
  /// [repo] is the repository to create the worktree for.
  /// [name] is the name of the new worktree.
  /// [path] is the filesystem path where the worktree will be created.
  /// [ref] is an optional reference to checkout (if null, HEAD is used).
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  Worktree.create({
    required Repository repo,
    required String name,
    required String path,
    Reference? ref,
  }) {
    _worktreePointer = bindings.create(
      repoPointer: repo.pointer,
      name: name,
      path: path,
      refPointer: ref?.pointer,
    );
    _finalizer.attach(this, _worktreePointer, detach: this);
  }

  /// Looks up an existing worktree in [repo] with the provided [name].
  ///
  /// Throws a [LibGit2Error] if an error occurs or if the worktree is not found.
  Worktree.lookup({required Repository repo, required String name}) {
    _worktreePointer = bindings.lookup(repoPointer: repo.pointer, name: name);
    _finalizer.attach(this, _worktreePointer, detach: this);
  }

  /// Opens the main worktree belonging to the provided [repo].
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  Worktree.openFromRepository({required Repository repo}) {
    _worktreePointer = bindings.openFromRepository(repo.pointer);
    _finalizer.attach(this, _worktreePointer, detach: this);
  }

  /// Pointer to the memory address for the allocated worktree object.
  late final Pointer<git_worktree> _worktreePointer;

  /// Returns a list of names of linked working trees in the repository.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static List<String> list(Repository repo) {
    final worktrees = bindings.list(repo.pointer);
    return worktrees.map((wt) => bindings.name(wt)).toList();
  }

  /// Gets the name of the worktree.
  String get name => bindings.name(_worktreePointer);

  /// Gets the filesystem path for the worktree.
  String get path => bindings.path(_worktreePointer);

  /// Checks if the worktree is locked.
  ///
  /// A worktree may be locked if the linked working tree is stored on a
  /// portable device which is not available.
  bool get isLocked => bindings.isLocked(_worktreePointer);

  /// Locks the worktree if it is not already locked.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void lock() => bindings.lock(_worktreePointer);

  /// Unlocks a locked worktree.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void unlock() => bindings.unlock(_worktreePointer);

  /// Checks if the worktree is prunable.
  ///
  /// A worktree is not prunable in the following scenarios:
  /// - The worktree is linking to a valid on-disk worktree
  /// - The worktree is locked
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  bool get isPrunable => bindings.isPrunable(_worktreePointer);

  /// Prunes the working tree by removing its git data structures from disk.
  ///
  /// [flags] is an optional combination of [GitWorktree] flags.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  void prune([Set<GitWorktree>? flags]) {
    bindings.prune(
      worktreePointer: _worktreePointer,
      flags: flags?.fold(0, (acc, e) => acc! | e.value),
    );
  }

  /// Opens the repository that belongs to this worktree.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  Repository repositoryFromWorktree() {
    final pointer = bindings.repositoryFromWorktree(_worktreePointer);
    return Repository(pointer);
  }

  /// Validates the worktree configuration.
  ///
  /// Throws a [LibGit2Error] if the worktree is invalid.
  void validate() => bindings.validate(_worktreePointer);

  /// Checks if the worktree is valid.
  ///
  /// A valid worktree requires both the git data structures inside the linked
  /// parent repository and the linked working copy to be present.
  bool get isValid => bindings.isValid(_worktreePointer);

  /// Releases memory allocated for the worktree object.
  void free() {
    bindings.free(_worktreePointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'Worktree{name: $name, path: $path, isLocked: $isLocked, '
        'isPrunable: $isPrunable, isValid: $isValid}';
  }

  @override
  List<Object?> get props => [name, path, isLocked, isValid];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_worktree>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
