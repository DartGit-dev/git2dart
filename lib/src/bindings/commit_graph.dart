import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Open a commit graph from a Git objects directory.
Pointer<git_commit_graph> open(String objectsDir) {
  return using((arena) {
    final out = arena<Pointer<git_commit_graph>>();
    final objectsDirC = objectsDir.toChar(arena);
    final options = arena<git_commit_graph_open_options>();
    options.ref.version = GIT_COMMIT_GRAPH_OPEN_OPTIONS_VERSION;

    final error = libgit2.git_commit_graph_open(out, objectsDirC, options);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a commit graph writer for an objects/info directory.
Pointer<git_commit_graph_writer> writerNew(String objectsInfoDir) {
  return using((arena) {
    final out = arena<Pointer<git_commit_graph_writer>>();
    final objectsInfoDirC = objectsInfoDir.toChar(arena);
    final options = arena<git_commit_graph_writer_options>();
    options.ref.version = GIT_COMMIT_GRAPH_WRITER_OPTIONS_VERSION;

    final error = libgit2.git_commit_graph_writer_new(
      out,
      objectsInfoDirC,
      options,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Add commits from [revWalkPointer] to [writerPointer].
void writerAddRevWalk({
  required Pointer<git_commit_graph_writer> writerPointer,
  required Pointer<git_revwalk> revWalkPointer,
}) {
  final error = libgit2.git_commit_graph_writer_add_revwalk(
    writerPointer,
    revWalkPointer,
  );

  checkErrorAndThrow(error);
}

/// Add an index file to [writerPointer].
void writerAddIndexFile({
  required Pointer<git_commit_graph_writer> writerPointer,
  required Pointer<git_repository> repoPointer,
  required String indexPath,
}) {
  using((arena) {
    final indexPathC = indexPath.toChar(arena);
    final error = libgit2.git_commit_graph_writer_add_index_file(
      writerPointer,
      repoPointer,
      indexPathC,
    );

    checkErrorAndThrow(error);
  });
}

/// Write the commit graph to disk.
void writerCommit(Pointer<git_commit_graph_writer> writerPointer) {
  final error = libgit2.git_commit_graph_writer_commit(writerPointer);

  checkErrorAndThrow(error);
}

/// Dump the commit graph writer contents to memory.
List<int> writerDump(Pointer<git_commit_graph_writer> writerPointer) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_commit_graph_writer_dump(out, writerPointer);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.cast<Uint8>().asTypedList(out.ref.size).toList();
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Free a commit graph.
void free(Pointer<git_commit_graph> commitGraph) {
  libgit2.git_commit_graph_free(commitGraph);
}

/// Free a commit graph writer.
void writerFree(Pointer<git_commit_graph_writer> writer) {
  libgit2.git_commit_graph_writer_free(writer);
}
