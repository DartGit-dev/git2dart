import 'dart:ffi';

import 'package:ffi/ffi.dart' show using;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Get the source specifier.
String source(Pointer<git_refspec> refspec) =>
    libgit2.git_refspec_src(refspec).toDartString();

/// Get the destination specifier.
String destination(Pointer<git_refspec> refspec) =>
    libgit2.git_refspec_dst(refspec).toDartString();

/// Get the force update setting.
bool force(Pointer<git_refspec> refspec) =>
    libgit2.git_refspec_force(refspec) == 1;

/// Get the refspec's string.
String string(Pointer<git_refspec> refspec) =>
    libgit2.git_refspec_string(refspec).toDartString();

/// Get the refspec's direction.
git_direction direction(Pointer<git_refspec> refspec) =>
    libgit2.git_refspec_direction(refspec);

/// Check if a refspec's source descriptor matches a reference.
bool matchesSource({
  required Pointer<git_refspec> refspecPointer,
  required String refname,
}) {
  return using((arena) {
    final refnameC = refname.toChar(arena);
    return libgit2.git_refspec_src_matches(refspecPointer, refnameC) == 1;
  });
}

/// Check if a refspec's destination descriptor matches a reference.
bool matchesDestination({
  required Pointer<git_refspec> refspecPointer,
  required String refname,
}) {
  return using((arena) {
    final refnameC = refname.toChar(arena);
    return libgit2.git_refspec_dst_matches(refspecPointer, refnameC) == 1;
  });
}

/// Transform a reference to its target following the refspec's rules.
///
/// Throws a [LibGit2Error] if error occured.
String transform({
  required Pointer<git_refspec> refspecPointer,
  required String name,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_refspec_transform(out, refspecPointer, nameC);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Transform a target reference to its source reference following the
/// refspec's rules.
///
/// Throws a [LibGit2Error] if error occured.
String rTransform({
  required Pointer<git_refspec> refspecPointer,
  required String name,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_refspec_rtransform(out, refspecPointer, nameC);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}
