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

    return <String>[
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
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

/// Get the name of a tag.
String name(Pointer<git_tag> tag) => libgit2.git_tag_name(tag).toDartString();

/// Get the message of a tag.
String message(Pointer<git_tag> tag) {
  final result = libgit2.git_tag_message(tag);
  return result == nullptr ? '' : result.toDartString();
}

/// Get the tagger (author) of a tag. The returned signature must be freed.
Pointer<git_signature> tagger(Pointer<git_tag> tag) =>
    libgit2.git_tag_tagger(tag);

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
