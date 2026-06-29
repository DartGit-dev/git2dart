import 'dart:ffi';

import 'package:ffi/ffi.dart' show Utf8, Utf8Pointer, calloc, using;
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

var _walkEntries = <String>[];

class TreeUpdate {
  const TreeUpdate({
    required this.action,
    required this.path,
    this.oidPointer,
    this.filemode,
  });

  final git_tree_update_t action;
  final String path;
  final Pointer<git_oid>? oidPointer;
  final git_filemode_t? filemode;
}

int _walkCb(
  Pointer<Char> root,
  Pointer<git_tree_entry> entry,
  Pointer<Void> payload,
) {
  _walkEntries.add('${root.cast<Utf8>().toDartString()}${entryName(entry)}');
  return 0;
}

/// Get the id of a tree.
Pointer<git_oid> id(Pointer<git_tree> tree) => libgit2.git_tree_id(tree);

/// Get the repository that owns this tree.
Pointer<git_repository> owner(Pointer<git_tree> tree) =>
    libgit2.git_tree_owner(tree);

/// Lookup a tree object from the repository. The returned tree must be freed
/// with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_tree> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_tree>>();
    final error = libgit2.git_tree_lookup(out, repoPointer, oidPointer);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Lookup a tree object from a repository by its short [oid].
///
/// The returned tree must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_tree> lookupPrefix({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
  required int length,
}) {
  return using((arena) {
    final out = arena<Pointer<git_tree>>();
    final error = libgit2.git_tree_lookup_prefix(
      out,
      repoPointer,
      oidPointer,
      length,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Lookup a tree entry by its position in the tree.
///
/// This returns a tree entry that is owned by the tree. You don't have to free
/// it, but you must not use it after the tree is released.
///
/// Throws [RangeError] when provided index is outside of valid range.
Pointer<git_tree_entry> getByIndex({
  required Pointer<git_tree> treePointer,
  required int index,
}) {
  final result = libgit2.git_tree_entry_byindex(treePointer, index);
  if (result == nullptr) {
    throw Git2DartError('Out of bounds');
  }
  return result;
}

/// Lookup a tree entry by its filename.
///
/// This returns a tree entry that is owned by the tree. You don't have to free
/// it, but you must not use it after the tree is released.
///
/// Throws [ArgumentError] if nothing found for provided filename.
Pointer<git_tree_entry> getByName({
  required Pointer<git_tree> treePointer,
  required String filename,
}) {
  return using((arena) {
    final filenameC = filename.toChar(arena);
    final result = libgit2.git_tree_entry_byname(treePointer, filenameC);
    if (result == nullptr) {
      throw Git2DartError('$filename was not found');
    }
    return result;
  });
}

/// Lookup a tree entry by its object id.
Pointer<git_tree_entry> getById({
  required Pointer<git_tree> treePointer,
  required Pointer<git_oid> oidPointer,
}) {
  final result = libgit2.git_tree_entry_byid(treePointer, oidPointer);
  if (result == nullptr) {
    throw Git2DartError('Tree entry was not found');
  }
  return result;
}

/// Retrieve a tree entry contained in a tree or in any of its subtrees, given
/// its relative path.
///
/// Unlike the other lookup functions, the returned tree entry is owned by the
/// user and must be freed explicitly with [freeEntry].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_tree_entry> getByPath({
  required Pointer<git_tree> rootPointer,
  required String path,
}) {
  return using((arena) {
    final out = arena<Pointer<git_tree_entry>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_tree_entry_bypath(out, rootPointer, pathC);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the number of entries listed in a tree.
int entryCount(Pointer<git_tree> tree) => libgit2.git_tree_entrycount(tree);

/// Walk entries in a tree.
List<String> walk({
  required Pointer<git_tree> treePointer,
  required git_treewalk_mode mode,
}) {
  _walkEntries = <String>[];

  final error = libgit2.git_tree_walk(
    treePointer,
    mode,
    Pointer.fromFunction<
      Int Function(Pointer<Char>, Pointer<git_tree_entry>, Pointer<Void>)
    >(_walkCb, -1),
    nullptr,
  );

  checkErrorAndThrow(error);
  return List.unmodifiable(_walkEntries);
}

/// Create a tree based on another one with the specified modifications.
Pointer<git_oid> createUpdated({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree> baselinePointer,
  required List<TreeUpdate> updates,
}) {
  final out = calloc<git_oid>();

  using((arena) {
    final updatesC = arena<git_tree_update>(updates.length);

    for (var i = 0; i < updates.length; i++) {
      final update = updates[i];
      final updateC = updatesC + i;
      updateC.ref.actionAsInt = update.action.value;
      updateC.ref.path = update.path.toChar(arena);

      if (update.oidPointer != null) {
        updateC.ref.id.type = update.oidPointer!.ref.type;
        for (var j = 0; j < 32; j++) {
          updateC.ref.id.id[j] = update.oidPointer!.ref.id[j];
        }
      }

      if (update.filemode != null) {
        updateC.ref.filemodeAsInt = update.filemode!.value;
      }
    }

    final error = libgit2.git_tree_create_updated(
      out,
      repoPointer,
      baselinePointer,
      updates.length,
      updatesC,
    );

    checkErrorAndThrow(error);
  });

  return out;
}

/// Get the id of the object pointed by the entry.
Pointer<git_oid> entryId(Pointer<git_tree_entry> entry) =>
    libgit2.git_tree_entry_id(entry);

/// Duplicate a tree entry owned by the user.
Pointer<git_tree_entry> duplicateEntry(Pointer<git_tree_entry> entry) {
  return using((arena) {
    final out = arena<Pointer<git_tree_entry>>();
    final error = libgit2.git_tree_entry_dup(out, entry);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Duplicate a tree object.
Pointer<git_tree> duplicateTree(Pointer<git_tree> tree) {
  return using((arena) {
    final out = arena<Pointer<git_tree>>();
    final error = libgit2.git_tree_dup(out, tree);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the filename of a tree entry.
String entryName(Pointer<git_tree_entry> entry) =>
    libgit2.git_tree_entry_name(entry).toDartString();

/// Get the UNIX file attributes of a tree entry.
git_filemode_t entryFilemode(Pointer<git_tree_entry> entry) =>
    libgit2.git_tree_entry_filemode(entry);

/// Get the raw UNIX file attributes of a tree entry.
git_filemode_t entryFilemodeRaw(Pointer<git_tree_entry> entry) =>
    libgit2.git_tree_entry_filemode_raw(entry);

/// Get the Git object type of a tree entry.
git_object_t entryType(Pointer<git_tree_entry> entry) {
  return libgit2.git_tree_entry_type(entry);
}

/// Compare two tree entries.
int entryCompare({
  required Pointer<git_tree_entry> aPointer,
  required Pointer<git_tree_entry> bPointer,
}) {
  return libgit2.git_tree_entry_cmp(aPointer, bPointer);
}

/// Convert a tree entry to the object it points to.
///
/// The returned object must be freed.
Pointer<git_object> entryToObject({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_tree_entry> entryPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_object>>();
    final error = libgit2.git_tree_entry_to_object(
      out,
      repoPointer,
      entryPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Free a user-owned tree entry.
///
/// IMPORTANT: This function is only needed for tree entries owned by the user,
/// such as [getByPath].
void freeEntry(Pointer<git_tree_entry> entry) =>
    libgit2.git_tree_entry_free(entry);

/// Close an open tree to release memory.
void free(Pointer<git_tree> tree) => libgit2.git_tree_free(tree);
