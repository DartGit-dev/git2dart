import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/error.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart/src/oid.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Get the blame for a single file. The returned blame must be freed with
/// [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_blame> file({
  required Pointer<git_repository> repoPointer,
  required String path,
  required int flags,
  int? minMatchCharacters,
  Oid? newestCommit,
  Oid? oldestCommit,
  int? minLine,
  int? maxLine,
}) {
  return using((arena) {
    final out = arena<Pointer<git_blame>>();
    final pathC = path.toChar(arena);
    final options = arena<git_blame_options>();
    libgit2.git_blame_options_init(options, GIT_BLAME_OPTIONS_VERSION);

    options.ref.flags = flags;

    if (minMatchCharacters != null) {
      options.ref.min_match_characters = minMatchCharacters;
    }

    if (newestCommit != null) {
      options.ref.newest_commit = newestCommit.pointer.ref;
    }

    if (oldestCommit != null) {
      options.ref.oldest_commit = oldestCommit.pointer.ref;
    }

    if (minLine != null) {
      options.ref.min_line = minLine;
    }

    if (maxLine != null) {
      options.ref.max_line = maxLine;
    }

    final error = libgit2.git_blame_file(out, repoPointer, pathC, options);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get blame data for a file that has been modified in memory.
///
/// The returned blame must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_blame> buffer({
  required String buffer,
  required int bufferLen,
  Pointer<git_blame>? ref,
}) {
  return using((arena) {
    final out = arena<Pointer<git_blame>>();
    final bufferC = buffer.toChar(arena);

    final error = libgit2.git_blame_buffer(
      out,
      ref ?? nullptr,
      bufferC,
      bufferLen,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Gets the number of hunks that exist in the blame structure.
int hunkCount(Pointer<git_blame> blame) {
  return libgit2.git_blame_get_hunk_count(blame);
}

/// Get the hunk that contains the given line number.
///
/// The returned hunk is owned by the blame and must not be freed.
///
/// Throws [Git2DartError] if the line number is out of bounds.
Pointer<git_blame_hunk> getHunkByline({
  required Pointer<git_blame> blamePointer,
  required int lineno,
}) {
  final result = libgit2.git_blame_get_hunk_byline(blamePointer, lineno);

  if (result == nullptr) {
    throw Git2DartError('Line number out of bounds');
  } else {
    return result;
  }
}

/// Get the hunk at the given index.
///
/// The returned hunk is owned by the blame and must not be freed.
///
/// Throws [Git2DartError] if the index is out of bounds.
Pointer<git_blame_hunk> getHunkByindex({
  required Pointer<git_blame> blamePointer,
  required int index,
}) {
  final result = libgit2.git_blame_get_hunk_byindex(blamePointer, index);

  if (result == nullptr) {
    throw Git2DartError('Index out of bounds');
  } else {
    return result;
  }
}

/// Free memory allocated for blame object.
void free(Pointer<git_blame> blame) => libgit2.git_blame_free(blame);
