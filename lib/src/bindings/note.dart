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

/// Create an iterator over notes from a specific commit.
///
/// The returned iterator must be freed with [iteratorFree].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_note_iterator> commitIteratorNew(Pointer<git_commit> notesCommit) {
  return using((arena) {
    final out = arena<Pointer<git_note_iterator>>();
    final error = libgit2.git_note_commit_iterator_new(out, notesCommit);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Read the note for an object from a notes commit. The returned note must be
/// freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_note> commitRead({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> notesCommitPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_note>>();
    final error = libgit2.git_note_commit_read(
      out,
      repoPointer,
      notesCommitPointer,
      oidPointer,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a note in a new commit.
///
/// The returned commit and note id pointers must be freed by the caller.
///
/// Throws a [LibGit2Error] if error occured.
List<Pointer<git_oid>> commitCreate({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> parentPointer,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  required Pointer<git_oid> oidPointer,
  required String note,
  bool allowOverwrite = false,
}) {
  return using((arena) {
    final commitOut = calloc<git_oid>();
    final blobOut = calloc<git_oid>();
    final noteC = note.toChar(arena);
    final allowC = allowOverwrite ? 1 : 0;
    final error = libgit2.git_note_commit_create(
      commitOut,
      blobOut,
      repoPointer,
      parentPointer,
      authorPointer,
      committerPointer,
      oidPointer,
      noteC,
      allowC,
    );
    checkErrorAndThrow(error);
    return [commitOut, blobOut];
  });
}

/// Remove the note for an object in a notes commit.
///
/// The returned commit id must be freed by the caller.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> commitRemove({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> notesCommitPointer,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final error = libgit2.git_note_commit_remove(
      out,
      repoPointer,
      notesCommitPointer,
      authorPointer,
      committerPointer,
      oidPointer,
    );
    checkErrorAndThrow(error);
    return out;
  });
}

/// Get the default notes reference for a repository.
///
/// Throws a [LibGit2Error] if error occured.
String defaultRef(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_note_default_ref(out, repo);
    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Iterate over all notes within the specified namespace.
///
/// Throws a [LibGit2Error] if error occured.
void foreach({
  required Pointer<git_repository> repoPointer,
  required String notesRef,
  required git_note_foreach_cb callback,
  required Pointer<Void> payload,
}) {
  return using((arena) {
    final notesRefC = notesRef.toChar(arena);
    final error = libgit2.git_note_foreach(
      repoPointer,
      notesRefC,
      callback,
      payload,
    );
    checkErrorAndThrow(error);
  });
}
