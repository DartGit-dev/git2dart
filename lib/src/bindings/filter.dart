import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Apply a filter list to an arbitrary data buffer.
///
/// The returned buffer must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
String applyToData({
  required Pointer<git_filter_list> filterListPointer,
  required String buffer,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final bufferC = buffer.toChar(arena);
    final error = libgit2.git_filter_list_apply_to_buffer(
      out,
      filterListPointer,
      bufferC,
      buffer.length,
    );

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);

    return result;
  });
}

/// Apply a filter list to a file on disk.
///
/// The returned buffer must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
String applyToFile({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_filter_list> filterListPointer,
  required String path,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_filter_list_apply_to_file(
      out,
      filterListPointer,
      repoPointer,
      pathC,
    );

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);

    return result;
  });
}

/// Apply a filter list to a blob.
///
/// The returned buffer must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
String applyToBlob({
  required Pointer<git_filter_list> filterListPointer,
  required Pointer<git_blob> blobPointer,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_filter_list_apply_to_blob(
      out,
      filterListPointer,
      blobPointer,
    );

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);

    return result;
  });
}

/// Load the filter list for a given file path.
Pointer<git_filter_list> load({
  required Pointer<git_repository> repoPointer,
  Pointer<git_blob>? blobPointer,
  required String path,
  required git_filter_mode_t mode,
  required int flags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_filter_list>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_filter_list_load(
      out,
      repoPointer,
      blobPointer ?? nullptr,
      pathC,
      mode,
      flags,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Load the filter list with extended options.
Pointer<git_filter_list> loadExt({
  required Pointer<git_repository> repoPointer,
  Pointer<git_blob>? blobPointer,
  required String path,
  required git_filter_mode_t mode,
  required Pointer<git_filter_options> options,
}) {
  return using((arena) {
    final out = arena<Pointer<git_filter_list>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_filter_list_load_ext(
      out,
      repoPointer,
      blobPointer ?? nullptr,
      pathC,
      mode,
      options,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Query whether a given filter will run.
bool contains({
  required Pointer<git_filter_list> filterListPointer,
  required String name,
}) {
  return using((arena) {
    final nameC = name.toChar(arena);
    final result = libgit2.git_filter_list_contains(filterListPointer, nameC);
    return result == 1;
  });
}

/// Free a filter list.
void free(Pointer<git_filter_list> filterList) =>
    libgit2.git_filter_list_free(filterList);
