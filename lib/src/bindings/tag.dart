import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc, using;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Fill a list with all the tags in the repository.
///
/// Throws a [LibGit2Error] if error occurred.
List<String> list(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<git_strarray>();
    final error = libgit2.git_tag_list(out, repo);
    checkErrorAndThrow(error);

    final result = <String>[
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
    libgit2.git_strarray_dispose(out);
    return result;
  });
}

/// Lookup a tag object from the repository. The returned tag must be freed
/// with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_tag> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_tag>>();
    final error = libgit2.git_tag_lookup(out, repoPointer, oidPointer);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Lookup a tag object from the repository by its short [oid].
///
/// The returned tag must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_tag> lookupPrefix({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
  required int length,
}) {
  return using((arena) {
    final out = arena<Pointer<git_tag>>();
    final error = libgit2.git_tag_lookup_prefix(
      out,
      repoPointer,
      oidPointer,
      length,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the tagged object of a tag.
///
/// This method performs a repository lookup for the given object and returns
/// it.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_object> target(Pointer<git_tag> tag) {
  return using((arena) {
    final out = arena<Pointer<git_object>>();
    final error = libgit2.git_tag_target(out, tag);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the type of a tag's tagged object.
git_object_t targetType(Pointer<git_tag> tag) =>
    libgit2.git_tag_target_type(tag);

/// Get the OID of the tagged object of a tag.
Pointer<git_oid> targetOid(Pointer<git_tag> tag) =>
    libgit2.git_tag_target_id(tag);

/// Get the id of a tag.
Pointer<git_oid> id(Pointer<git_tag> tag) => libgit2.git_tag_id(tag);

/// Get the repository that owns this tag.
Pointer<git_repository> owner(Pointer<git_tag> tag) =>
    libgit2.git_tag_owner(tag);

/// Get the name of a tag.
String name(Pointer<git_tag> tag) => libgit2.git_tag_name(tag).toDartString();

/// Get the message of a tag.
String message(Pointer<git_tag> tag) {
  final result = libgit2.git_tag_message(tag);
  return result == nullptr ? '' : result.toDartString();
}

/// Check whether a tag name is valid.
bool nameIsValid(String name) {
  return using((arena) {
    final valid = arena<Int>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_tag_name_is_valid(valid, nameC);
    checkErrorAndThrow(error);
    return valid.value == 1;
  });
}

/// Get the tagger (author) of a tag. The returned signature must be freed.
Pointer<git_signature> tagger(Pointer<git_tag> tag) =>
    libgit2.git_tag_tagger(tag);

/// Recursively peel a tag until an object of the specified type is found.
///
/// The returned object must be freed.
Pointer<git_object> peel({
  required Pointer<git_tag> tagPointer,
  required git_object_t targetType,
}) {
  return using((arena) {
    final out = arena<Pointer<git_object>>();
    final error = libgit2.git_tag_peel(out, tagPointer);
    checkErrorAndThrow(error);

    final object = out.value;
    if (targetType == git_object_t.GIT_OBJECT_ANY ||
        libgit2.git_object_type(object).value == targetType.value) {
      return object;
    }

    final peeled = arena<Pointer<git_object>>();
    final peelError = libgit2.git_object_peel(peeled, object, targetType);
    libgit2.git_object_free(object);
    checkErrorAndThrow(peelError);
    return peeled.value;
  });
}

/// Create a new annotated tag in the repository from an object.
///
/// A new reference will also be created pointing to this tag object. If force
/// is true and a reference already exists with the given name, it'll be
/// replaced.
///
/// The message will not be cleaned up.
///
/// The tag name will be checked for validity. You must avoid the characters
/// '~', '^', ':', '\', '?', '[', and '*', and the sequences ".." and "@{" which have
/// special meaning to revparse.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_oid> createAnnotated({
  required Pointer<git_repository> repoPointer,
  required String tagName,
  required Pointer<git_object> targetPointer,
  required Pointer<git_signature> taggerPointer,
  required String message,
  required bool force,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final tagNameC = tagName.toChar(arena);
    final messageC = message.toChar(arena);
    final error = libgit2.git_tag_create(
      out,
      repoPointer,
      tagNameC,
      targetPointer,
      taggerPointer,
      messageC,
      force ? 1 : 0,
    );
    checkErrorAndThrow(error);
    return out;
  });
}

/// Create a new annotated tag object without creating a reference.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_oid> createAnnotation({
  required Pointer<git_repository> repoPointer,
  required String tagName,
  required Pointer<git_object> targetPointer,
  required Pointer<git_signature> taggerPointer,
  required String message,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final tagNameC = tagName.toChar(arena);
    final messageC = message.toChar(arena);
    final error = libgit2.git_tag_annotation_create(
      out,
      repoPointer,
      tagNameC,
      targetPointer,
      taggerPointer,
      messageC,
    );
    checkErrorAndThrow(error);
    return out;
  });
}

/// Create a new lightweight tag pointing at a target object.
///
/// A new direct reference will be created pointing to this target object. If
/// force is true and a reference already exists with the given name, it'll be
/// replaced.
///
/// The tag name will be checked for validity. See [createAnnotated] for rules
/// about valid names.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_oid> createLightweight({
  required Pointer<git_repository> repoPointer,
  required String tagName,
  required Pointer<git_object> targetPointer,
  required bool force,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final tagNameC = tagName.toChar(arena);
    final error = libgit2.git_tag_create_lightweight(
      out,
      repoPointer,
      tagNameC,
      targetPointer,
      force ? 1 : 0,
    );
    checkErrorAndThrow(error);
    return out;
  });
}

/// Create a tag from a raw buffer.
Pointer<git_oid> createFromBuffer({
  required Pointer<git_repository> repoPointer,
  required String buffer,
  required bool force,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final bufferC = buffer.toChar(arena);
    final error = libgit2.git_tag_create_from_buffer(
      out,
      repoPointer,
      bufferC,
      force ? 1 : 0,
    );
    checkErrorAndThrow(error);
    return out;
  });
}

/// Duplicate an existing tag object.
Pointer<git_tag> duplicate(Pointer<git_tag> tag) {
  return using((arena) {
    final out = arena<Pointer<git_tag>>();
    final error = libgit2.git_tag_dup(out, tag);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Iterate over all tags matching a pattern.
List<String> listMatch({
  required Pointer<git_repository> repoPointer,
  required String pattern,
}) {
  return using((arena) {
    final out = arena<git_strarray>();
    final patternC = pattern.toChar(arena);
    final error = libgit2.git_tag_list_match(out, patternC, repoPointer);
    checkErrorAndThrow(error);
    final result = [
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
    libgit2.git_strarray_dispose(out);
    return result;
  });
}

/// Global callback function for tag foreach
void Function(String name, Pointer<git_oid> oid)? _currentTagCallback;

/// Top-level callback function for tag foreach
int _tagForeachCallback(
  Pointer<Char> name,
  Pointer<git_oid> oid,
  Pointer<Void> payload,
) {
  _currentTagCallback?.call(name.toDartString(), oid);
  return 0;
}

/// Iterate over all tags using a callback.
void foreach({
  required Pointer<git_repository> repoPointer,
  required void Function(String name, Pointer<git_oid> oid) callback,
}) {
  const except = -1;
  _currentTagCallback = callback;
  final c = Pointer.fromFunction<git_tag_foreach_cbFunction>(
    _tagForeachCallback,
    except,
  );
  final error = libgit2.git_tag_foreach(repoPointer, c, nullptr);
  _currentTagCallback = null;
  checkErrorAndThrow(error);
}

/// Delete an existing tag reference.
///
/// The tag name will be checked for validity.
///
/// Throws a [LibGit2Error] if error occurred.
void delete({
  required Pointer<git_repository> repoPointer,
  required String tagName,
}) {
  using((arena) {
    final tagNameC = tagName.toChar(arena);
    final error = libgit2.git_tag_delete(repoPointer, tagNameC);
    checkErrorAndThrow(error);
  });
}

/// Close an open tag to release memory.
void free(Pointer<git_tag> tag) => libgit2.git_tag_free(tag);
