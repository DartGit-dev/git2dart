import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Get the type of a reference.
///
/// Returns either [GIT_REFERENCE_DIRECT] for direct references (pointing to an OID)
/// or [GIT_REFERENCE_SYMBOLIC] for symbolic references (pointing to another reference).
git_reference_t referenceType(Pointer<git_reference> ref) =>
    libgit2.git_reference_type(ref);

/// Get the OID pointed to by a direct reference.
///
/// This function is only available for direct references (those pointing to an OID).
/// For symbolic references, use [resolve] to get the final target OID.
///
/// Returns a pointer to the OID that this reference points to.
Pointer<git_oid> target(Pointer<git_reference> ref) =>
    libgit2.git_reference_target(ref);

/// Get the target of a symbolic reference.
///
/// This function is only available for symbolic references. For direct references,
/// use [target] to get the OID.
///
/// Returns the name of the reference that this symbolic reference points to.
String symbolicTarget(Pointer<git_reference> ref) =>
    libgit2.git_reference_symbolic_target(ref).toDartString();

/// Resolve a symbolic reference to a direct reference.
///
/// This method iteratively peels a symbolic reference until it resolves to a
/// direct reference to an OID. For example, if HEAD is a symbolic reference to
/// refs/heads/master, and master is a direct reference to an OID, this will
/// return the direct reference to that OID.
///
/// If a direct reference is passed as an argument, a copy of that reference is
/// returned.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be resolved.
Pointer<git_reference> resolve(Pointer<git_reference> ref) {
  final out = calloc<Pointer<git_reference>>();
  final error = libgit2.git_reference_resolve(out, ref);

  final result = out.value;

  calloc.free(out);

  checkErrorAndThrow(error);
  return result;
}

/// Lookup a reference by name in a repository.
///
/// The name will be checked for validity. Valid reference names must follow
/// one of two patterns:
/// 1. Top-level names must contain only capital letters and underscores, and
///    must begin and end with a letter (e.g., "HEAD", "ORIG_HEAD").
/// 2. Names prefixed with "refs/" can be almost anything, but must avoid the
///    characters '~', '^', ':', '\', '?', '[', '*', and the sequences ".."
///    and "@{" which have special meaning to revparse.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be found or is invalid.
Pointer<git_reference> lookup({
  required Pointer<git_repository> repoPointer,
  required String name,
}) {
  final out = calloc<Pointer<git_reference>>();
  final nameC = name.toChar();
  final error = libgit2.git_reference_lookup(out, repoPointer, nameC);

  final result = out.value;

  calloc.free(out);
  calloc.free(nameC);

  checkErrorAndThrow(error);
  return result;
}

/// Get the full name of a reference.
///
/// Returns the full name of the reference (e.g., "refs/heads/master").
String name(Pointer<git_reference> ref) {
  return libgit2.git_reference_name(ref).toDartString();
}

/// Get the reference's short name.
///
/// This will transform the reference name into a "human-readable" version.
/// For example:
/// - "refs/heads/master" becomes "master"
/// - "refs/remotes/origin/master" becomes "origin/master"
/// - "refs/tags/v1.0" becomes "v1.0"
///
/// If no shortname is appropriate, it will return the full name.
String shorthand(Pointer<git_reference> ref) {
  return libgit2.git_reference_shorthand(ref).toDartString();
}

/// Rename an existing reference.
///
/// This method works for both direct and symbolic references. The new name will
/// be checked for validity.
///
/// If [force] is false and there's already a reference with the given name,
/// the renaming will fail.
///
/// If [logMessage] is provided, it will be used as the message for the reflog
/// entry. The reflog entry will only be written if the reference belongs to the
/// standard set (HEAD, branches, and remote-tracking branches) or if it already
/// has a reflog.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be renamed.
Pointer<git_reference> rename({
  required Pointer<git_reference> refPointer,
  required String newName,
  required bool force,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final newNameC = newName.toChar();
  final forceC = force ? 1 : 0;
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_rename(
    out,
    refPointer,
    newNameC,
    forceC,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(newNameC);
  calloc.free(logMessageC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// List all references in a repository.
///
/// Returns a list of all reference names that can be found in the repository.
/// This includes all references in the standard locations (refs/heads/,
/// refs/remotes/, refs/tags/, etc.) as well as any other references that
/// might exist.
///
/// Throws a [LibGit2Error] if the references cannot be listed.
List<String> list(Pointer<git_repository> repo) {
  final array = calloc<git_strarray>();
  final error = libgit2.git_reference_list(array, repo);
  final result = <String>[];

  checkErrorAndThrow(error);

  for (var i = 0; i < array.ref.count; i++) {
    result.add(array.ref.strings[i].cast<Char>().toDartString());
  }

  calloc.free(array);

  return result;
}

/// Check if a reflog exists for the specified reference.
///
/// Returns true if the reference has a reflog, false otherwise.
bool hasLog({
  required Pointer<git_repository> repoPointer,
  required String name,
}) {
  final nameC = name.toChar();
  final result = libgit2.git_reference_has_log(repoPointer, nameC);

  calloc.free(nameC);

  return result == 1;
}

/// Ensure there is a reflog for a particular reference.
///
/// This will create a reflog for the reference if it doesn't already exist.
/// Successive updates to the reference will append to its log.
///
/// Throws a [LibGit2Error] if the reflog cannot be created.
void ensureLog({
  required Pointer<git_repository> repoPointer,
  required String refName,
}) {
  final refNameC = refName.toChar();
  final error = libgit2.git_reference_ensure_log(repoPointer, refNameC);

  calloc.free(refNameC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Check if a reference is a local branch.
///
/// Returns true if the reference is a local branch (starts with "refs/heads/").
bool isBranch(Pointer<git_reference> ref) {
  return libgit2.git_reference_is_branch(ref) == 1;
}

/// Check if a reference is a note.
///
/// Returns true if the reference is a note (starts with "refs/notes/").
bool isNote(Pointer<git_reference> ref) {
  return libgit2.git_reference_is_note(ref) == 1;
}

/// Check if a reference is a remote tracking branch.
///
/// Returns true if the reference is a remote tracking branch
/// (starts with "refs/remotes/").
bool isRemote(Pointer<git_reference> ref) {
  return libgit2.git_reference_is_remote(ref) == 1;
}

/// Check if a reference is a tag.
///
/// Returns true if the reference is a tag (starts with "refs/tags/").
bool isTag(Pointer<git_reference> ref) {
  return libgit2.git_reference_is_tag(ref) == 1;
}

/// Create a new direct reference.
///
/// A direct reference (also called an object id reference) refers directly to a
/// specific object id (OID) in the repository. The id permanently refers to the
/// object (although the reference itself can be moved).
///
/// Valid reference names must follow one of two patterns:
/// 1. Top-level names must contain only capital letters and underscores, and
///    must begin and end with a letter (e.g., "HEAD", "ORIG_HEAD").
/// 2. Names prefixed with "refs/" can be almost anything, but must avoid the
///    characters '~', '^', ':', '\', '?', '[', '*', and the sequences ".."
///    and "@{" which have special meaning to revparse.
///
/// If [force] is false and a reference already exists with the given name,
/// the creation will fail.
///
/// If [logMessage] is provided, it will be used as the message for the reflog
/// entry. The reflog entry will only be written if the reference belongs to the
/// standard set (HEAD, branches, and remote-tracking branches) or if it already
/// has a reflog.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be created.
Pointer<git_reference> createDirect({
  required Pointer<git_repository> repoPointer,
  required String name,
  required Pointer<git_oid> oidPointer,
  required bool force,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final nameC = name.toChar();
  final forceC = force ? 1 : 0;
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_create(
    out,
    repoPointer,
    nameC,
    oidPointer,
    forceC,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(nameC);
  calloc.free(logMessageC);

  checkErrorAndThrow(error);
  return result;
}

/// Create a new symbolic reference.
///
/// A symbolic reference points to another reference rather than directly to an
/// OID. For example, HEAD is typically a symbolic reference pointing to a branch.
///
/// Valid reference names must follow one of two patterns:
/// 1. Top-level names must contain only capital letters and underscores, and
///    must begin and end with a letter (e.g., "HEAD", "ORIG_HEAD").
/// 2. Names prefixed with "refs/" can be almost anything, but must avoid the
///    characters '~', '^', ':', '\', '?', '[', '*', and the sequences ".."
///    and "@{" which have special meaning to revparse.
///
/// If [force] is false and a reference already exists with the given name,
/// the creation will fail.
///
/// If [logMessage] is provided, it will be used as the message for the reflog
/// entry. The reflog entry will only be written if the reference belongs to the
/// standard set (HEAD, branches, and remote-tracking branches) or if it already
/// has a reflog.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be created.
Pointer<git_reference> createSymbolic({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String target,
  required bool force,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final nameC = name.toChar();
  final targetC = target.toChar();
  final forceC = force ? 1 : 0;
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_symbolic_create(
    out,
    repoPointer,
    nameC,
    targetC,
    forceC,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(nameC);
  calloc.free(targetC);
  calloc.free(logMessageC);

  checkErrorAndThrow(error);
  return result;
}

/// Update a direct reference to point to a new OID.
///
/// This function can only be used on direct references. For symbolic references,
/// use [updateSymbolic] instead.
///
/// If [logMessage] is provided, it will be used as the message for the reflog
/// entry. The reflog entry will only be written if the reference belongs to the
/// standard set (HEAD, branches, and remote-tracking branches) or if it already
/// has a reflog.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be updated.
Pointer<git_reference> updateDirect({
  required Pointer<git_reference> refPointer,
  required Pointer<git_oid> oidPointer,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_set_target(
    out,
    refPointer,
    oidPointer,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(logMessageC);

  checkErrorAndThrow(error);
  return result;
}

/// Update a symbolic reference to point to a new target.
///
/// This function can only be used on symbolic references. For direct references,
/// use [updateDirect] instead.
///
/// If [logMessage] is provided, it will be used as the message for the reflog
/// entry. The reflog entry will only be written if the reference belongs to the
/// standard set (HEAD, branches, and remote-tracking branches) or if it already
/// has a reflog.
///
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if the reference cannot be updated.
Pointer<git_reference> updateSymbolic({
  required Pointer<git_reference> refPointer,
  required String target,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final targetC = target.toChar();
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_symbolic_set_target(
    out,
    refPointer,
    targetC,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(targetC);
  calloc.free(logMessageC);

  checkErrorAndThrow(error);
  return result;
}

/// Delete a reference.
///
/// This will remove the reference from the repository. If the reference is a
/// symbolic reference, it will be removed. If it is a direct reference, the
/// reference will be removed but the object it points to will remain in the
/// repository.
///
/// Throws a [LibGit2Error] if the reference cannot be deleted.
void delete(Pointer<git_reference> ref) {
  final error = libgit2.git_reference_delete(ref);
  checkErrorAndThrow(error);
}

/// Free a reference object.
///
/// This will free the reference and all associated resources. The reference
/// must not be used after this call.
void free(Pointer<git_reference> ref) {
  libgit2.git_reference_free(ref);
}

/// Get the repository where a reference resides.
Pointer<git_repository> owner(Pointer<git_reference> ref) {
  return libgit2.git_reference_owner(ref);
}

/// Conditionally create a new reference with the same name as the given
/// reference but a different OID target. The reference must be a direct
/// reference, otherwise this will fail.
///
/// The new reference will be written to disk, overwriting the given reference.
/// The returned reference must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_reference> setTarget({
  required Pointer<git_reference> refPointer,
  required Pointer<git_oid> oidPointer,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_set_target(
    out,
    refPointer,
    oidPointer,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(logMessageC);

  checkErrorAndThrow(error);
  return result;
}

/// Create a new reference with the same name as the given reference but a
/// different symbolic target. The reference must be a symbolic reference,
/// otherwise this will fail.
///
/// The new reference will be written to disk, overwriting the given reference.
/// The returned reference must be freed with [free].
///
/// The target name will be checked for validity.
///
/// The message for the reflog will be ignored if the reference does not belong
/// in the standard set (HEAD, branches and remote-tracking branches) and and
/// it does not have a reflog.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_reference> setTargetSymbolic({
  required Pointer<git_reference> refPointer,
  required String target,
  String? logMessage,
}) {
  final out = calloc<Pointer<git_reference>>();
  final targetC = target.toChar();
  final logMessageC = logMessage?.toChar() ?? nullptr;
  final error = libgit2.git_reference_symbolic_set_target(
    out,
    refPointer,
    targetC,
    logMessageC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(targetC);
  calloc.free(logMessageC);

  checkErrorAndThrow(error);
  return result;
}

/// Recursively peel reference until object of the specified type is found.
///
/// The retrieved peeled object is owned by the repository and should be closed
/// to release memory.
///
/// If you pass GIT_OBJECT_ANY as the target type, then the object will be
/// peeled until a non-tag object is met.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_object> peel({
  required Pointer<git_reference> refPointer,
  required git_object_t type,
}) {
  final out = calloc<Pointer<git_object>>();
  final error = libgit2.git_reference_peel(out, refPointer, type);

  final result = out.value;

  calloc.free(out);

  checkErrorAndThrow(error);
  return result;
}

/// Create a copy of an existing reference. The returned reference must be
/// freed with [free].
Pointer<git_reference> duplicate(Pointer<git_reference> source) {
  final out = calloc<Pointer<git_reference>>();
  libgit2.git_reference_dup(out, source);

  final result = out.value;

  calloc.free(out);

  return result;
}

/// Lookup a reference by name and resolve immediately to OID.
///
/// This function provides a quick way to resolve a reference name straight
/// through to the object id that it refers to.  This avoids having to
/// allocate or free any `git_reference` objects for simple situations.
///
/// The name will be checked for validity.
/// See [createSymbolic] for rules about valid names.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> nameToId({
  required Pointer<git_repository> repoPointer,
  required String refName,
}) {
  final result = calloc<git_oid>();
  final nameC = refName.toChar();

  final error = libgit2.git_reference_name_to_id(result, repoPointer, nameC);

  checkErrorAndThrow(error);
  return result;
}
