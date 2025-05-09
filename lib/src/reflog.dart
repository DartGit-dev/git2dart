import 'dart:collection';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/reference.dart' as reference_bindings;
import 'package:git2dart/src/bindings/reflog.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git reference log (reflog).
///
/// The reflog is a record of when the tips of branches and other references
/// were updated in the local repository. It provides a history of all changes
/// to the reference, including when it was updated and by whom.
///
/// Example:
/// ```dart
/// final ref = repository.lookupReference('refs/heads/main');
/// final reflog = RefLog(ref);
/// for (final entry in reflog) {
///   print('${entry.message} by ${entry.committer}');
/// }
/// ```
class RefLog with IterableMixin<RefLogEntry> {
  /// Initializes a new instance of [RefLog] class from provided [Reference].
  ///
  /// The reflog will be read from the repository for the given reference.
  /// If there is no reflog file for the given reference yet, an empty reflog
  /// object will be returned.
  ///
  /// Throws a [LibGit2Error] if error occurred while reading the reflog.
  RefLog(Reference ref) {
    _reflogPointer = bindings.read(
      repoPointer: reference_bindings.owner(ref.pointer),
      name: ref.name,
    );
    _finalizer.attach(this, _reflogPointer, detach: this);
  }

  /// Pointer to memory address for allocated reflog object.
  late final Pointer<git_reflog> _reflogPointer;

  /// Deletes the reflog for the given reference.
  ///
  /// This will remove the reflog file from the repository. Note that this
  /// operation cannot be undone.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  static void delete(Reference ref) {
    bindings.delete(
      repoPointer: reference_bindings.owner(ref.pointer),
      name: ref.name,
    );
  }

  /// Renames a reflog.
  ///
  /// The reflog to be renamed is expected to already exist. The new name will
  /// be checked for validity.
  ///
  /// This is useful when renaming a reference and you want to preserve its
  /// reflog history.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  static void rename({
    required Repository repo,
    required String oldName,
    required String newName,
  }) {
    bindings.rename(
      repoPointer: repo.pointer,
      oldName: oldName,
      newName: newName,
    );
  }

  /// Lookups an entry by its index.
  ///
  /// Requesting the reflog entry with an index of 0 will return the most
  /// recently created entry. The index must be within the bounds of the reflog.
  ///
  /// Throws a [LibGit2Error] if the index is out of bounds.
  RefLogEntry operator [](int index) {
    return RefLogEntry._(
      bindings.getByIndex(reflogPointer: _reflogPointer, index: index),
    );
  }

  /// Adds a new entry to the in-memory reflog.
  ///
  /// [oid] is the OID the reference is now pointing to.
  /// [committer] is the signature of the committer.
  /// [message] is optional reflog message that describes the change.
  ///
  /// Note that this only adds the entry to memory. You need to call [write]
  /// to persist the changes to disk.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void add({
    required Oid oid,
    required Signature committer,
    String message = '',
  }) {
    bindings.add(
      reflogPointer: _reflogPointer,
      oidPointer: oid.pointer,
      committerPointer: committer.pointer,
      message: message,
    );
  }

  /// Removes an entry from the reflog by its [index].
  ///
  /// The entry at the specified index will be removed from the reflog.
  /// Note that this only removes the entry from memory. You need to call [write]
  /// to persist the changes to disk.
  ///
  /// Throws a [LibGit2Error] if error occurred or if the index is out of bounds.
  void remove(int index) {
    bindings.remove(reflogPointer: _reflogPointer, index: index);
  }

  /// Writes an existing in-memory reflog object back to disk using an atomic
  /// file lock.
  ///
  /// This method persists any changes made to the reflog (like adding or
  /// removing entries) to the actual reflog file in the repository.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void write() => bindings.write(_reflogPointer);

  /// Releases memory allocated for reflog object.
  ///
  /// This method should be called when you're done with the reflog to free
  /// the allocated memory. The finalizer will automatically call this method
  /// when the reflog object is garbage collected.
  void free() {
    bindings.free(_reflogPointer);
    _finalizer.detach(this);
  }

  @override
  Iterator<RefLogEntry> get iterator => _RefLogIterator(_reflogPointer);
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_reflog>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end

/// A class representing a single entry in a Git reference log.
///
/// Each entry contains information about a change to a reference, including
/// the old and new OIDs, the committer's signature, and a message describing
/// the change.
@immutable
class RefLogEntry extends Equatable {
  /// Initializes a new instance of [RefLogEntry] class from provided
  /// pointer to RefLogEntry object in memory.
  const RefLogEntry._(this._entryPointer);

  /// Pointer to memory address for allocated reflog entry object.
  final Pointer<git_reflog_entry> _entryPointer;

  /// Log message describing the change.
  ///
  /// Returns empty string if there is no message.
  String get message => bindings.entryMessage(_entryPointer);

  /// Committer of this entry.
  ///
  /// Contains information about who made the change, including name, email,
  /// and timestamp.
  Signature get committer => Signature(bindings.entryCommiter(_entryPointer));

  /// New OID that the reference points to after this change.
  Oid get newOid => Oid(bindings.entryOidNew(_entryPointer));

  /// Old OID that the reference pointed to before this change.
  Oid get oldOid => Oid(bindings.entryOidOld(_entryPointer));

  @override
  String toString() => 'RefLogEntry{message: $message, committer: $committer}';

  @override
  List<Object?> get props => [message, committer, newOid, oldOid];
}

/// Iterator implementation for [RefLog] entries.
class _RefLogIterator implements Iterator<RefLogEntry> {
  _RefLogIterator(this._reflogPointer) {
    _count = bindings.entryCount(_reflogPointer);
  }

  /// Pointer to memory address for allocated reflog object.
  final Pointer<git_reflog> _reflogPointer;

  late RefLogEntry _currentEntry;
  int _index = 0;
  late final int _count;

  @override
  RefLogEntry get current => _currentEntry;

  @override
  bool moveNext() {
    if (_index == _count) {
      return false;
    } else {
      _currentEntry = RefLogEntry._(
        bindings.getByIndex(reflogPointer: _reflogPointer, index: _index),
      );
      _index++;
      return true;
    }
  }
}
