import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Directly generate a patch from the difference between two buffers. The
/// returned patch must be freed with [free].
Pointer<git_patch> fromBuffers({
  String? oldBuffer,
  String? oldAsPath,
  String? newBuffer,
  String? newAsPath,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_patch>>();
    final oldBufferC = oldBuffer?.toChar(arena) ?? nullptr;
    final oldAsPathC = oldAsPath?.toChar(arena) ?? nullptr;
    final oldLen = oldBuffer?.length ?? 0;
    final newBufferC = newBuffer?.toCharAlloc() ?? nullptr;
    final newAsPathC = newAsPath?.toCharAlloc() ?? nullptr;
    final newLen = newBuffer?.length ?? 0;
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_patch_from_buffers(
      out,
      oldBufferC.cast(),
      oldLen,
      oldAsPathC,
      newBufferC.cast(),
      newLen,
      newAsPathC,
      opts,
    );

    checkErrorAndThrow(error);

    // We are not freeing buffers `oldBufferC` and `newBufferC` because patch
    // object does not have reference to underlying buffers. So if the buffer is
    // freed the patch text becomes corrupted.

    return out.value;
  });
}

/// Directly generate a patch from the difference between two blobs. The
/// returned patch must be freed with [free].
Pointer<git_patch> fromBlobs({
  required Pointer<git_blob>? oldBlobPointer,
  String? oldAsPath,
  required Pointer<git_blob>? newBlobPointer,
  String? newAsPath,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_patch>>();
    final oldAsPathC = oldAsPath?.toChar(arena) ?? nullptr;
    final newAsPathC = oldAsPath?.toChar(arena) ?? nullptr;
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_patch_from_blobs(
      out,
      oldBlobPointer ?? nullptr,
      oldAsPathC,
      newBlobPointer ?? nullptr,
      newAsPathC,
      opts,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Directly generate a patch from the difference between a blob and a buffer.
/// The returned patch must be freed with [free].
Pointer<git_patch> fromBlobAndBuffer({
  Pointer<git_blob>? oldBlobPointer,
  String? oldAsPath,
  String? buffer,
  String? bufferAsPath,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  return using((arena) {
    final out = arena<Pointer<git_patch>>();
    final oldAsPathC = oldAsPath?.toChar(arena) ?? nullptr;
    final bufferC = buffer?.toCharAlloc() ?? nullptr;
    final bufferAsPathC = oldAsPath?.toChar(arena) ?? nullptr;
    final bufferLen = buffer?.length ?? 0;
    final opts = _diffOptionsInit(
      arena: arena,
      flags: flags,
      contextLines: contextLines,
      interhunkLines: interhunkLines,
    );

    final error = libgit2.git_patch_from_blob_and_buffer(
      out,
      oldBlobPointer ?? nullptr,
      oldAsPathC,
      bufferC.cast(),
      bufferLen,
      bufferAsPathC,
      opts,
    );
    checkErrorAndThrow(error);

    // We are not freeing buffer `bufferC` because patch object does not have
    // reference to underlying buffers. So if the buffer is freed the patch text
    // becomes corrupted.

    return out.value;
  });
}

/// Return a patch for an entry in the diff list. The returned patch must be
/// freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_patch> fromDiff({
  required Pointer<git_diff> diffPointer,
  required int index,
}) {
  return using((arena) {
    final out = arena<Pointer<git_patch>>();
    final error = libgit2.git_patch_from_diff(out, diffPointer, index);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get the delta associated with a patch.
Pointer<git_diff_delta> delta(Pointer<git_patch> patch) =>
    libgit2.git_patch_get_delta(patch);

/// Get the repository that owns this patch.
Pointer<git_repository> owner(Pointer<git_patch> patch) =>
    libgit2.git_patch_owner(patch);

/// Get the number of hunks in a patch.
int numHunks(Pointer<git_patch> patch) => libgit2.git_patch_num_hunks(patch);

/// Get the information about a hunk in a patch.
///
/// Given a patch and a hunk index into the patch, this returns detailed
/// information about that hunk.
Map<String, Object> hunk({
  required Pointer<git_patch> patchPointer,
  required int hunkIndex,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff_hunk>>();
    final linesInHunk = arena<Size>();

    final error = libgit2.git_patch_get_hunk(
      out,
      linesInHunk,
      patchPointer,
      hunkIndex,
    );
    checkErrorAndThrow(error);

    final hunk = out.value;
    final linesN = linesInHunk.value;

    return {'hunk': hunk, 'linesN': linesN};
  });
}

/// Get the number of lines in a hunk of a patch.
int numLinesInHunk({
  required Pointer<git_patch> patchPointer,
  required int hunkIndex,
}) {
  return libgit2.git_patch_num_lines_in_hunk(patchPointer, hunkIndex);
}

/// Get line counts of each type in a patch.
Map<String, int> lineStats(Pointer<git_patch> patch) {
  return using((arena) {
    final context = arena<Size>();
    final insertions = arena<Size>();
    final deletions = arena<Size>();

    final error = libgit2.git_patch_line_stats(
      context,
      insertions,
      deletions,
      patch,
    );
    checkErrorAndThrow(error);

    return {
      'context': context.value,
      'insertions': insertions.value,
      'deletions': deletions.value,
    };
  });
}

/// Get data about a line in a hunk of a patch.
Pointer<git_diff_line> lines({
  required Pointer<git_patch> patchPointer,
  required int hunkIndex,
  required int lineOfHunk,
}) {
  return using((arena) {
    final out = arena<Pointer<git_diff_line>>();
    final error = libgit2.git_patch_get_line_in_hunk(
      out,
      patchPointer,
      hunkIndex,
      lineOfHunk,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get the content of a patch as a single diff text.
///
/// Throws a [LibGit2Error] if error occured.
String text(Pointer<git_patch> patch) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_patch_to_buf(out, patch);
    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Get the content of a patch as bytes.
Uint8List textBytes(Pointer<git_patch> patch) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_patch_to_buf(out, patch);
    checkErrorAndThrow(error);

    final data = out.ref.ptr.cast<Uint8>().asTypedList(out.ref.size);
    final result = Uint8List.fromList(data);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Look up size of patch diff data in bytes.
///
/// This returns the raw size of the patch data. This only includes the actual
/// data from the lines of the diff, not the file or hunk headers.
///
/// If you pass `includeContext` as true, this will be the size of all of the
/// diff output; if you pass it as false, this will only include the actual
/// changed lines (as if contextLines was 0).
int size({
  required Pointer<git_patch> patchPointer,
  required bool includeContext,
  required bool includeHunkHeaders,
  required bool includeFileHeaders,
}) {
  final includeContextC = includeContext ? 1 : 0;
  final includeHunkHeadersC = includeHunkHeaders ? 1 : 0;
  final includeFileHeadersC = includeFileHeaders ? 1 : 0;

  return libgit2.git_patch_size(
    patchPointer,
    includeContextC,
    includeHunkHeadersC,
    includeFileHeadersC,
  );
}

/// Free a previously allocated patch object.
void free(Pointer<git_patch> patch) => libgit2.git_patch_free(patch);

Pointer<git_diff_options> _diffOptionsInit({
  required Arena arena,
  required int flags,
  required int contextLines,
  required int interhunkLines,
}) {
  final opts = arena<git_diff_options>();
  final error = libgit2.git_diff_options_init(opts, GIT_DIFF_OPTIONS_VERSION);
  checkErrorAndThrow(error);

  opts.ref.flags = flags;
  opts.ref.context_lines = contextLines;
  opts.ref.interhunk_lines = interhunkLines;

  return opts;
}
