import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/object.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A generic Git object wrapping [git_object] pointer.
@immutable
class GitObject extends Equatable {
  /// Initializes [GitObject] from existing pointer.
  @internal
  GitObject._(this._objectPointer) {
    _finalizer.attach(this, _objectPointer, detach: this);
  }

  /// Lookups object in [repo] for provided [oid].
  ///
  /// Throws a [LibGit2Error] if error occurred.
  factory GitObject.lookup({
    required Repository repo,
    required Oid oid,
    GitObjectType type = GitObjectType.any,
  }) {
    final pointer = bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: oid.pointer,
      type: git_object_t.fromValue(type.value),
    );
    return GitObject._(pointer);
  }

  late final Pointer<git_object> _objectPointer;

  /// Pointer to underlying git_object.
  @internal
  Pointer<git_object> get pointer => _objectPointer;

  /// Type of this object.
  GitObjectType get type {
    final t = bindings.type(_objectPointer);
    return GitObjectType.fromValue(t.value);
  }

  /// Object id.
  Oid get oid => Oid.fromRaw(libgit2.git_object_id(_objectPointer).ref);

  /// Get short abbreviated OID string.
  String get shortId => bindings.shortId(objectPointer: _objectPointer);

  /// Recursively peel object to [targetType].
  GitObject peel({required GitObjectType targetType}) {
    final pointer = bindings.peel(
      objectPointer: _objectPointer,
      targetType: git_object_t.fromValue(targetType.value),
    );
    return GitObject._(pointer);
  }

  /// Convert string to [GitObjectType].
  static GitObjectType string2type(String type) {
    final res = bindings.string2type(type);
    return GitObjectType.fromValue(res.value);
  }

  /// Convert [type] to its string representation.
  static String type2string(GitObjectType type) {
    return bindings.type2string(git_object_t.fromValue(type.value));
  }

  /// Release allocated memory.
  void free() {
    bindings.free(_objectPointer);
    _finalizer.detach(this);
  }

  @override
  String toString() => 'GitObject{oid: \$oid, type: \$type}';

  @override
  List<Object?> get props => [oid];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_object>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
