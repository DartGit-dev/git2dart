import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc, using;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Parses a revision string and returns a [git_revspec] structure.
///
/// This function parses a revision string and returns a [git_revspec] structure
/// containing the parsed information. The revision string can be in various formats
/// as described in the git documentation.
///
/// For more information about the accepted syntax, see:
/// * [git-rev-parse documentation](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions)
/// * `man gitrevisions`
///
/// The returned [git_revspec] structure should be freed when no longer needed.
///
/// Throws a [LibGit2Error] if an error occurs during parsing.
///
/// Example:
/// ```dart
/// final revspec = revParse(
///   repoPointer: repo.pointer,
///   spec: 'HEAD~1',
/// );
/// ```
Pointer<git_revspec> revParse({
  required Pointer<git_repository> repoPointer,
  required String spec,
}) {
  return using((arena) {
    final out = calloc<git_revspec>();
    final specC = spec.toChar(arena);

    final error = libgit2.git_revparse(out, repoPointer, specC);
    checkErrorAndThrow(error);
    return out;
  });
}

/// Parses a revision string and returns a single object.
///
/// This function parses a revision string and returns a single object. The
/// revision string can be in various formats as described in the git documentation.
///
/// For more information about the accepted syntax, see:
/// * [git-rev-parse documentation](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions)
/// * `man gitrevisions`
///
/// The returned object should be freed when no longer needed.
///
/// Throws a [LibGit2Error] if an error occurs during parsing.
///
/// Example:
/// ```dart
/// final object = revParseSingle(
///   repoPointer: repo.pointer,
///   spec: 'HEAD~1',
/// );
/// ```
Pointer<git_object> revParseSingle({
  required Pointer<git_repository> repoPointer,
  required String spec,
}) {
  return using((arena) {
    final out = arena<Pointer<git_object>>();
    final specC = spec.toChar(arena);

    final error = libgit2.git_revparse_single(out, repoPointer, specC);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Parses a revision string and returns extended information.
///
/// This function parses a revision string and returns extended information about
/// the parsed objects. The revision string can be in various formats as described
/// in the git documentation.
///
/// For more information about the accepted syntax, see:
/// * [git-rev-parse documentation](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions)
/// * `man gitrevisions`
///
/// The returned objects should be freed when no longer needed.
///
/// Throws a [LibGit2Error] if an error occurs during parsing.
///
/// Example:
/// ```dart
/// final (object, reference) = revParseExt(
///   repoPointer: repo.pointer,
///   spec: 'HEAD~1',
/// );
/// ```
(Pointer<git_object>?, Pointer<git_reference>?) revParseExt({
  required Pointer<git_repository> repoPointer,
  required String spec,
}) {
  return using((arena) {
    final objOut = arena<Pointer<git_object>>();
    final refOut = arena<Pointer<git_reference>>();
    final specC = spec.toChar(arena);

    final error = libgit2.git_revparse_ext(objOut, refOut, repoPointer, specC);
    checkErrorAndThrow(error);

    final obj = objOut.value;
    final ref = refOut.value;

    return (obj == nullptr ? null : obj, ref == nullptr ? null : ref);
  });
}
