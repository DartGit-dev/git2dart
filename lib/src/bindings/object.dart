import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Get the object type of an object.
git_object_t type(Pointer<git_object> obj) => libgit2.git_object_type(obj);

/// Lookup a reference to one of the objects in a repository. The returned
/// reference must be freed with [free].
///
/// The 'type' parameter must match the type of the object in the odb; the
/// method will fail otherwise. The special value 'GIT_OBJECT_ANY' may be
/// passed to let the method guess the object's type.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_object> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
  required git_object_t type,
}) {
  return using((arena) {
    final out = arena<Pointer<git_object>>();
    final error = libgit2.git_object_lookup(out, repoPointer, oidPointer, type);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Close an open object to release memory.
///
/// This method instructs the library to close an existing object; note that
/// git_objects are owned and cached by the repository so the object may or may
/// not be freed after this library call, depending on how aggressive is the
/// caching mechanism used by the repository.
void free(Pointer<git_object> object) => libgit2.git_object_free(object);

/// Recursively peel an object until an object of the specified type is met.
///
/// The returned object must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_object> peel({
  required Pointer<git_object> objectPointer,
  required git_object_t targetType,
}) {
  return using((arena) {
    final out = arena<Pointer<git_object>>();
    final error = libgit2.git_object_peel(out, objectPointer, targetType);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get a short abbreviated OID string for the object.
///
/// This starts at the "core.abbrev" length (default 7 characters) and
/// iteratively extends to a longer string if that length is ambiguous.
/// The returned string will be unique in the repository.
///
/// Throws a [LibGit2Error] if error occurred.
String shortId({required Pointer<git_object> objectPointer}) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_object_short_id(out, objectPointer);
    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Convert a string object type to its corresponding type.
git_object_t string2type(String type) {
  return using((arena) {
    final typeC = type.toChar(arena);
    return libgit2.git_object_string2type(typeC);
  });
}

/// Convert an object type to its corresponding string representation.
String type2string(git_object_t type) {
  final result = libgit2.git_object_type2string(type);
  return result.toDartString();
}
