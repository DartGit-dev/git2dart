import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Add in-memory ignore [rules] to [repoPointer].
void addRule({
  required Pointer<git_repository> repoPointer,
  required String rules,
}) {
  using((arena) {
    final rulesC = rules.toChar(arena);
    final error = libgit2.git_ignore_add_rule(repoPointer, rulesC);

    checkErrorAndThrow(error);
  });
}

/// Clear in-memory ignore rules for [repoPointer].
void clearInternalRules(Pointer<git_repository> repoPointer) {
  final error = libgit2.git_ignore_clear_internal_rules(repoPointer);

  checkErrorAndThrow(error);
}

/// Return whether [path] is ignored by repository ignore rules.
bool pathIsIgnored({
  required Pointer<git_repository> repoPointer,
  required String path,
}) {
  return using((arena) {
    final ignored = arena<Int>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_ignore_path_is_ignored(
      ignored,
      repoPointer,
      pathC,
    );

    checkErrorAndThrow(error);
    return ignored.value == 1;
  });
}
