import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Create a new action signature. The returned signature must be freed with
/// [free].
///
/// Note: angle brackets ('<' and '>') characters are not allowed to be used in
/// either the name or the email parameter.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_signature> create({
  required String name,
  required String email,
  required int time,
  required int offset,
}) {
  return using((arena) {
    final out = arena<Pointer<git_signature>>();
    final nameC = name.toChar(arena);
    final emailC = email.toChar(arena);
    final error = libgit2.git_signature_new(out, nameC, emailC, time, offset);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a new action signature with a timestamp of 'now'. The returned
/// signature must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_signature> now({required String name, required String email}) {
  return using((arena) {
    final out = arena<Pointer<git_signature>>();
    final nameC = name.toChar(arena);
    final emailC = email.toChar(arena);
    final error = libgit2.git_signature_now(out, nameC, emailC);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get the default signature for the repository.
///
/// If the repository is configured with user.name and user.email, those
/// values are used. Otherwise, the name and email are read from the
/// environment variables GIT_AUTHOR_NAME, GIT_AUTHOR_EMAIL, GIT_COMMITTER_NAME,
/// and GIT_COMMITTER_EMAIL. If those are not set, the name and email are
/// read from the system's user.name and user.email configuration.
///
/// The returned signature must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_signature> defaultSignature(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_signature>>();
    final error = libgit2.git_signature_default(out, repo);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a copy of an existing signature. The returned signature must be
/// freed with [free].
Pointer<git_signature> duplicate(Pointer<git_signature> sig) {
  return using((arena) {
    final out = arena<Pointer<git_signature>>();
    final error = libgit2.git_signature_dup(out, sig);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a signature from a buffer.
///
/// The buffer should contain a signature in the standard git format.
/// Throws a [LibGit2Error] if parsing fails.
Pointer<git_signature> fromBuffer(String buffer) {
  return using((arena) {
    final out = arena<Pointer<git_signature>>();
    final bufC = buffer.toChar(arena);
    final error = libgit2.git_signature_from_buffer(out, bufC);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Free an existing signature.
void free(Pointer<git_signature> sig) => libgit2.git_signature_free(sig);
