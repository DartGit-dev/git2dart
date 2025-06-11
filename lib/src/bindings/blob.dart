import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Lookup a blob object from a repository by its [oid].
///
/// The returned blob must be freed with [free] when no longer needed.
///
/// Throws a [LibGit2Error] if the blob cannot be found or if an error occurs.
Pointer<git_blob> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_blob>>();
    final error = libgit2.git_blob_lookup(out, repoPointer, oidPointer);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Lookup a blob object from a repository by its short [oid]. The returned
/// blob must be freed with [free].
///
/// Throws a [LibGit2Error] if the blob cannot be found or if an error occurs.
Pointer<git_blob> lookupPrefix({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
  required int len,
}) {
  return using((arena) {
    final out = arena<Pointer<git_blob>>();
    final error = libgit2.git_blob_lookup_prefix(
      out,
      repoPointer,
      oidPointer,
      len,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the [Oid] of a blob.
Pointer<git_oid> id(Pointer<git_blob> blob) => libgit2.git_blob_id(blob);

/// Determine if the blob content is most certainly binary or not.
///
/// The heuristic used to guess if a file is binary is taken from core git:
/// Searching for NUL bytes and looking for a reasonable ratio of printable to
/// non-printable characters among the first 8000 bytes.
bool isBinary(Pointer<git_blob> blob) {
  return libgit2.git_blob_is_binary(blob) == 1 || false;
}

/// Get a read-only buffer with the raw content of a blob.
///
/// Returns the raw content as a UTF-8 string.
String content(Pointer<git_blob> blob) {
  return libgit2.git_blob_rawcontent(blob).cast<Utf8>().toDartString();
}

/// Get a read-only buffer with the raw content of a blob as bytes.
Uint8List contentBytes(Pointer<git_blob> blob) {
  final size = libgit2.git_blob_rawsize(blob);
  if (size == 0) return Uint8List(0);
  final data = libgit2
      .git_blob_rawcontent(blob)
      .cast<Uint8>()
      .asTypedList(size);
  return Uint8List.fromList(data);
}

/// Get the size in bytes of the contents of a blob.
int size(Pointer<git_blob> blob) => libgit2.git_blob_rawsize(blob);

/// Write content of a string buffer to the ODB as a blob.
///
/// Creates a new blob from the provided [buffer] content and writes it to the
/// Object Database.
///
/// Throws a [LibGit2Error] if an error occurs during creation.
Pointer<git_oid> create({
  required Pointer<git_repository> repoPointer,
  required String buffer,
  required int len,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final bufferC = buffer.toNativeUtf8Arena(arena).cast<Void>();
    final error = libgit2.git_blob_create_from_buffer(
      out,
      repoPointer,
      bufferC,
      len,
    );

    checkErrorAndThrow(error);

    return out;
  });
}

/// Read a file from the working folder of a repository and write it to the
/// Object Database as a loose blob.
///
/// The [relativePath] should be relative to the working directory.
///
/// Throws a [LibGit2Error] if the file cannot be read or if an error occurs.
Pointer<git_oid> createFromWorkdir({
  required Pointer<git_repository> repoPointer,
  required String relativePath,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final relativePathC = relativePath.toChar(arena);
    final error = libgit2.git_blob_create_from_workdir(
      out,
      repoPointer,
      relativePathC,
    );

    checkErrorAndThrow(error);
    return out;
  });
}

/// Read a file from the filesystem and write its content to the Object
/// Database as a loose blob.
///
/// The [path] should be an absolute path to the file.
///
/// Throws a [LibGit2Error] if the file cannot be read or if an error occurs.
Pointer<git_oid> createFromDisk({
  required Pointer<git_repository> repoPointer,
  required String path,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_blob_create_from_disk(out, repoPointer, pathC);

    checkErrorAndThrow(error);
    return out;
  });
}

/// Create an in-memory copy of a blob.
///
/// The returned copy must be freed with [free] when no longer needed.
Pointer<git_blob> duplicate(Pointer<git_blob> source) {
  return using((arena) {
    final out = arena<Pointer<git_blob>>();
    libgit2.git_blob_dup(out, source);
    return out.value;
  });
}

/// Create a stream to write a new blob into the object database.
///
/// The returned stream should be passed to [createFromStreamCommit] to
/// finalize the blob creation.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_writestream> createFromStream({
  required Pointer<git_repository> repoPointer,
  String? hintPath,
}) {
  return using((arena) {
    final out = arena<Pointer<git_writestream>>();
    final hintPathC = hintPath?.toChar(arena) ?? nullptr;
    final error = libgit2.git_blob_create_from_stream(
      out,
      repoPointer,
      hintPathC,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Close the stream and finalize writing the blob to the object database.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> createFromStreamCommit(Pointer<git_writestream> stream) {
  return using((arena) {
    final out = calloc<git_oid>();
    final error = libgit2.git_blob_create_from_stream_commit(out, stream);

    checkErrorAndThrow(error);
    return out;
  });
}

/// Determine if the given content is most certainly binary or not.
bool dataIsBinary({required Uint8List data, required int len}) {
  return using((arena) {
    final buffer = arena<Uint8>(data.length);
    buffer.asTypedList(data.length).setAll(0, data);

    return libgit2.git_blob_data_is_binary(buffer.cast<Char>(), len) == 1;
  });
}

/// Get a buffer with the filtered content of a blob.
///
/// This applies filters as if the blob was being checked out to the working
/// directory under the specified filename. This may apply CRLF filtering or
/// other types of changes depending on the file attributes set for the blob
/// and the content detected in it.
///
/// [asPath] is path used for file attribute lookups.
/// [flags] is a combination of [GitBlobFilter] flags to use for filtering.
/// [attributesCommit] is the commit to load attributes from, when
/// [GitBlobFilter.attributesFromCommit] is provided in [flags].
///
/// Throws a [LibGit2Error] if an error occurs during filtering.
String filterContent({
  required Pointer<git_blob> blobPointer,
  required String asPath,
  required int flags,
  git_oid? attributesCommit,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final asPathC = asPath.toChar(arena);
    final opts = arena<git_blob_filter_options>();
    libgit2.git_blob_filter_options_init(opts, GIT_BLOB_FILTER_OPTIONS_VERSION);
    opts.ref.flags = flags;
    if (attributesCommit != null) {
      opts.ref.attr_commit_id = attributesCommit;
    }

    final error = libgit2.git_blob_filter(out, blobPointer, asPathC, opts);

    checkErrorAndThrow(error);

    if (out.ref.ptr == nullptr) {
      return '';
    }
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Free the memory allocated for a blob object.
///
/// This should be called when the blob is no longer needed to prevent memory leaks.
void free(Pointer<git_blob> blob) => libgit2.git_blob_free(blob);
