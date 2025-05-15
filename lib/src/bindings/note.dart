import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Returns list of notes for repository. The returned notes must be freed with
/// [free].
///
/// Throws a [LibGit2Error] if error occured.
List<Map<String, Pointer>> list({
  required Pointer<git_repository> repoPointer,
  required String notesRef,
}) {
  return using((arena) {
    final notesRefC = notesRef.toChar(arena);
    final iterator = arena<Pointer<git_iterator>>();
    final iteratorError = libgit2.git_note_iterator_new(
      iterator,
      repoPointer,
      notesRefC,
    );
    checkErrorAndThrow(iteratorError);

    final result = <Map<String, Pointer>>[];
    var nextError = 0;

    while (nextError >= 0) {
      final noteOid = arena<git_oid>();
      final annotatedOid = calloc<git_oid>();
      nextError = libgit2.git_note_next(noteOid, annotatedOid, iterator.value);
      if (nextError >= 0) {
        final out = arena<Pointer<git_note>>();
        final error = libgit2.git_note_read(
          out,
          repoPointer,
          notesRefC,
          annotatedOid,
        );
        checkErrorAndThrow(error);

        result.add({'note': out.value, 'annotatedOid': annotatedOid});
      } else {
        break;
      }
    }

    libgit2.git_note_iterator_free(iterator.value);
    return result;
  });
}

/// Read the note for an object. The returned note must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_note> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
  required String notesRef,
}) {
  return using((arena) {
    final out = arena<Pointer<git_note>>();
    final notesRefC = notesRef.toChar(arena);
    final error = libgit2.git_note_read(
      out,
      repoPointer,
      notesRefC,
      oidPointer,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Add a note for an object.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> create({
  required Pointer<git_repository> repoPointer,
  required String notesRef,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  required Pointer<git_oid> oidPointer,
  required String note,
  bool force = false,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final notesRefC = notesRef.toChar(arena);
    final noteC = note.toChar(arena);
    final forceC = force ? 1 : 0;
    final error = libgit2.git_note_create(
      out,
      repoPointer,
      notesRefC,
      authorPointer,
      committerPointer,
      oidPointer,
      noteC,
      forceC,
    );
    checkErrorAndThrow(error);
    return out;
  });
}

/// Delete the note for an object.
///
/// Throws a [LibGit2Error] if error occured.
void delete({
  required Pointer<git_repository> repoPointer,
  required String notesRef,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final notesRefC = notesRef.toChar(arena);
    final error = libgit2.git_note_remove(
      repoPointer,
      notesRefC,
      authorPointer,
      committerPointer,
      oidPointer,
    );
    checkErrorAndThrow(error);
  });
}

/// Get the note object's id.
Pointer<git_oid> id(Pointer<git_note> note) => libgit2.git_note_id(note);

/// Get the note message.
String message(Pointer<git_note> note) {
  return libgit2.git_note_message(note).toDartString();
}

/// Free memory allocated for note object.
void free(Pointer<git_note> note) => libgit2.git_note_free(note);
