import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A packbuilder is used to create packfiles from a set of objects.
///
/// The packbuilder allows you to create packfiles by adding objects one by one
/// or recursively, and then writing them to disk. It's particularly useful for
/// creating packfiles for pushing to remotes or creating backups.
class Packbuilder {
  /// Initialize a new packbuilder for the given repository.
  ///
  /// The returned packbuilder must be freed with [free] when no longer needed.
  ///
  /// [repo] is the repository to create the packbuilder for.
  ///
  /// Throws a [LibGit2Error] if initialization fails.
  static Pointer<git_packbuilder> init(Pointer<git_repository> repo) {
    return using((arena) {
      final out = arena<Pointer<git_packbuilder>>();
      final error = libgit2.git_packbuilder_new(out, repo);

      checkErrorAndThrow(error);

      return out.value;
    });
  }

  /// Insert a single object into the packbuilder.
  ///
  /// For optimal pack creation, objects should be inserted in recency order:
  /// commits followed by trees and blobs.
  ///
  /// [packbuilderPointer] is the packbuilder to add the object to.
  /// [oidPointer] is the OID of the object to add.
  ///
  /// Throws a [LibGit2Error] if the object cannot be added.
  static void add({
    required Pointer<git_packbuilder> packbuilderPointer,
    required Pointer<git_oid> oidPointer,
  }) {
    final error = libgit2.git_packbuilder_insert(
      packbuilderPointer,
      oidPointer,
      nullptr,
    );

    checkErrorAndThrow(error);
  }

  /// Recursively insert an object and all its referenced objects.
  ///
  /// This will add the specified object as well as any objects it references.
  /// For example, adding a commit will also add its tree and all blobs.
  ///
  /// [packbuilderPointer] is the packbuilder to add the objects to.
  /// [oidPointer] is the OID of the root object to add.
  ///
  /// Throws a [LibGit2Error] if any object cannot be added.
  static void addRecursively({
    required Pointer<git_packbuilder> packbuilderPointer,
    required Pointer<git_oid> oidPointer,
  }) {
    final error = libgit2.git_packbuilder_insert_recur(
      packbuilderPointer,
      oidPointer,
      nullptr,
    );
    checkErrorAndThrow(error);
  }

  /// Insert a commit object and its complete tree.
  ///
  /// This will add the commit as well as the complete tree it references,
  /// including all subtrees and blobs.
  ///
  /// [packbuilderPointer] is the packbuilder to add the commit to.
  /// [oidPointer] is the OID of the commit to add.
  ///
  /// Throws a [LibGit2Error] if the commit cannot be added.
  static void addCommit({
    required Pointer<git_packbuilder> packbuilderPointer,
    required Pointer<git_oid> oidPointer,
  }) {
    final error = libgit2.git_packbuilder_insert_commit(
      packbuilderPointer,
      oidPointer,
    );

    checkErrorAndThrow(error);
  }

  /// Insert a root tree object and all its contents.
  ///
  /// This will add the tree as well as all referenced trees and blobs.
  ///
  /// [packbuilderPointer] is the packbuilder to add the tree to.
  /// [oidPointer] is the OID of the root tree to add.
  ///
  /// Throws a [LibGit2Error] if the tree cannot be added.
  static void addTree({
    required Pointer<git_packbuilder> packbuilderPointer,
    required Pointer<git_oid> oidPointer,
  }) {
    final error = libgit2.git_packbuilder_insert_tree(
      packbuilderPointer,
      oidPointer,
    );

    checkErrorAndThrow(error);
  }

  /// Insert objects as given by the walk.
  ///
  /// This will add all commits from the walker and all objects they reference.
  ///
  /// [packbuilderPointer] is the packbuilder to add the objects to.
  /// [walkerPointer] is the revwalk containing the commits to add.
  ///
  /// Throws a [LibGit2Error] if any object cannot be added.
  static void addWalk({
    required Pointer<git_packbuilder> packbuilderPointer,
    required Pointer<git_revwalk> walkerPointer,
  }) {
    final error = libgit2.git_packbuilder_insert_walk(
      packbuilderPointer,
      walkerPointer,
    );

    checkErrorAndThrow(error);
  }

  /// Write the new pack and corresponding index file to the specified path.
  ///
  /// [packbuilderPointer] is the packbuilder to write.
  /// [path] is the directory to write the pack and index files to.
  ///        If null, writes to the repository's objects directory.
  ///
  /// Throws a [LibGit2Error] if the pack cannot be written.
  static void write({
    required Pointer<git_packbuilder> packbuilderPointer,
    String? path,
  }) {
    return using((arena) {
      final pathC = path?.toChar(arena) ?? nullptr;
      final error = libgit2.git_packbuilder_write(
        packbuilderPointer,
        pathC,
        0,
        nullptr,
        nullptr,
      );

      checkErrorAndThrow(error);
    });
  }

  /// Get the total number of objects the packbuilder will write out.
  ///
  /// [pb] is the packbuilder to get the count from.
  static int length(Pointer<git_packbuilder> pb) =>
      libgit2.git_packbuilder_object_count(pb);

  /// Get the number of objects the packbuilder has already written out.
  ///
  /// [pb] is the packbuilder to get the count from.
  static int writtenCount(Pointer<git_packbuilder> pb) =>
      libgit2.git_packbuilder_written(pb);

  /// Get the unique name for the resulting packfile.
  ///
  /// The packfile's name is derived from the packfile's content. This is only
  /// correct after the packfile has been written.
  ///
  /// [pb] is the packbuilder to get the name from.
  static String name(Pointer<git_packbuilder> pb) {
    final result = libgit2.git_packbuilder_name(pb);
    return result == nullptr ? '' : result.toDartString();
  }

  /// Set the number of threads to use for pack creation.
  ///
  /// By default, libgit2 won't spawn any threads at all. When set to 0,
  /// libgit2 will autodetect the number of CPUs.
  ///
  /// [packbuilderPointer] is the packbuilder to configure.
  /// [number] is the number of threads to use.
  ///
  /// Returns the number of threads that will be used.
  static int setThreads({
    required Pointer<git_packbuilder> packbuilderPointer,
    required int number,
  }) {
    return libgit2.git_packbuilder_set_threads(packbuilderPointer, number);
  }

  /// Free the packbuilder and all associated data.
  ///
  /// [pb] is the packbuilder to free.
  static void free(Pointer<git_packbuilder> pb) =>
      libgit2.git_packbuilder_free(pb);
}
