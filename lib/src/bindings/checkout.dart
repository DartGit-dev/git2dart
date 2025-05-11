import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Updates files in the index and the working tree to match the content of the
/// commit pointed at by HEAD.
///
/// Note that this is not the correct mechanism used to switch branches; do not
/// change your HEAD and then call this method, that would leave you with
/// checkout conflicts since your working directory would then appear to be
/// dirty. Instead, checkout the target of the branch and then update HEAD
/// using [setHead] to point to the branch you checked out.
///
/// Throws a [LibGit2Error] if error occurred.
void head({
  required Pointer<git_repository> repoPointer,
  required int strategy,
  String? directory,
  List<String>? paths,
}) {
  final initOpts = initOptions(
    strategy: strategy,
    directory: directory,
    paths: paths,
  );
  final optsC = initOpts[0] as Pointer<git_checkout_options>;
  final pathPointers = initOpts[1] as List<Pointer<Char>>;
  final strArray = initOpts[2] as Pointer<Pointer<Char>>;

  try {
    final error = libgit2.git_checkout_head(repoPointer, optsC);

    if (error < 0) {
      throw LibGit2Error(libgit2.git_error_last());
    }
  } finally {
    for (final p in pathPointers) {
      calloc.free(p);
    }
    calloc.free(strArray);
    calloc.free(optsC);
  }
}

/// Updates files in the working tree to match the content of the index.
///
/// Throws a [LibGit2Error] if error occurred.
void index({
  required Pointer<git_repository> repoPointer,
  required int strategy,
  String? directory,
  List<String>? paths,
}) {
  final initOpts = initOptions(
    strategy: strategy,
    directory: directory,
    paths: paths,
  );
  final optsC = initOpts[0] as Pointer<git_checkout_options>;
  final pathPointers = initOpts[1] as List<Pointer<Char>>;
  final strArray = initOpts[2] as Pointer<Pointer<Char>>;

  try {
    final error = libgit2.git_checkout_index(repoPointer, nullptr, optsC);

    if (error < 0) {
      throw LibGit2Error(libgit2.git_error_last());
    }
  } finally {
    for (final p in pathPointers) {
      calloc.free(p);
    }
    calloc.free(strArray);
    calloc.free(optsC);
  }
}

/// Updates files in the index and working tree to match the content of the tree
/// pointed at by the treeish.
///
/// Throws a [LibGit2Error] if error occurred.
void tree({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_object> treeishPointer,
  required int strategy,
  String? directory,
  List<String>? paths,
}) {
  final initOpts = initOptions(
    strategy: strategy,
    directory: directory,
    paths: paths,
  );
  final optsC = initOpts[0] as Pointer<git_checkout_options>;
  final pathPointers = initOpts[1] as List<Pointer<Char>>;
  final strArray = initOpts[2] as Pointer<Pointer<Char>>;

  try {
    final error = libgit2.git_checkout_tree(repoPointer, treeishPointer, optsC);

    if (error < 0) {
      throw LibGit2Error(libgit2.git_error_last());
    }
  } finally {
    for (final p in pathPointers) {
      calloc.free(p);
    }
    calloc.free(strArray);
    calloc.free(optsC);
  }
}

/// Initialize checkout options with the given parameters.
///
/// Returns a list containing:
/// - [0]: Pointer to checkout options
/// - [1]: List of path pointers that need to be freed
/// - [2]: String array pointer that needs to be freed
List<Object> initOptions({
  required int strategy,
  String? directory,
  List<String>? paths,
}) {
  final optsC = calloc<git_checkout_options>();
  libgit2.git_checkout_options_init(optsC, GIT_CHECKOUT_OPTIONS_VERSION);

  optsC.ref.checkout_strategy = strategy;

  if (directory != null) {
    optsC.ref.target_directory = directory.toChar();
  }

  var pathPointers = <Pointer<Char>>[];
  Pointer<Pointer<Char>> strArray = nullptr;
  if (paths != null) {
    pathPointers = paths.map((e) => e.toChar()).toList();
    strArray = calloc(paths.length);
    for (var i = 0; i < paths.length; i++) {
      strArray[i] = pathPointers[i];
    }
    optsC.ref.paths.strings = strArray;
    optsC.ref.paths.count = paths.length;
  }

  return [optsC, pathPointers, strArray];
}
