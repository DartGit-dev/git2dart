import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/error.dart';
import 'package:git2dart/src/extensions.dart';
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
  final out = calloc<git_revspec>();
  final specC = spec.toChar();

  final error = libgit2.git_revparse(out, repoPointer, specC);

  calloc.free(specC);

  if (error < 0) {
    calloc.free(out);
    throw LibGit2Error(libgit2.git_error_last());
  }

  return out;
}

/// Finds a single object as specified by a revision string.
///
/// This function parses a revision string and returns the corresponding git object.
/// The revision string can be in various formats as described in the git documentation.
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
///   spec: 'HEAD',
/// );
/// ```
Pointer<git_object> revParseSingle({
  required Pointer<git_repository> repoPointer,
  required String spec,
}) {
  final out = calloc<Pointer<git_object>>();
  final specC = spec.toChar();

  final error = libgit2.git_revparse_single(out, repoPointer, specC);

  final result = out.value;

  calloc.free(out);
  calloc.free(specC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }

  return result;
}

/// Finds a single object and intermediate reference by a revision string.
///
/// This function parses a revision string and returns both the corresponding git object
/// and any intermediate reference. This is particularly useful for expressions like
/// `@{<-n>}` or `<branchname>@{upstream}` where an intermediate reference is involved.
///
/// For more information about the accepted syntax, see:
/// * [git-rev-parse documentation](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions)
/// * `man gitrevisions`
///
/// The returned object and reference (if present) should be freed when no longer needed.
///
/// Returns a list containing:
/// * The git object pointer at index 0
/// * The reference pointer at index 1 (if present)
///
/// Throws a [LibGit2Error] if an error occurs during parsing.
///
/// Example:
/// ```dart
/// final results = revParseExt(
///   repoPointer: repo.pointer,
///   spec: 'master@{upstream}',
/// );
/// final object = results[0];
/// final reference = results.length > 1 ? results[1] : null;
/// ```
List<Pointer> revParseExt({
  required Pointer<git_repository> repoPointer,
  required String spec,
}) {
  final objectOut = calloc<Pointer<git_object>>();
  final referenceOut = calloc<Pointer<git_reference>>();
  final specC = spec.toChar();

  final error = libgit2.git_revparse_ext(
    objectOut,
    referenceOut,
    repoPointer,
    specC,
  );

  final result = <Pointer>[objectOut.value];
  if (referenceOut.value != nullptr) {
    result.add(referenceOut.value);
  }

  calloc.free(objectOut);
  calloc.free(referenceOut);
  calloc.free(specC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }

  return result;
}
