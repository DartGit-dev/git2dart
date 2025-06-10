import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Create a new tree builder. The returned tree builder must be freed with
/// [free].
///
/// The tree builder can be used to create or modify trees in memory and write
/// them as tree objects to the database.
///
/// If [sourcePointer] is provided, the tree builder will be initialized with
/// the entries of the given tree.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_treebuilder> create(
  Pointer<git_repository> repoPointer,
  Pointer<git_tree> source,
) {
  return using((arena) {
    final out = arena<Pointer<git_treebuilder>>();
    final error = libgit2.git_treebuilder_new(out, repoPointer, source);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Write the contents of the tree builder as a tree object.
///
/// The tree builder will write a new tree object to the object database
/// containing all the entries in the tree.
///
/// Returns a pointer to the OID of the newly written tree object.
Pointer<git_oid> write(Pointer<git_treebuilder> bld) {
  final out = calloc<git_oid>();
  libgit2.git_treebuilder_write(out, bld);
  return out;
}

/// Clear all the entries in the builder.
///
/// This will clear all the entries in the tree builder, making it empty.
void clear(Pointer<git_treebuilder> bld) => libgit2.git_treebuilder_clear(bld);

/// Get the number of entries listed in a treebuilder.
///
/// Returns the number of entries in the tree builder.
int entryCount(Pointer<git_treebuilder> bld) =>
    libgit2.git_treebuilder_entrycount(bld);

/// Get a tree entry from the builder by its filename.
///
/// This returns a tree entry that is owned by the builder. You don't have to
/// free it, but you must not use it after the builder is released.
///
/// Throws [ArgumentError] if nothing found for provided filename.
Pointer<git_tree_entry> getByFilename({
  required Pointer<git_treebuilder> builderPointer,
  required String filename,
}) {
  return using((arena) {
    final filenameC = filename.toChar(arena);
    final result = libgit2.git_treebuilder_get(builderPointer, filenameC);

    if (result == nullptr) {
      throw ArgumentError.value('$filename was not found');
    } else {
      return result;
    }
  });
}

/// Add or update an entry to the builder.
///
/// Insert a new entry for filename in the builder with the given attributes.
/// If an entry named filename already exists, its attributes will be updated
/// with the given ones.
///
/// By default the entry that you are inserting will be checked for validity;
/// that it exists in the object database and is of the correct type.
///
/// Throws a [LibGit2Error] if error occurred.
void add({
  required Pointer<git_treebuilder> builderPointer,
  required String filename,
  required Pointer<git_oid> oidPointer,
  required git_filemode_t filemode,
}) {
  using((arena) {
    final filenameC = filename.toChar(arena);
    final error = libgit2.git_treebuilder_insert(
      nullptr,
      builderPointer,
      filenameC,
      oidPointer,
      filemode,
    );
    checkErrorAndThrow(error);
  });
}

/// Remove an entry from the builder by its filename.
///
/// If the entry does not exist, this will still succeed but will do nothing.
///
/// Throws a [LibGit2Error] if error occurred.
void remove({
  required Pointer<git_treebuilder> builderPointer,
  required String filename,
}) {
  using((arena) {
    final filenameC = filename.toChar(arena);
    final error = libgit2.git_treebuilder_remove(builderPointer, filenameC);
    checkErrorAndThrow(error);
  });
}

/// Filter tree builder entries using a callback.
void filter({
  required Pointer<git_treebuilder> builderPointer,
  required int Function(Pointer<git_tree_entry> entry) predicate,
}) {
  const except = -1;
  final cb = Pointer.fromFunction<git_treebuilder_filter_cbFunction>(
    (Pointer<git_tree_entry> entry, Pointer<Void> payload) => predicate(entry),
    except,
  );
  final error = libgit2.git_treebuilder_filter(builderPointer, cb, nullptr);
  checkErrorAndThrow(error);
}

/// Free a tree builder and all the entries.
///
/// This will clear all the entries and free the builder.
void free(Pointer<git_treebuilder> bld) => libgit2.git_treebuilder_free(bld);
