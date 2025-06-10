import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Create a new reference database for the repository. The returned database
/// does not have any backend attached and must be configured before use.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_refdb> create(Pointer<git_repository> repoPointer) {
  return using((arena) {
    final out = arena<Pointer<git_refdb>>();
    final error = libgit2.git_refdb_new(out, repoPointer);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Open the default reference database for the repository. The returned
/// database is ready for use with the standard filesystem backend attached.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_refdb> open(Pointer<git_repository> repoPointer) {
  return using((arena) {
    final out = arena<Pointer<git_refdb>>();
    final error = libgit2.git_refdb_open(out, repoPointer);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Initialize a refdb backend structure with default values.
void initBackend(Pointer<git_refdb_backend> backend) {
  libgit2.git_refdb_init_backend(backend, GIT_REFDB_BACKEND_VERSION);
}

/// Create a filesystem-based backend for the repository.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_refdb_backend> backendFs(Pointer<git_repository> repoPointer) {
  return using((arena) {
    final out = arena<Pointer<git_refdb_backend>>();
    final error = libgit2.git_refdb_backend_fs(out, repoPointer);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Attach a backend to the reference database.
///
/// After this call the backend is owned by libgit2 and must not be freed.
///
/// Throws a [LibGit2Error] if error occured.
void setBackend({
  required Pointer<git_refdb> refdbPointer,
  required Pointer<git_refdb_backend> backendPointer,
}) {
  final error = libgit2.git_refdb_set_backend(refdbPointer, backendPointer);
  checkErrorAndThrow(error);
}

/// Suggests that the given refdb compress or optimize its references.
/// This mechanism is implementation specific. For on-disk reference databases,
/// for example, this may pack all loose references.
void compress(Pointer<git_refdb> refdb) => libgit2.git_refdb_compress(refdb);

/// Close an open reference database to release memory.
void free(Pointer<git_refdb> refdb) => libgit2.git_refdb_free(refdb);
