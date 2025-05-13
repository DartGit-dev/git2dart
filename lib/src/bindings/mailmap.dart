import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Allocate a new mailmap object. The returned mailmap must be freed with
/// [free].
///
/// This object is empty, so you'll have to add a mailmap file before you can
/// do anything with it.
Pointer<git_mailmap> init() {
  return using((arena) {
    final out = arena<Pointer<git_mailmap>>();
    final error = libgit2.git_mailmap_new(out);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a new mailmap instance containing a single mailmap file. The
/// returned mailmap must be freed with [free].
Pointer<git_mailmap> fromBuffer(String buffer) {
  return using((arena) {
    final out = arena<Pointer<git_mailmap>>();
    final bufferC = buffer.toChar(arena);
    final error = libgit2.git_mailmap_from_buffer(out, bufferC, buffer.length);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a new mailmap instance from a repository, loading mailmap files based
/// on the repository's configuration. The returned mailmap must be freed with
/// [free].
///
/// Mailmaps are loaded in the following order:
///
/// 1. `.mailmap` in the root of the repository's working directory, if present.
/// 2. The blob object identified by the `mailmap.blob` config entry, if set.
///   NOTE: `mailmap.blob` defaults to `HEAD:.mailmap` in bare repositories
/// 3. The path in the `mailmap.file` config entry, if set.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_mailmap> fromRepository(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_mailmap>>();
    final error = libgit2.git_mailmap_from_repository(out, repo);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Resolve a name and email to the corresponding real name and email.
List<String> resolve({
  required Pointer<git_mailmap> mailmapPointer,
  required String name,
  required String email,
}) {
  return using((arena) {
    final outRealName = arena<Pointer<Char>>();
    final outRealEmail = arena<Pointer<Char>>();
    final nameC = name.toChar(arena);
    final emailC = email.toChar(arena);

    libgit2.git_mailmap_resolve(
      outRealName,
      outRealEmail,
      mailmapPointer,
      nameC,
      emailC,
    );

    return [
      outRealName.value.toDartString(),
      outRealEmail.value.toDartString(),
    ];
  });
}

/// Resolve a signature to use real names and emails with a mailmap. The
/// returned signature must be freed.
Pointer<git_signature> resolveSignature({
  required Pointer<git_mailmap> mailmapPointer,
  required Pointer<git_signature> signaturePointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_signature>>();
    final error = libgit2.git_mailmap_resolve_signature(
      out,
      mailmapPointer,
      signaturePointer,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Add a single entry to the given mailmap object. If the entry already exists,
/// it will be replaced with the new entry.
///
/// Throws a [LibGit2Error] if error occured.
void addEntry({
  required Pointer<git_mailmap> mailmapPointer,
  String? realName,
  String? realEmail,
  String? replaceName,
  required String replaceEmail,
}) {
  return using((arena) {
    final realNameC = realName?.toChar(arena) ?? nullptr;
    final realEmailC = realEmail?.toChar(arena) ?? nullptr;
    final replaceNameC = replaceName?.toChar(arena) ?? nullptr;
    final replaceEmailC = replaceEmail.toChar(arena);

    final error = libgit2.git_mailmap_add_entry(
      mailmapPointer,
      realNameC,
      realEmailC,
      replaceNameC,
      replaceEmailC,
    );

    checkErrorAndThrow(error);
  });
}

/// Free the mailmap and its associated memory.
void free(Pointer<git_mailmap> mm) => libgit2.git_mailmap_free(mm);
