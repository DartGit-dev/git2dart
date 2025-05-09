import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/object.dart' as object_bindings;
import 'package:git2dart/src/bindings/tag.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git tag object.
///
/// This class provides methods to interact with Git tags, including creating,
/// modifying, and retrieving tag information. It wraps the libgit2 tag
/// functionality in a more Dart-friendly way.
@immutable
class Tag extends Equatable {
  /// Initializes a new instance of [Tag] class from provided pointer to
  /// tag object in memory.
  ///
  /// This constructor is for internal use only. Use [Tag.lookup] instead
  /// to create tag instances.
  ///
  /// [tagPointer] is a pointer to the underlying libgit2 tag object.
  @internal
  Tag(this._tagPointer) {
    _finalizer.attach(this, _tagPointer, detach: this);
  }

  /// Creates a new tag instance by looking up a tag object in the repository.
  ///
  /// [repo] is the repository to search in.
  /// [oid] is the object ID of the tag to look up.
  ///
  /// Throws a [LibGit2Error] if the tag cannot be found or if an error occurs.
  Tag.lookup({required Repository repo, required Oid oid}) {
    _tagPointer = bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: oid.pointer,
    );
    _finalizer.attach(this, _tagPointer, detach: this);
  }

  late final Pointer<git_tag> _tagPointer;

  /// Gets the pointer to the underlying libgit2 tag object.
  ///
  /// This is for internal use only.
  @internal
  Pointer<git_tag> get pointer => _tagPointer;

  /// Gets the [Oid] of the tag.
  Oid get oid => Oid(bindings.id(_tagPointer));

  /// Gets the name of the tag.
  String get name => bindings.name(_tagPointer);

  /// Gets the message of the tag.
  String get message => bindings.message(_tagPointer);

  /// Gets the tagger (author) of the tag.
  Signature get tagger => Signature(bindings.tagger(_tagPointer));

  /// Gets the type of the tagged object.
  GitObject get targetType {
    final type = bindings.targetType(_tagPointer);
    return GitObject.fromValue(type.value);
  }

  /// Gets the [Oid] of the tagged object.
  Oid get targetOid => Oid(bindings.targetOid(_tagPointer));

  /// Gets the tagged object.
  ///
  /// Returns a [GitObject] representing the tagged object.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  GitObject get target {
    final type = bindings.targetType(_tagPointer);
    return GitObject.fromValue(type.value);
  }

  /// Creates a new annotated tag in the repository.
  ///
  /// [repo] is the repository where to store the tag.
  /// [tagName] is the name for the new tag.
  /// [target] is the object ID to tag.
  /// [targetType] specifies the type of object being tagged (commit, tree, blob, etc).
  /// [tagger] is the signature of the person creating the tag.
  /// [message] is the message/description for the tag.
  /// [force] if true, existing tag with same name will be overwritten.
  ///
  /// Returns the [Oid] of the newly created tag.
  ///
  /// Throws a [LibGit2Error] if an error occurs during tag creation.
  static Oid createAnnotated({
    required Repository repo,
    required String tagName,
    required Oid target,
    required GitObject targetType,
    required Signature tagger,
    required String message,
    bool force = false,
  }) {
    final object = object_bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: target.pointer,
      type: git_object_t.fromValue(targetType.value),
    );

    final result = bindings.createAnnotated(
      repoPointer: repo.pointer,
      tagName: tagName,
      targetPointer: object,
      taggerPointer: tagger.pointer,
      message: message,
      force: force,
    );

    object_bindings.free(object);

    return Oid(result);
  }

  /// Creates a new lightweight tag in the repository.
  ///
  /// [repo] is the repository where to store the tag.
  /// [tagName] is the name for the new tag.
  /// [target] is the object to tag.
  /// [targetType] specifies the type of object being tagged (commit, tree, blob, etc).

  /// [force] determines whether to force the tag creation if a tag with the same name already exists.
  ///
  /// Returns the [Oid] of the newly created tag.
  ///
  /// Throws a [LibGit2Error] if an error occurs during tag creation.
  static Oid createLightweight({
    required Repository repo,
    required String tagName,
    required Oid target,
    required GitObject targetType,
    bool force = false,
  }) {
    final object = object_bindings.lookup(
      repoPointer: repo.pointer,
      oidPointer: target.pointer,
      type: git_object_t.fromValue(GitObject.any.value),
    );

    final result = bindings.createLightweight(
      repoPointer: repo.pointer,
      tagName: tagName,
      targetPointer: object,
      force: force,
    );

    object_bindings.free(object);

    return Oid(result);
  }

  /// Lists all tags in the repository.
  ///
  /// [repo] is the repository to list tags from.
  ///
  /// Returns a list of tag names.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static List<String> list({required Repository repo}) =>
      bindings.list(repo.pointer);

  /// Deletes a tag from the repository.
  ///
  /// [repo] is the repository containing the tag.
  /// [tagName] is the name of the tag to delete.
  ///
  /// Throws a [LibGit2Error] if an error occurs.
  static void delete({required Repository repo, required String tagName}) {
    bindings.delete(repoPointer: repo.pointer, tagName: tagName);
  }

  /// Releases memory allocated for the tag object.
  ///
  /// This should be called when the tag object is no longer needed.
  void free() {
    bindings.free(_tagPointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'Tag{oid: $oid, name: $name, message: $message, tagger: $tagger}';
  }

  @override
  List<Object?> get props => [oid];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_tag>>(
  (pointer) => bindings.free(pointer),
);
// coverage:ignore-end
