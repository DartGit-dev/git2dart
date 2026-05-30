import 'dart:ffi';

import 'package:git2dart/src/bindings/commit_graph.dart' as bindings;
import 'package:git2dart/src/repository.dart';
import 'package:git2dart/src/revwalk.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A file-backed Git commit graph.
@immutable
class CommitGraph {
  /// Opens a commit graph from a Git objects directory.
  CommitGraph.open(String objectsDir) {
    _commitGraphPointer = bindings.open(objectsDir);
    _finalizer.attach(this, _commitGraphPointer, detach: this);
  }

  late final Pointer<git_commit_graph> _commitGraphPointer;

  /// Pointer to the underlying commit graph.
  ///
  /// Note: For internal use.
  @internal
  Pointer<git_commit_graph> get pointer => _commitGraphPointer;

  /// Releases memory allocated for this commit graph.
  void free() {
    bindings.free(_commitGraphPointer);
    _finalizer.detach(this);
  }
}

final _finalizer = Finalizer<Pointer<git_commit_graph>>(
  (pointer) => bindings.free(pointer),
);

/// Writer for Git commit graph files.
@immutable
class CommitGraphWriter {
  /// Creates a writer for the given objects/info directory.
  CommitGraphWriter(String objectsInfoDir) {
    _writerPointer = bindings.writerNew(objectsInfoDir);
    _writerFinalizer.attach(this, _writerPointer, detach: this);
  }

  late final Pointer<git_commit_graph_writer> _writerPointer;

  /// Adds commits from [revWalk].
  void addRevWalk(RevWalk revWalk) {
    bindings.writerAddRevWalk(
      writerPointer: _writerPointer,
      revWalkPointer: revWalk.pointer,
    );
  }

  /// Adds an `.idx` file from [repo].
  void addIndexFile({required Repository repo, required String path}) {
    bindings.writerAddIndexFile(
      writerPointer: _writerPointer,
      repoPointer: repo.pointer,
      indexPath: path,
    );
  }

  /// Writes the commit graph file to disk.
  void commit() {
    bindings.writerCommit(_writerPointer);
  }

  /// Dumps the commit graph content to memory.
  List<int> dump() => bindings.writerDump(_writerPointer);

  /// Releases memory allocated for this writer.
  void free() {
    bindings.writerFree(_writerPointer);
    _writerFinalizer.detach(this);
  }
}

final _writerFinalizer = Finalizer<Pointer<git_commit_graph_writer>>(
  (pointer) => bindings.writerFree(pointer),
);
