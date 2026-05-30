import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/pathspec.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// Flags controlling pathspec matching.
enum GitPathspec {
  /// Default matching behavior.
  defaults(0),

  /// Match paths ignoring case.
  ignoreCase(1),

  /// Match paths case-sensitively.
  useCase(2),

  /// Disable glob patterns.
  noGlob(4),

  /// Throw a [LibGit2Error] when no paths match.
  noMatchError(8),

  /// Track pathspec patterns that did not match anything.
  findFailures(16),

  /// Return only pathspec patterns that did not match anything.
  failuresOnly(32);

  const GitPathspec(this.value);
  final int value;
}

int _flags(Set<GitPathspec> flags) {
  return flags.fold(0, (acc, e) => acc | e.value);
}

/// Compiled Git pathspec.
@immutable
class Pathspec extends Equatable {
  /// Compiles [patterns] into a reusable pathspec.
  Pathspec(List<String> patterns) : patterns = List.unmodifiable(patterns) {
    _pathspecPointer = bindings.create(patterns);
    _finalizer.attach(this, _pathspecPointer, detach: this);
  }

  /// Original pathspec patterns.
  final List<String> patterns;

  late final Pointer<git_pathspec> _pathspecPointer;

  /// Pointer to the underlying pathspec.
  ///
  /// Note: For internal use.
  @internal
  Pointer<git_pathspec> get pointer => _pathspecPointer;

  /// Returns whether [path] matches this pathspec.
  bool matchesPath(
    String path, {
    Set<GitPathspec> flags = const {GitPathspec.defaults},
  }) {
    return bindings.matchesPath(
      pathspecPointer: _pathspecPointer,
      path: path,
      flags: _flags(flags),
    );
  }

  /// Matches this pathspec against [repo]'s workdir.
  PathspecMatchList matchWorkdir({
    required Repository repo,
    Set<GitPathspec> flags = const {GitPathspec.defaults},
  }) {
    return PathspecMatchList(
      bindings.matchWorkdir(
        repoPointer: repo.pointer,
        pathspecPointer: _pathspecPointer,
        flags: _flags(flags),
      ),
    );
  }

  /// Matches this pathspec against [index].
  PathspecMatchList matchIndex({
    required Index index,
    Set<GitPathspec> flags = const {GitPathspec.defaults},
  }) {
    return PathspecMatchList(
      bindings.matchIndex(
        indexPointer: index.pointer,
        pathspecPointer: _pathspecPointer,
        flags: _flags(flags),
      ),
    );
  }

  /// Matches this pathspec against [tree].
  PathspecMatchList matchTree({
    required Tree tree,
    Set<GitPathspec> flags = const {GitPathspec.defaults},
  }) {
    return PathspecMatchList(
      bindings.matchTree(
        treePointer: tree.pointer,
        pathspecPointer: _pathspecPointer,
        flags: _flags(flags),
      ),
    );
  }

  /// Matches this pathspec against [diff].
  PathspecMatchList matchDiff({
    required Diff diff,
    Set<GitPathspec> flags = const {GitPathspec.defaults},
  }) {
    return PathspecMatchList(
      bindings.matchDiff(
        diffPointer: diff.pointer,
        pathspecPointer: _pathspecPointer,
        flags: _flags(flags),
      ),
    );
  }

  /// Releases memory allocated for this pathspec.
  void free() {
    bindings.free(_pathspecPointer);
    _finalizer.detach(this);
  }

  @override
  List<Object?> get props => [patterns];
}

final _finalizer = Finalizer<Pointer<git_pathspec>>(
  (pointer) => bindings.free(pointer),
);

/// Result of matching a pathspec.
@immutable
class PathspecMatchList extends Equatable {
  /// Creates a match list from a native pointer.
  ///
  /// Note: For internal use.
  @internal
  PathspecMatchList(this._matchListPointer) {
    _matchListFinalizer.attach(this, _matchListPointer, detach: this);
  }

  final Pointer<git_pathspec_match_list> _matchListPointer;

  /// Matched path entries.
  List<String> get entries => bindings.entries(_matchListPointer);

  /// Pathspec patterns that did not match anything.
  List<String> get failedEntries {
    return bindings.failedEntries(_matchListPointer);
  }

  /// Releases memory allocated for this match list.
  void free() {
    bindings.freeMatchList(_matchListPointer);
    _matchListFinalizer.detach(this);
  }

  @override
  List<Object?> get props => [entries, failedEntries];
}

final _matchListFinalizer = Finalizer<Pointer<git_pathspec_match_list>>(
  (pointer) => bindings.freeMatchList(pointer),
);
