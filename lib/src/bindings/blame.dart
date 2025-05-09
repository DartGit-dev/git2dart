import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/error.dart';
import 'package:git2dart/src/extensions.dart';
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
  final out = calloc<Pointer<git_blame>>();
  final pathC = path.toChar();
  final options = calloc<git_blame_options>();
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

  final result = out.value;

  calloc.free(out);
  calloc.free(pathC);
  calloc.free(options);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
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
  final out = calloc<Pointer<git_blame>>();
  final bufferC = buffer.toChar();
  final error = libgit2.git_blame_buffer(
    out,
    ref ?? nullptr,
    bufferC,
    bufferLen,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(bufferC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Gets the number of hunks that exist in the blame structure.
int hunkCount(Pointer<git_blame> blame) {
  return libgit2.git_blame_get_hunk_count(blame);
}

/// Get the hunk that contains the given line number.
///
/// The returned hunk is owned by the blame and must not be freed.
///
/// Throws [ArgumentError] if the line number is out of bounds.
Pointer<git_blame_hunk> getHunkByline({
  required Pointer<git_blame> blamePointer,
  required int lineno,
}) {
  final result = libgit2.git_blame_get_hunk_byline(blamePointer, lineno);

  if (result == nullptr) {
    throw ArgumentError('Line number out of bounds');
  } else {
    return result;
  }
}

/// Get the hunk at the given index.
///
/// The returned hunk is owned by the blame and must not be freed.
///
/// Throws [RangeError] if the index is out of bounds.
Pointer<git_blame_hunk> getHunkByindex({
  required Pointer<git_blame> blamePointer,
  required int index,
}) {
  final result = libgit2.git_blame_get_hunk_byindex(blamePointer, index);

  if (result == nullptr) {
    throw RangeError('Index out of bounds');
  } else {
    return result;
  }
}

/// Free memory allocated for blame object.
void free(Pointer<git_blame> blame) => libgit2.git_blame_free(blame);
