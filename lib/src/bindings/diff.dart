// coverage:ignore-file
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Create a diff with the difference between two index objects. The returned
/// diff must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_diff> indexToIndex({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_index> oldIndexPointer,
  required Pointer<git_index> newIndexPointer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_diff_index_to_index(
      out,
      repoPointer,
      oldIndexPointer,
      newIndexPointer,
      opts,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a diff between the repository index and the workdir directory. The
/// returned diff must be freed with [free].
Pointer<git_diff> indexToWorkdir({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_index> indexPointer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_diff_index_to_workdir(
      out,
      repoPointer,
      indexPointer,
      opts,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a diff between a tree and repository index. The returned diff must
/// be freed with [free].
Pointer<git_diff> treeToIndex({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree>? treePointer,
  required Pointer<git_index> indexPointer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_diff_tree_to_index(
      out,
      repoPointer,
      treePointer ?? nullptr,
      indexPointer,
      opts,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a diff between a tree and the working directory. The returned
/// diff must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_diff> treeToWorkdir({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree>? treePointer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_diff_tree_to_workdir(
      out,
      repoPointer,
      treePointer ?? nullptr,
      opts,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a diff between a tree and the working directory using index data to
/// account for staged deletes, tracked files, etc. The returned diff must be
/// freed with [free].
///
/// This emulates `git diff <tree>` by diffing the tree to the index and the
/// index to the working directory and blending the results into a single diff
/// that includes staged deleted, etc.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_diff> treeToWorkdirWithIndex({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree>? treePointer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_diff_tree_to_workdir_with_index(
      out,
      repoPointer,
      treePointer ?? nullptr,
      opts,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a diff with the difference between two tree objects. The returned
/// diff must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_diff> treeToTree({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree>? oldTreePointer,
  required Pointer<git_tree>? newTreePointer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_diff_tree_to_tree(
      out,
      repoPointer,
      oldTreePointer ?? nullptr,
      newTreePointer ?? nullptr,
      opts,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Query how many diff records are there in a diff.
int length(Pointer<git_diff> diff) => libgit2.git_diff_num_deltas(diff);

/// Query how many diff records have [type].
int lengthOfType({
  required Pointer<git_diff> diffPointer,
  required git_delta_t type,
}) {
  return libgit2.git_diff_num_deltas_of_type(diffPointer, type);
}

/// Return whether deltas are sorted case-insensitively.
bool isSortedICase(Pointer<git_diff> diff) {
  return libgit2.git_diff_is_sorted_icase(diff) == 1;
}

/// Merge one diff into another.
///
/// This modifies the first diff to include the changes from the second diff.
///
/// Throws a [LibGit2Error] if error occurred.
void merge({
  required Pointer<git_diff> diffPointer,
  required Pointer<git_diff> fromDiffPointer,
}) {
  final error = libgit2.git_diff_merge(diffPointer, fromDiffPointer);
  checkErrorAndThrow(error);
}

/// Read the contents of a git patch file into a git diff object. The returned
/// diff must be freed with [free].
///
/// The diff object produced is similar to the one that would be produced if
/// you actually produced it computationally by comparing two trees, however
/// there may be subtle differences. For example, a patch file likely contains
/// abbreviated object IDs, so the object IDs in a diff delta produced by this
/// function will also be abbreviated.
///
/// This function will only read patch files created by a git implementation,
/// it will not read unified diffs produced by the `diff` program, nor any
/// other types of patch files.
Pointer<git_diff> parse(
  String content, {
  git_oid_t oidType = git_oid_t.GIT_OID_SHA1,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff>>();
    final contentC = content.toChar(arena);

    final opts = arena<git_diff_parse_options>();
    opts.ref.version = GIT_DIFF_PARSE_OPTIONS_VERSION;
    opts.ref.oid_typeAsInt = oidType.value;

    final error = libgit2.git_diff_from_buffer(
      out,
      contentC,
      content.length,
      opts,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Transform a diff marking file renames, copies, etc.
///
/// This modifies a diff in place, replacing old entries that look like renames
/// or copies with new entries reflecting those changes. This also will, if
/// requested, break modified files into add/remove pairs if the amount of
/// change is above a threshold.
///
/// Throws a [LibGit2Error] if error occured.
void findSimilar({
  required Pointer<git_diff> diffPointer,
  required Pointer<git_diff_find_options> options,
}) {
  final error = libgit2.git_diff_find_similar(diffPointer, options);
  checkErrorAndThrow(error);
}

/// Calculate the patch ID for the given patch.
///
/// Calculate a stable patch ID for the given patch by summing the hash of the
/// file diffs, ignoring whitespace and line numbers. This can be used to
/// derive whether two diffs are the same with a high probability.
///
/// Currently, this function only calculates stable patch IDs, as defined in
/// `git-patch-id(1)`, and should in fact generate the same IDs as the upstream
/// git project does.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> patchOid(
  Pointer<git_diff> diff, {
  Pointer<git_diff_patchid_options>? options,
}) {
  final out = calloc<git_oid>();
  final error = libgit2.git_diff_patchid(out, diff, options ?? nullptr);

  checkErrorAndThrow(error);

  return out;
}

/// Allocate and initialize `git_diff_patchid_options` structure.
Pointer<git_diff_patchid_options> initPatchIdOptions() {
  final opts = calloc<git_diff_patchid_options>();
  libgit2.git_diff_patchid_options_init(opts, GIT_DIFF_PATCHID_OPTIONS_VERSION);
  return opts;
}

/// Return the diff delta for an entry in the diff list.
Pointer<git_diff_delta> getDeltaByIndex({
  required Pointer<git_diff> diffPointer,
  required int index,
}) {
  return libgit2.git_diff_get_delta(diffPointer, index);
}

/// Look up the single character abbreviation for a delta status code.
///
/// When you run `git diff --name-status` it uses single letter codes in the
/// output such as 'A' for added, 'D' for deleted, 'M' for modified, etc. This
/// function converts a [GitDelta] value into these letters for your own
/// purposes. [GitDelta.untracked] will return a space (i.e. ' ').
String statusChar(git_delta_t status) {
  return String.fromCharCode(libgit2.git_diff_status_char(status));
}

/// Accumulate diff statistics for all patches. The returned diff stats must be
/// freed with [freeStats].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_diff_stats> stats(Pointer<git_diff> diff) {
  return using((arena) {
    final out = arena<Pointer<git_diff_stats>>();
    final error = libgit2.git_diff_get_stats(out, diff);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get performance data for [diff].
DiffPerfData perfData(Pointer<git_diff> diff) {
  return using((arena) {
    final out = arena<git_diff_perfdata>();
    out.ref.version = GIT_DIFF_PERFDATA_VERSION;
    final error = libgit2.git_diff_get_perfdata(out, diff);

    checkErrorAndThrow(error);

    return DiffPerfData(
      statCalls: out.ref.stat_calls,
      oidCalculations: out.ref.oid_calculations,
    );
  });
}

/// Get the total number of insertions in a diff.
int statsInsertions(Pointer<git_diff_stats> stats) =>
    libgit2.git_diff_stats_insertions(stats);

/// Get the total number of deletions in a diff.
int statsDeletions(Pointer<git_diff_stats> stats) =>
    libgit2.git_diff_stats_deletions(stats);

/// Get the total number of files changed in a diff.
int statsFilesChanged(Pointer<git_diff_stats> stats) =>
    libgit2.git_diff_stats_files_changed(stats);

/// Print diff statistics.
///
/// Throws a [LibGit2Error] if error occured.
String statsPrint({
  required Pointer<git_diff_stats> statsPointer,
  required git_diff_stats_format_t format,
  required int width,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_diff_stats_to_buf(
      out,
      statsPointer,
      format,
      width,
    );
    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);

    return result;
  });
}

/// Produce the complete formatted text output from a diff into a buffer.
String addToBuf(Pointer<git_diff> diff) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_diff_to_buf(
      out,
      diff,
      git_diff_format_t.GIT_DIFF_FORMAT_PATCH,
    );
    checkErrorAndThrow(error);

    final result =
        out.ref.ptr == nullptr
            ? ''
            : out.ref.ptr.toDartString(length: out.ref.size);

    libgit2.git_buf_dispose(out);
    return result;
  });
}

var _printedDiffLines = <String>[];
var _foreachFilePaths = <String>[];
var _foreachLineOrigins = <int>[];

String _lineContent(Pointer<git_diff_line> line) {
  if (line == nullptr || line.ref.content == nullptr) {
    return '';
  }

  final content = line.ref.content.toDartString(length: line.ref.content_len);
  final origin = line.ref.origin;
  if (origin == git_diff_line_t.GIT_DIFF_LINE_ADDITION.value ||
      origin == git_diff_line_t.GIT_DIFF_LINE_DELETION.value) {
    return '${String.fromCharCode(origin)}$content';
  }
  if (origin == git_diff_line_t.GIT_DIFF_LINE_CONTEXT.value) {
    return ' $content';
  }

  return content;
}

int _diffPrintCb(
  Pointer<git_diff_delta> delta,
  Pointer<git_diff_hunk> hunk,
  Pointer<git_diff_line> line,
  Pointer<Void> payload,
) {
  _printedDiffLines.add(_lineContent(line));
  return 0;
}

int _diffFileCb(
  Pointer<git_diff_delta> delta,
  double progress,
  Pointer<Void> payload,
) {
  final path =
      delta.ref.new_file.path == nullptr
          ? delta.ref.old_file.path.toDartString()
          : delta.ref.new_file.path.toDartString();
  _foreachFilePaths.add(path);
  return 0;
}

int _diffHunkCb(
  Pointer<git_diff_delta> delta,
  Pointer<git_diff_hunk> hunk,
  Pointer<Void> payload,
) {
  return 0;
}

int _diffLineCb(
  Pointer<git_diff_delta> delta,
  Pointer<git_diff_hunk> hunk,
  Pointer<git_diff_line> line,
  Pointer<Void> payload,
) {
  _foreachLineOrigins.add(line.ref.origin);
  _printedDiffLines.add(_lineContent(line));
  return 0;
}

git_diff_line_cb _lineCallback() {
  return Pointer.fromFunction<
    Int Function(
      Pointer<git_diff_delta>,
      Pointer<git_diff_hunk>,
      Pointer<git_diff_line>,
      Pointer<Void>,
    )
  >(_diffPrintCb, 0);
}

/// Iterate over a diff and collect formatted text through the print callback.
String print(Pointer<git_diff> diff) {
  final cb = _lineCallback();

  _printedDiffLines.clear();
  final error = libgit2.git_diff_print(
    diff,
    git_diff_format_t.GIT_DIFF_FORMAT_PATCH,
    cb,
    nullptr,
  );

  checkErrorAndThrow(error);
  final result = _printedDiffLines.join();
  _printedDiffLines.clear();
  return result;
}

/// Iterate over a diff and return file paths and line origin codes.
Map<String, Object> foreach(Pointer<git_diff> diff) {
  final fileCb = Pointer.fromFunction<
    Int Function(Pointer<git_diff_delta>, Float, Pointer<Void>)
  >(_diffFileCb, 0);
  final hunkCb = Pointer.fromFunction<
    Int Function(Pointer<git_diff_delta>, Pointer<git_diff_hunk>, Pointer<Void>)
  >(_diffHunkCb, 0);
  final lineCb = Pointer.fromFunction<
    Int Function(
      Pointer<git_diff_delta>,
      Pointer<git_diff_hunk>,
      Pointer<git_diff_line>,
      Pointer<Void>,
    )
  >(_diffLineCb, 0);

  _foreachFilePaths.clear();
  _foreachLineOrigins.clear();
  _printedDiffLines.clear();

  final error = libgit2.git_diff_foreach(
    diff,
    fileCb,
    nullptr,
    hunkCb,
    lineCb,
    nullptr,
  );

  checkErrorAndThrow(error);

  final result = {
    'paths': _foreachFilePaths.toList(growable: false),
    'origins': _foreachLineOrigins.toList(growable: false),
    'text': _printedDiffLines.join(),
  };

  _foreachFilePaths.clear();
  _foreachLineOrigins.clear();
  _printedDiffLines.clear();
  return result;
}

String _runDirectDiff({
  required Arena arena,
  Pointer<git_blob>? oldBlobPointer,
  String? oldAsPath,
  Pointer<git_blob>? newBlobPointer,
  String? newAsPath,
  String? oldBuffer,
  String? newBuffer,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  final oldAsPathC = oldAsPath?.toChar(arena) ?? nullptr;
  final newAsPathC = newAsPath?.toChar(arena) ?? nullptr;
  final oldBufferC = oldBuffer?.toChar(arena) ?? nullptr;
  final newBufferC = newBuffer?.toChar(arena) ?? nullptr;
  final opts = _diffOptionsInit(
    arena: arena,
    flags: flags,
    contextLines: contextLines,
    interhunkLines: interhunkLines,
  );
  final fileCb = Pointer.fromFunction<
    Int Function(Pointer<git_diff_delta>, Float, Pointer<Void>)
  >(_diffFileCb, 0);
  final hunkCb = Pointer.fromFunction<
    Int Function(Pointer<git_diff_delta>, Pointer<git_diff_hunk>, Pointer<Void>)
  >(_diffHunkCb, 0);
  final lineCb = Pointer.fromFunction<
    Int Function(
      Pointer<git_diff_delta>,
      Pointer<git_diff_hunk>,
      Pointer<git_diff_line>,
      Pointer<Void>,
    )
  >(_diffLineCb, 0);

  _foreachFilePaths.clear();
  _foreachLineOrigins.clear();
  _printedDiffLines.clear();

  int error;
  if (oldBuffer != null || oldBlobPointer == null) {
    error = libgit2.git_diff_buffers(
      oldBufferC.cast(),
      oldBuffer?.length ?? 0,
      oldAsPathC,
      newBufferC.cast(),
      newBuffer?.length ?? 0,
      newAsPathC,
      opts,
      fileCb,
      nullptr,
      hunkCb,
      lineCb,
      nullptr,
    );
  } else if (newBlobPointer != null) {
    error = libgit2.git_diff_blobs(
      oldBlobPointer,
      oldAsPathC,
      newBlobPointer,
      newAsPathC,
      opts,
      fileCb,
      nullptr,
      hunkCb,
      lineCb,
      nullptr,
    );
  } else {
    error = libgit2.git_diff_blob_to_buffer(
      oldBlobPointer,
      oldAsPathC,
      newBufferC,
      newBuffer?.length ?? 0,
      newAsPathC,
      opts,
      fileCb,
      nullptr,
      hunkCb,
      lineCb,
      nullptr,
    );
  }

  checkErrorAndThrow(error);
  final result = _printedDiffLines.join();
  _foreachFilePaths.clear();
  _foreachLineOrigins.clear();
  _printedDiffLines.clear();
  return result;
}

/// Directly diff two buffers and return collected line text.
String buffers({
  String? oldBuffer,
  String? oldAsPath,
  String? newBuffer,
  String? newAsPath,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using(
    (arena) => _runDirectDiff(
      arena: arena,
      oldBuffer: oldBuffer,
      oldAsPath: oldAsPath,
      newBuffer: newBuffer,
      newAsPath: newAsPath,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    ),
  );
}

/// Directly diff two blobs and return collected line text.
String blobs({
  required Pointer<git_blob>? oldBlobPointer,
  String? oldAsPath,
  required Pointer<git_blob>? newBlobPointer,
  String? newAsPath,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using(
    (arena) => _runDirectDiff(
      arena: arena,
      oldBlobPointer: oldBlobPointer,
      oldAsPath: oldAsPath,
      newBlobPointer: newBlobPointer,
      newAsPath: newAsPath,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    ),
  );
}

/// Directly diff a blob and a buffer and return collected line text.
String blobToBuffer({
  Pointer<git_blob>? oldBlobPointer,
  String? oldAsPath,
  String? buffer,
  String? bufferAsPath,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using(
    (arena) => _runDirectDiff(
      arena: arena,
      oldBlobPointer: oldBlobPointer,
      oldAsPath: oldAsPath,
      newBuffer: buffer,
      newAsPath: bufferAsPath,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    ),
  );
}

/// Counter for hunk number being applied.
///
/// **IMPORTANT**: make sure to reset it to 0 before using since it's a global
/// variable.
int _counter = 0;

/// When applying a patch, callback that will be made per hunk.
int _hunkCb(Pointer<git_diff_hunk> hunk, Pointer<Void> payload) {
  final index = payload.cast<Int32>().value;
  if (_counter == index) {
    _counter++;
    return 0;
  } else {
    _counter++;
    return 1;
  }
}

/// Apply a diff to the given repository, making changes directly in the
/// working directory, the index, or both.
///
/// Throws a [LibGit2Error] if error occured.
bool apply({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_diff> diffPointer,
  int? hunkIndex,
  required git_apply_location_t location,
  bool check = false,
}) {
  return using((arena) {
    final opts = arena<git_apply_options>();
    final error = libgit2.git_apply_options_init(
      opts,
      GIT_APPLY_OPTIONS_VERSION,
    );
    checkErrorAndThrow(error);

    if (check) {
      opts.ref.flags |= git_apply_flags_t.GIT_APPLY_CHECK.value;
    }

    Pointer<Int32> payload = nullptr;
    if (hunkIndex != null) {
      _counter = 0;
      const except = -1;
      // ignore: omit_local_variable_types
      final git_apply_hunk_cb callback = Pointer.fromFunction(_hunkCb, except);
      payload = arena<Int32>()..value = hunkIndex;
      opts.ref.payload = payload.cast();
      opts.ref.hunk_cb = callback;
    }

    final errorApply = libgit2.git_apply(
      repoPointer,
      diffPointer,
      location,
      opts,
    );

    if (errorApply >= 0) {
      return true;
    }

    return check ? false : throw LibGit2Error(libgit2.git_error_last());
  });
}

/// Apply a diff to a tree, and return the resulting image as an index. The
/// returned index must be freed.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_index> applyToTree({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree> treePointer,
  required Pointer<git_diff> diffPointer,
  int? hunkIndex,
}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final opts = arena<git_apply_options>();
    libgit2.git_apply_options_init(opts, GIT_APPLY_OPTIONS_VERSION);

    Pointer<Int32> payload = nullptr;
    if (hunkIndex != null) {
      _counter = 0;
      const except = -1;
      // ignore: omit_local_variable_types
      final git_apply_hunk_cb callback = Pointer.fromFunction(_hunkCb, except);
      payload = arena<Int32>()..value = hunkIndex;
      opts.ref.payload = payload.cast();
      opts.ref.hunk_cb = callback;
    }

    final error = libgit2.git_apply_to_tree(
      out,
      repoPointer,
      treePointer,
      diffPointer,
      opts,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Free a previously allocated diff stats.
void freeStats(Pointer<git_diff_stats> stats) =>
    libgit2.git_diff_stats_free(stats);

/// Free a previously allocated diff.
void free(Pointer<git_diff> diff) => libgit2.git_diff_free(diff);

/// Diff performance counters.
class DiffPerfData {
  /// Creates diff performance counters.
  const DiffPerfData({required this.statCalls, required this.oidCalculations});

  /// Number of stat calls performed.
  final int statCalls;

  /// Number of object ID calculations performed.
  final int oidCalculations;
}

Pointer<git_diff_options> _diffOptionsInit({
  required Arena arena,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  final opts = arena<git_diff_options>();
  libgit2.git_diff_options_init(opts, GIT_DIFF_OPTIONS_VERSION);

  opts.ref.flags = flags;
  opts.ref.context_lines = contextLines;
  opts.ref.interhunk_lines = interhunkLines;
  return opts;
}

// /// Format a patch into an email.
// ///
// /// The returned string must be freed with [free].
// ///
// /// Throws a [LibGit2Error] if error occurred.
// String formatEmail({
//   required Pointer<git_diff> diffPointer,
//   required Pointer<git_email_create_options> options,
// }) {
//   return using((arena) {
//     final out = arena<git_buf>();
//     final error = libgit2.git_email_create_from_diff(out, diff, patch_idx, patch_count, commit_id, summary, body, author, opts)

//     git_diff_format_email(out, diffPointer, options);
//     checkErrorAndThrow(error);

//     final result = out.ref.ptr.toDartString(length: out.ref.size);
//     libgit2.git_buf_dispose(out);

//     return result;
//   });
// }
