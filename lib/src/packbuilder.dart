import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/packbuilder.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A packbuilder is used to create packfiles from a set of objects.
///
/// The packbuilder allows you to create packfiles by adding objects one by one
/// or recursively, and then writing them to disk. It's particularly useful for
/// creating packfiles for pushing to remotes or creating backups.
class PackBuilder {
  /// Initializes a new instance of [PackBuilder] class.
  ///
  /// The packbuilder allows you to create packfiles by adding objects one by one
  /// or recursively, and then writing them to disk.
  ///
  /// Throws a [LibGit2Error] if initialization fails.
  ///
  /// Note: For internal use.
  @internal
  PackBuilder(Repository repo) {
    _packbuilderPointer = Packbuilder.init(repo.pointer);
    _finalizer.attach(this, _packbuilderPointer, detach: this);
  }

  /// Pointer to memory address for allocated packbuilder object.
  late final Pointer<git_packbuilder> _packbuilderPointer;

  /// Adds a single object to the packbuilder.
  ///
  /// For optimal pack creation, objects should be added in recency order:
  /// commits followed by trees and blobs.
  ///
  /// Throws a [LibGit2Error] if the object cannot be added.
  void add(Oid oid) {
    Packbuilder.add(
      packbuilderPointer: _packbuilderPointer,
      oidPointer: oid.pointer,
    );
  }

  /// Recursively adds an object and all its referenced objects.
  ///
  /// This will add the specified object as well as any objects it references.
  /// For example, adding a commit will also add its tree and all blobs.
  ///
  /// Throws a [LibGit2Error] if any object cannot be added.
  void addRecursively(Oid oid) {
    Packbuilder.addRecursively(
      packbuilderPointer: _packbuilderPointer,
      oidPointer: oid.pointer,
    );
  }

  /// Adds a commit object and its complete tree.
  ///
  /// This will add the commit as well as the complete tree it references,
  /// including all subtrees and blobs.
  ///
  /// Throws a [LibGit2Error] if the commit cannot be added.
  void addCommit(Oid oid) {
    Packbuilder.addCommit(
      packbuilderPointer: _packbuilderPointer,
      oidPointer: oid.pointer,
    );
  }

  /// Adds a root tree object and all its contents.
  ///
  /// This will add the tree as well as all referenced trees and blobs.
  ///
  /// Throws a [LibGit2Error] if the tree cannot be added.
  void addTree(Oid oid) {
    Packbuilder.addTree(
      packbuilderPointer: _packbuilderPointer,
      oidPointer: oid.pointer,
    );
  }

  /// Adds objects as given by the walker.
  ///
  /// This will add all commits from the walker and all objects they reference.
  ///
  /// Throws a [LibGit2Error] if any object cannot be added.
  void addWalk(RevWalk walker) {
    Packbuilder.addWalk(
      packbuilderPointer: _packbuilderPointer,
      walkerPointer: walker.pointer,
    );
  }

  /// Writes the new pack and corresponding index file to the specified path.
  ///
  /// If [path] is null, writes to the repository's objects directory.
  ///
  /// Throws a [LibGit2Error] if the pack cannot be written.
  void write(String? path) {
    Packbuilder.write(packbuilderPointer: _packbuilderPointer, path: path);
  }

  /// Total number of objects the packbuilder will write out.
  int get length => Packbuilder.length(_packbuilderPointer);

  /// Number of objects the packbuilder has already written out.
  int get writtenLength => Packbuilder.writtenCount(_packbuilderPointer);

  /// Unique name for the resulting packfile.
  ///
  /// The packfile's name is derived from the packfile's content. This is only
  /// correct after the packfile has been written.
  String get name => Packbuilder.name(_packbuilderPointer);

  /// Sets and returns the number of threads to spawn.
  ///
  /// By default, libgit2 won't spawn any threads at all. When set to 0,
  /// libgit2 will autodetect the number of CPUs.
  int setThreads(int number) {
    return Packbuilder.setThreads(
      packbuilderPointer: _packbuilderPointer,
      number: number,
    );
  }

  /// Releases memory allocated for packbuilder object.
  void free() {
    Packbuilder.free(_packbuilderPointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'PackBuilder{length: $length, writtenLength: $writtenLength}';
  }
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_packbuilder>>(
  (pointer) => Packbuilder.free(pointer),
);
// coverage:ignore-end
