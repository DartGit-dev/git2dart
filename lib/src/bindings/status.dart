import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Gather file status information and populate the git_status_list.
///
/// This function will scan the working directory and index for changes and
/// return a list of files that have been modified, added, or deleted.
/// The returned list must be freed with [listFree].
///
/// Throws a [LibGit2Error] if an error occurs.
Pointer<git_status_list> listNew(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_status_list>>();
  final error = libgit2.git_status_list_new(out, repo, nullptr);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Gets the count of status entries in this list.
///
/// If there are no changes in status (at least according the options given when
/// the status list was created), this can return 0.
int listEntryCount(Pointer<git_status_list> statuslist) {
  return libgit2.git_status_list_entrycount(statuslist);
}

/// Get a pointer to one of the entries in the status list.
///
/// The entry is not modifiable and should not be freed.
/// Returns a pointer to the status entry at the specified index.
Pointer<git_status_entry> getByIndex({
  required Pointer<git_status_list> statuslistPointer,
  required int index,
}) {
  return libgit2.git_status_byindex(statuslistPointer, index);
}

/// Get file status for a single file.
///
/// This tries to get status for the filename that you give. If no files match
/// that name (in either the HEAD, index, or working directory), this returns
/// GIT_ENOTFOUND.
///
/// If the name matches multiple files (for example, if the path names a
/// directory or if running on a case-insensitive filesystem and yet the HEAD
/// has two entries that both match the path), then this returns GIT_EAMBIGUOUS
/// because it cannot give correct results.
///
/// This does not do any sort of rename detection. Renames require a set of
/// targets and because of the path filtering, there is not enough information
/// to check renames correctly. To check file status with rename detection,
/// there is no choice but to do a full [listNew] and scan through looking for
/// the path that you are interested in.
///
/// Throws a [LibGit2Error] if an error occurs.
int file({required Pointer<git_repository> repoPointer, required String path}) {
  final out = calloc<UnsignedInt>();
  final pathC = path.toChar();
  final error = libgit2.git_status_file(out, repoPointer, pathC);

  final result = out.value;

  calloc.free(out);
  calloc.free(pathC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Free an existing status list.
///
/// This will free all the status entries in the list.
void listFree(Pointer<git_status_list> statuslist) =>
    libgit2.git_status_list_free(statuslist);
