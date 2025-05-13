import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/treebuilder.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A class for constructing or modifying tree objects.
///
/// This class provides functionality to create new trees or modify existing ones
/// by adding, removing, or updating entries. Each entry in a tree represents either
/// a file (blob) or a directory (tree) with associated metadata like name, mode,
/// and object ID.
///
/// The class supports operations to:
/// - Create a new tree builder from scratch or based on an existing tree
/// - Add or update entries with specific file modes and object IDs
/// - Remove entries by name
/// - Write the final tree object to the repository
class TreeBuilder {
  /// Initializes a new instance of [TreeBuilder] class from provided
  /// [repo]sitory and optional [tree] objects.
  ///
  /// If [tree] is provided, the builder will be initialized with its entries.
  /// If [tree] is null, the builder will start empty.
  ///
  /// Throws a [LibGit2Error] if error occurred while creating the tree builder.
  TreeBuilder({required Repository repo, Tree? tree}) {
    _treeBuilderPointer = bindings.create(
      repo.pointer,
      tree?.pointer ?? nullptr,
    );
    _finalizer.attach(this, _treeBuilderPointer, detach: this);
  }

  /// Pointer to memory address for allocated tree builder object.
  late final Pointer<git_treebuilder> _treeBuilderPointer;

  /// Number of entries listed in a tree builder.
  ///
  /// Returns the total count of entries currently in the builder.
  int get length => bindings.entryCount(_treeBuilderPointer);

  /// Writes the contents of the tree builder as a tree object.
  ///
  /// This method creates a new tree object in the repository containing all
  /// the entries in the builder.
  ///
  /// Returns the [Oid] of the newly written tree object.
  ///
  /// Throws a [LibGit2Error] if error occurred while writing the tree.
  Oid write() => Oid(bindings.write(_treeBuilderPointer));

  /// Clears all the entries in the tree builder.
  ///
  /// After this call, the builder will be empty regardless of its previous contents.
  void clear() => bindings.clear(_treeBuilderPointer);

  /// Returns an entry from the tree builder with provided [filename].
  ///
  /// Throws [ArgumentError] if nothing found for provided [filename].
  TreeEntry operator [](String filename) => TreeEntry(
    bindings.getByFilename(
      builderPointer: _treeBuilderPointer,
      filename: filename,
    ),
  );

  /// Adds or updates an entry to the tree builder with the given attributes.
  ///
  /// If an entry with [filename] already exists, its attributes will be
  /// updated with the given ones.
  ///
  /// By default the entry that you are inserting will be checked for validity;
  /// that it exists in the object database and is of the correct type.
  ///
  /// Parameters:
  /// - [filename] is the filename of the entry
  /// - [oid] is [Oid] of the entry
  /// - [filemode] is one of the [GitFilemode] values:
  ///   - [GitFilemode.tree] for directories
  ///   - [GitFilemode.blob] for regular files
  ///   - [GitFilemode.blobExecutable] for executable files
  ///   - [GitFilemode.link] for symbolic links
  ///   - [GitFilemode.commit] for submodules
  ///
  /// Throws a [LibGit2Error] if error occurred while adding the entry.
  void add({
    required String filename,
    required Oid oid,
    required GitFilemode filemode,
  }) {
    bindings.add(
      builderPointer: _treeBuilderPointer,
      filename: filename,
      oidPointer: oid.pointer,
      filemode: git_filemode_t.fromValue(filemode.value),
    );
  }

  /// Removes an entry from the tree builder by its [filename].
  ///
  /// If the entry does not exist, this method will still succeed.
  ///
  /// Throws a [LibGit2Error] if error occurred while removing the entry.
  void remove(String filename) =>
      bindings.remove(builderPointer: _treeBuilderPointer, filename: filename);

  /// Releases memory allocated for tree builder object and all the entries.
  ///
  /// After calling this method, the builder should not be used anymore.
  void free() {
    bindings.free(_treeBuilderPointer);
    _finalizer.detach(this);
  }

  @override
  String toString() => 'TreeBuilder{length: $length}';
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_treebuilder>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
