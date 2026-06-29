import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/tree.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A Tree object represents a Git tree, which is a hierarchical structure that
/// represents the state of a directory in a Git repository at a particular point in time.
///
/// Trees contain entries that point to other trees (subdirectories) or blobs (files).
/// Each entry has a name, mode (file permissions), and an OID pointing to the actual object.
///
/// This class provides methods to:
/// - Look up trees by OID
/// - Access tree entries by index, name, or path
/// - Get tree metadata like OID and entry count
/// - Navigate the tree structure
@immutable
class Tree extends Equatable {
  /// Initializes a new instance of [Tree] class from provided pointer to
  /// tree object in memory.
  ///
  /// Note: For internal use. Use [Tree.lookup] instead.
  @internal
  Tree(this._treePointer) {
    _finalizer.attach(this, _treePointer, detach: this);
  }

  /// Lookups a tree object for provided [oid] in a [repo]sitory.
  ///
  /// This method retrieves a tree object from the repository using its OID.
  /// The tree object must be freed when no longer needed.
  ///
  /// Throws [LibGit2Error] if the tree cannot be found or if an error occurs.
  Tree.lookup({required Repository repo, required Oid oid}) {
    _treePointer = bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: oid.pointer,
    );
    _finalizer.attach(this, _treePointer, detach: this);
  }

  /// Lookups a tree object by an abbreviated [oid].
  ///
  /// [length] is the number of hexadecimal characters to use from [oid].
  /// Throws [LibGit2Error] if the prefix is invalid, ambiguous, or not found.
  Tree.lookupPrefix({
    required Repository repo,
    required Oid oid,
    required int length,
  }) {
    _treePointer = bindings.lookupPrefix(
      repoPointer: repo.pointer,
      oidPointer: oid.pointer,
      length: length,
    );
    _finalizer.attach(this, _treePointer, detach: this);
  }

  /// Creates a tree from [baseline] with [updates] applied.
  Tree.createUpdated({
    required Repository repo,
    required Tree baseline,
    required List<TreeUpdate> updates,
  }) {
    _treePointer = bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: bindings.createUpdated(
        repoPointer: repo.pointer,
        baselinePointer: baseline.pointer,
        updates: [
          for (final update in updates)
            bindings.TreeUpdate(
              action:
                  update.oid == null
                      ? git_tree_update_t.GIT_TREE_UPDATE_REMOVE
                      : git_tree_update_t.GIT_TREE_UPDATE_UPSERT,
              path: update.path,
              oidPointer: update.oid?.pointer,
              filemode:
                  update.filemode == null
                      ? null
                      : git_filemode_t.fromValue(update.filemode!.value),
            ),
        ],
      ),
    );
    _finalizer.attach(this, _treePointer, detach: this);
  }

  late final Pointer<git_tree> _treePointer;

  /// Pointer to memory address for allocated tree object.
  ///
  /// Note: For internal use.
  @internal
  Pointer<git_tree> get pointer => _treePointer;

  /// List with tree entries of a tree.
  ///
  /// Returns a list of all entries in the tree, including files and subdirectories.
  /// Each entry contains information about the object it points to (OID, name, and file mode).
  List<TreeEntry> get entries {
    final entryCount = bindings.entryCount(_treePointer);
    return <TreeEntry>[
      for (var i = 0; i < entryCount; i++)
        TreeEntry(bindings.getByIndex(treePointer: _treePointer, index: i)),
    ];
  }

  /// Lookups a tree entry in the tree.
  ///
  /// The lookup can be done in three ways:
  /// - By index: Provide an integer [value] to get the entry at that position
  /// - By filename: Provide a string [value] to get the entry with that name
  /// - By path: Provide a string [value] containing a path to get the entry at that path
  ///
  /// Throws [ArgumentError] if provided [value] is not int or string.
  /// Throws [RangeError] if index is out of bounds.
  /// Throws [LibGit2Error] if path lookup fails.
  TreeEntry operator [](Object value) {
    if (value is int) {
      return TreeEntry(
        bindings.getByIndex(treePointer: _treePointer, index: value),
      );
    } else if (value is String && value.contains('/')) {
      return TreeEntry._byPath(
        bindings.getByPath(rootPointer: _treePointer, path: value),
      );
    } else if (value is String) {
      return TreeEntry(
        bindings.getByName(treePointer: _treePointer, filename: value),
      );
    } else {
      throw ArgumentError.value(
        '$value should be either index position, filename or path',
      );
    }
  }

  /// Looks up a tree entry by object [oid].
  TreeEntry entryByOid(Oid oid) {
    return TreeEntry(
      bindings.getById(treePointer: _treePointer, oidPointer: oid.pointer),
    );
  }

  /// [Oid] of a tree.
  ///
  /// Returns the OID (Object ID) of this tree object.
  Oid get oid => Oid(bindings.id(_treePointer));

  /// Number of entries listed in a tree.
  ///
  /// Returns the total count of entries (files and subdirectories) in this tree.
  int get length => bindings.entryCount(_treePointer);

  /// Walks this tree and returns relative entry paths.
  List<String> walk({GitTreeWalk mode = GitTreeWalk.pre}) {
    return bindings.walk(
      treePointer: _treePointer,
      mode: git_treewalk_mode.fromValue(mode.value),
    );
  }

  /// Releases memory allocated for tree object.
  ///
  /// This method should be called when the tree object is no longer needed
  /// to prevent memory leaks.
  void free() {
    bindings.free(_treePointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'Tree{oid: $oid, length: $length}';
  }

  @override
  List<Object?> get props => [oid];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_tree>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end

/// A change to apply when creating a tree from a baseline tree.
@immutable
class TreeUpdate extends Equatable {
  /// Adds or replaces [path] with [oid] and [filemode].
  const TreeUpdate.upsert({
    required this.path,
    required this.oid,
    required this.filemode,
  });

  /// Removes [path].
  const TreeUpdate.remove(this.path) : oid = null, filemode = null;

  /// Full path from the root tree.
  final String path;

  /// Object id to write for an upsert.
  final Oid? oid;

  /// File mode to write for an upsert.
  final GitFilemode? filemode;

  @override
  List<Object?> get props => [path, oid, filemode];
}

/// A TreeEntry represents a single entry in a Git tree, which can be either
/// a file (blob) or a subdirectory (tree).
///
/// Each entry contains:
/// - An OID pointing to the actual object (blob or tree)
/// - A name (filename or directory name)
/// - A file mode (permissions and type)
@immutable
class TreeEntry extends Equatable {
  /// Initializes a new instance of [TreeEntry] class from provided pointer to
  /// tree entry object in memory.
  ///
  /// Note: For internal use.
  @internal
  const TreeEntry(this._treeEntryPointer);

  /// Initializes a new instance of [TreeEntry] class from provided pointer to
  /// tree entry object in memory.
  ///
  /// Unlike the other lookup methods, must be freed.
  TreeEntry._byPath(this._treeEntryPointer) {
    _entryFinalizer.attach(this, _treeEntryPointer, detach: this);
  }

  /// Pointer to memory address for allocated tree entry object.
  final Pointer<git_tree_entry> _treeEntryPointer;

  /// [Oid] of the object pointed by the entry.
  ///
  /// Returns the OID of the blob or tree that this entry points to.
  Oid get oid => Oid(bindings.entryId(_treeEntryPointer));

  /// Filename of a tree entry.
  ///
  /// Returns the name of the file or directory represented by this entry.
  String get name => bindings.entryName(_treeEntryPointer);

  /// UNIX file attributes of a tree entry.
  ///
  /// Returns the file mode which includes:
  /// - File permissions (read, write, execute)
  /// - File type (regular file, directory, symlink, etc.)
  GitFilemode get filemode {
    final modeInt = bindings.entryFilemode(_treeEntryPointer);
    return GitFilemode.fromValue(modeInt.value);
  }

  /// Raw UNIX file attributes of this tree entry.
  GitFilemode get filemodeRaw {
    final modeInt = bindings.entryFilemodeRaw(_treeEntryPointer);
    return GitFilemode.fromValue(modeInt.value);
  }

  /// Git object type pointed to by this tree entry.
  GitObject get type {
    final type = bindings.entryType(_treeEntryPointer);
    return GitObject.fromValue(type.value);
  }

  /// Converts this tree entry to the object it points to.
  Object toObject(Repository repo) {
    final type = bindings.entryType(_treeEntryPointer);
    final object = bindings.entryToObject(
      repoPointer: repo.pointer,
      entryPointer: _treeEntryPointer,
    );

    if (type.value == GitObject.commit.value) {
      return Commit(object.cast());
    } else if (type.value == GitObject.tree.value) {
      return Tree(object.cast());
    } else if (type.value == GitObject.blob.value) {
      return Blob(object.cast());
    } else if (type.value == GitObject.tag.value) {
      return Tag(object.cast());
    } else {
      throw ArgumentError('Unsupported tree entry target type: ${type.value}');
    }
  }

  /// Compares this tree entry with [other] for tree ordering.
  int compareTo(TreeEntry other) {
    return bindings.entryCompare(
      aPointer: _treeEntryPointer,
      bPointer: other._treeEntryPointer,
    );
  }

  /// Releases memory allocated for tree entry object.
  ///
  /// **IMPORTANT**: Only tree entries looked up by path should be freed.
  /// Other entries are owned by their parent tree and will be freed automatically.
  void free() {
    bindings.freeEntry(_treeEntryPointer);
    _entryFinalizer.detach(this);
  }

  @override
  String toString() => 'TreeEntry{oid: $oid, name: $name, filemode: $filemode}';

  @override
  List<Object?> get props => [oid, name, filemode];
}

// coverage:ignore-start
final _entryFinalizer = Finalizer<Pointer<git_tree_entry>>(
  (pointer) => bindings.freeEntry(pointer),
);
// coverage:ignore-end
