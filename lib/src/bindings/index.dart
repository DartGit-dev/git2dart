import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/error.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Create an in-memory index object.
///
/// The returned index must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_index> newInMemory({git_oid_t oidType = git_oid_t.GIT_OID_SHA1}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final opts = arena<git_index_options>();
    opts.ref.version = GIT_INDEX_OPTIONS_VERSION;
    opts.ref.oid_typeAsInt = oidType.value;

    final error = libgit2.git_index_new(out, opts);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Open an index file from disk.
///
/// The returned index must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_index> open(
  String path, {
  Pointer<git_index_options>? optionsPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_index_open(
      out,
      pathC,
      optionsPointer ?? nullptr,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Read index capabilities flags.
int capabilities(Pointer<git_index> index) => libgit2.git_index_caps(index);

/// Set index capabilities flags.
///
/// If you pass [GitIndexCapability.fromOwner] for the caps, then capabilities
/// will be read from the config of the owner object, looking at
/// core.ignorecase, core.filemode, core.symlinks.
///
/// Throws a [LibGit2Error] if error occured.
void setCapabilities({
  required Pointer<git_index> indexPointer,
  required int caps,
}) {
  final error = libgit2.git_index_set_caps(indexPointer, caps);

  checkErrorAndThrow(error);
}

/// Get the full path to the index file on disk.
///
/// Returns the path to the index file, or null if the index is in-memory.
String? getPath(Pointer<git_index> index) {
  final path = libgit2.git_index_path(index);
  return path == nullptr ? null : path.toDartString();
}

/// Find the first position of any entries which point to given path in the Git
/// index.
///
/// Returns the position of the entry, or -1 if not found.
int findIndex({
  required Pointer<git_index> indexPointer,
  required String path,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);

    return libgit2.git_index_find(nullptr, indexPointer, pathC);
  });
}

/// Update the contents of an existing index object in memory by reading from
/// the hard disk.
///
/// If [force] is true, this performs a "hard" read that discards in-memory
/// changes and always reloads the on-disk index data. If there is no on-disk
/// version, the index will be cleared.
///
/// If [force] is false, this does a "soft" read that reloads the index data
/// from disk only if it has changed since the last time it was loaded. Purely
/// in-memory index data will be untouched. Be aware: if there are changes on
/// disk, unwritten in-memory changes are discarded.
void read({required Pointer<git_index> indexPointer, required bool force}) {
  final forceC = force == true ? 1 : 0;
  libgit2.git_index_read(indexPointer, forceC);
}

/// Read a tree into the index file with stats.
///
/// The current index contents will be replaced by the specified tree.
void readTree({
  required Pointer<git_index> indexPointer,
  required Pointer<git_tree> treePointer,
}) => libgit2.git_index_read_tree(indexPointer, treePointer);

/// Write the index as a tree.
///
/// This method will scan the index and write a representation of its current
/// state back to disk; it recursively creates tree objects for each of the
/// subtrees stored in the index, but only returns the OID of the root tree.
/// This is the OID that can be used e.g. to create a commit.
///
/// The index instance cannot be bare, and needs to be associated to an
/// existing repository.
///
/// The index must not contain any file in conflict.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> writeTree(Pointer<git_index> index) {
  final out = calloc<git_oid>();
  final error = libgit2.git_index_write_tree(out, index);

  checkErrorAndThrow(error);

  return out;
}

/// Write the index as a tree to the given repository.
///
/// This method will do the same as [writeTree], but letting the user choose
/// the repository where the tree will be written.
///
/// The index must not contain any file in conflict.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> writeTreeTo({
  required Pointer<git_index> indexPointer,
  required Pointer<git_repository> repoPointer,
}) {
  final out = calloc<git_oid>();
  final error = libgit2.git_index_write_tree_to(out, indexPointer, repoPointer);

  checkErrorAndThrow(error);

  return out;
}

/// Get the count of entries currently in the index.
int entryCount(Pointer<git_index> index) => libgit2.git_index_entrycount(index);

/// Get a pointer to one of the entries in the index based on position.
///
/// The entry is not modifiable and should not be freed.
///
/// Throws [Git2DartError] when provided index is outside of valid range.
Pointer<git_index_entry> getByIndex({
  required Pointer<git_index> indexPointer,
  required int position,
}) {
  final result = libgit2.git_index_get_byindex(indexPointer, position);

  if (result == nullptr) {
    throw Git2DartError('Out of bounds');
  } else {
    return result;
  }
}

/// Get a pointer to one of the entries in the index based on path.
///
/// The entry is not modifiable and should not be freed.
///
/// Throws [ArgumentError] if nothing found for provided path.
Pointer<git_index_entry> getByPath({
  required Pointer<git_index> indexPointer,
  required String path,
  required int stage,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    final result = libgit2.git_index_get_bypath(indexPointer, pathC, stage);

    if (result == nullptr) {
      throw ArgumentError.value('$path was not found');
    } else {
      return result;
    }
  });
}

/// Return the stage number from a git index entry.
int entryStage(Pointer<git_index_entry> entry) =>
    libgit2.git_index_entry_stage(entry);

/// Clear the contents (all the entries) of an index object.
///
/// This clears the index object in memory; changes must be explicitly written
/// to disk for them to take effect persistently.
///
/// Throws a [LibGit2Error] if error occured.
void clear(Pointer<git_index> index) {
  final error = libgit2.git_index_clear(index);

  checkErrorAndThrow(error);
}

/// Add or update an index entry from an in-memory struct.
///
/// If a previous index entry exists that has the same path and stage as the
/// given `sourceEntry`, it will be replaced. Otherwise, the `sourceEntry` will
/// be added.
///
/// Throws a [LibGit2Error] if error occured.
void add({
  required Pointer<git_index> indexPointer,
  required Pointer<git_index_entry> sourceEntryPointer,
}) {
  final error = libgit2.git_index_add(indexPointer, sourceEntryPointer);

  checkErrorAndThrow(error);
}

/// Add or update an index entry from a file on disk.
///
/// The file [path] must be relative to the repository's working folder and must
/// be readable.
///
/// This method will fail in bare index instances.
///
/// This forces the file to be added to the index, not looking at gitignore
/// rules.
///
/// If this file currently is the result of a merge conflict, this file will no
/// longer be marked as conflicting. The data about the conflict will be moved
/// to the "resolve undo" (REUC) section.
///
/// Throws a [LibGit2Error] if error occured.
void addByPath({
  required Pointer<git_index> indexPointer,
  required String path,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_index_add_bypath(indexPointer, pathC);

    checkErrorAndThrow(error);
  });
}

/// Add or update an index entry from a buffer in memory.
///
/// This method will create a blob in the repository that owns the index and
/// then add the index entry to the index. The path of the entry represents the
/// position of the blob relative to the repository's root folder.
///
/// If a previous index entry exists that has the same path as the given
/// 'entry', it will be replaced. Otherwise, the 'entry' will be added.
///
/// This forces the file to be added to the index, not looking at gitignore
/// rules.
///
/// If this file currently is the result of a merge conflict, this file will no
/// longer be marked as conflicting. The data about the conflict will be moved
/// to the "resolve undo" (REUC) section.
///
/// Throws a [LibGit2Error] if error occured.
void addFromBuffer({
  required Pointer<git_index> indexPointer,
  required Pointer<git_index_entry> entryPointer,
  required String buffer,
}) {
  return using((arena) {
    final bufferC = buffer.toChar(arena);
    final error = libgit2.git_index_add_from_buffer(
      indexPointer,
      entryPointer,
      bufferC.cast(),
      buffer.length,
    );

    checkErrorAndThrow(error);
  });
}

/// Add or update index entries matching files in the working directory.
///
/// This method will add all files in the working directory that match the given
/// [pathspec] to the index. If [pathspec] is null, all files will be added.
///
/// This method will respect gitignore rules.
///
/// Throws a [LibGit2Error] if error occurred.
void addAll({
  required Pointer<git_index> indexPointer,
  required Pointer<git_strarray> pathspec,
  required int flags,
  required git_index_matched_path_cb callback,
  required Pointer<Void> payload,
}) {
  final error = libgit2.git_index_add_all(
    indexPointer,
    pathspec,
    flags,
    callback,
    payload,
  );

  checkErrorAndThrow(error);
}

/// Update all index entries to match the working directory.
///
/// This method will update all files in the working directory that match the
/// given [pathspec] to the index. If [pathspec] is null, all files will be
/// updated.
///
/// This method will respect gitignore rules.
///
/// Throws a [LibGit2Error] if error occurred.
void updateAll({
  required Pointer<git_index> indexPointer,
  required Pointer<git_strarray> pathspec,
  required git_index_matched_path_cb callback,
  required Pointer<Void> payload,
}) {
  final error = libgit2.git_index_update_all(
    indexPointer,
    pathspec,
    callback,
    payload,
  );

  checkErrorAndThrow(error);
}

/// Write an existing index object from memory back to disk using an atomic
/// file lock.
void write(Pointer<git_index> index) => libgit2.git_index_write(index);

/// Remove an entry from the index.
///
/// Throws a [LibGit2Error] if error occured.
void remove({
  required Pointer<git_index> indexPointer,
  required String path,
  required int stage,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_index_remove(indexPointer, pathC, stage);

    checkErrorAndThrow(error);
  });
}

/// Remove an index entry corresponding to a file on disk.
///
/// The file [path] must be relative to the repository's working folder.
///
/// This method will fail in bare index instances.
///
/// If this file currently is the result of a merge conflict, this file will no
/// longer be marked as conflicting. The data about the conflict will be moved
/// to the "resolve undo" (REUC) section.
///
/// Throws a [LibGit2Error] if error occurred.
void removeByPath({
  required Pointer<git_index> indexPointer,
  required String path,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_index_remove_bypath(indexPointer, pathC);

    checkErrorAndThrow(error);
  });
}

/// Remove all entries from the index under a given directory.
///
/// The [dir] path must be relative to the repository's working folder.
///
/// This method will fail in bare index instances.
///
/// Throws a [LibGit2Error] if error occurred.
void removeDirectory({
  required Pointer<git_index> indexPointer,
  required String dir,
  required int stage,
}) {
  return using((arena) {
    final dirC = dir.toChar(arena);
    final error = libgit2.git_index_remove_directory(indexPointer, dirC, stage);

    checkErrorAndThrow(error);
  });
}

/// Remove all matching index entries.
///
/// If [pathspec] is null, all files will be removed.
///
/// Throws a [LibGit2Error] if error occurred.
void removeAll({
  required Pointer<git_index> indexPointer,
  required Pointer<git_strarray> pathspec,
  required git_index_matched_path_cb callback,
  required Pointer<Void> payload,
}) {
  final error = libgit2.git_index_remove_all(
    indexPointer,
    pathspec,
    callback,
    payload,
  );

  checkErrorAndThrow(error);
}

/// Update the contents of an index entry in the index from a file on disk.
///
/// The file [path] must be relative to the repository's working folder.
///
/// This method will fail in bare index instances.
///
/// Throws a [LibGit2Error] if error occurred.
void updateByPath({
  required Pointer<git_index> indexPointer,
  required String path,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_index_add_bypath(indexPointer, pathC);

    checkErrorAndThrow(error);
  });
}

// /// Update the contents of an index entry in the index from a buffer in memory.
// ///
// /// This method will create a blob in the repository that owns the index and
// /// then update the index entry to point to the new blob.
// ///
// /// Throws a [LibGit2Error] if error occurred.
// void updateByBuffer({
//   required Pointer<git_index> indexPointer,
//   required Pointer<git_index_entry> entry,
//   required Pointer<Void> buffer,
//   required int len,
// }) {
//   final error = libgit2.git_index_add_frombuffer(
//     indexPointer,
//     entry,
//     buffer,
//     len,
//   );

//   checkErrorAndThrow(error);
// }

/// Determine if the index contains entries representing file conflicts.
bool hasConflicts(Pointer<git_index> index) =>
    libgit2.git_index_has_conflicts(index) == 1 || false;

/// Return list of conflicts in the index.
///
/// Throws a [LibGit2Error] if error occured.
List<Map<String, Pointer<git_index_entry>>> conflictList(
  Pointer<git_index> index,
) {
  return using((arena) {
    final iterator = arena<Pointer<git_index_conflict_iterator>>();
    final error = libgit2.git_index_conflict_iterator_new(iterator, index);
    checkErrorAndThrow(error);

    final result = <Map<String, Pointer<git_index_entry>>>[];
    var nextError = 0;

    while (nextError >= 0) {
      final ancestorOut = arena<Pointer<git_index_entry>>();
      final ourOut = arena<Pointer<git_index_entry>>();
      final theirOut = arena<Pointer<git_index_entry>>();
      nextError = libgit2.git_index_conflict_next(
        ancestorOut,
        ourOut,
        theirOut,
        iterator.value,
      );
      if (nextError >= 0) {
        result.add({
          'ancestor': ancestorOut.value,
          'our': ourOut.value,
          'their': theirOut.value,
        });
      } else {
        break;
      }
    }

    libgit2.git_index_conflict_iterator_free(iterator.value);
    return result;
  });
}

/// Return whether the given index entry is a conflict (has a high stage entry).
/// This is simply shorthand for [entryStage] > 0.
bool entryIsConflict(Pointer<git_index_entry> entry) =>
    libgit2.git_index_entry_is_conflict(entry) == 1 || false;

/// Add or update index entries to represent a conflict. Any staged entries
/// that exist at the given paths will be removed.
///
/// The entries are the entries from the tree included in the merge. Any entry
/// may be null to indicate that that file was not present in the trees during
/// the merge. For example, [ancestorEntryPointer] may be null to indicate that
/// a file was added in both branches and must be resolved.
///
/// Throws a [LibGit2Error] if error occured.
void conflictAdd({
  required Pointer<git_index> indexPointer,
  Pointer<git_index_entry>? ancestorEntryPointer,
  Pointer<git_index_entry>? ourEntryPointer,
  Pointer<git_index_entry>? theirEntryPointer,
}) {
  final error = libgit2.git_index_conflict_add(
    indexPointer,
    ancestorEntryPointer ?? nullptr,
    ourEntryPointer ?? nullptr,
    theirEntryPointer ?? nullptr,
  );

  checkErrorAndThrow(error);
}

/// Removes the index entries that represent a conflict of a single file.
///
/// Throws a [LibGit2Error] if error occured.
void conflictRemove({
  required Pointer<git_index> indexPointer,
  required String path,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_index_conflict_remove(indexPointer, pathC);

    checkErrorAndThrow(error);
  });
}

/// Remove all conflicts in the index (entries with a stage greater than 0).
///
/// Throws a [LibGit2Error] if error occured.
void conflictCleanup(Pointer<git_index> index) {
  final error = libgit2.git_index_conflict_cleanup(index);

  checkErrorAndThrow(error);
}

/// Free an existing index object.
void free(Pointer<git_index> index) => libgit2.git_index_free(index);

/// Find the first position of any entries which point to given path in the index.
///
/// Returns the index of the first matching entry, or -1 if not found.
int findPrefix({
  required Pointer<Size> size,
  required Pointer<git_index> indexPointer,
  required String prefix,
}) {
  return using((arena) {
    final prefixC = prefix.toChar(arena);
    return libgit2.git_index_find_prefix(size, indexPointer, prefixC);
  });
}

/// Get the repository that owns this index.
///
/// Returns the repository that owns this index, or null if the index is not
/// associated with a repository.
Pointer<git_repository>? getOwner(Pointer<git_index> index) =>
    libgit2.git_index_owner(index);

/// Get the checksum of the index file.
///
/// Returns the checksum of the index file, or null if the index is in-memory.
Pointer<git_oid>? getChecksum(Pointer<git_index> index) =>
    libgit2.git_index_checksum(index);

/// Get the version of the index file.
///
/// Returns the version of the index file.
int getVersion(Pointer<git_index> index) => libgit2.git_index_version(index);

/// Set the version of the index file.
///
/// This can be used to override the default version of the index file.
///
/// Throws a [LibGit2Error] if error occurred.
void setVersion({
  required Pointer<git_index> indexPointer,
  required int version,
}) {
  final error = libgit2.git_index_set_version(indexPointer, version);

  checkErrorAndThrow(error);
}
