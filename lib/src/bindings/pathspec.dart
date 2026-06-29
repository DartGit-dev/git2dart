// coverage:ignore-file
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

Pointer<git_strarray> _strArray(Arena arena, List<String> patterns) {
  final result = arena<git_strarray>();
  final strings = arena<Pointer<Char>>(patterns.length);

  for (var i = 0; i < patterns.length; i++) {
    strings[i] = patterns[i].toChar(arena);
  }

  result.ref.count = patterns.length;
  result.ref.strings = strings;
  return result;
}

/// Compile [patterns] into a pathspec. The returned pointer must be freed.
Pointer<git_pathspec> create(List<String> patterns) {
  return using((arena) {
    final out = arena<Pointer<git_pathspec>>();
    final patternsC = _strArray(arena, patterns);
    final error = libgit2.git_pathspec_new(out, patternsC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Return whether [path] matches [pathspecPointer].
bool matchesPath({
  required Pointer<git_pathspec> pathspecPointer,
  required String path,
  required int flags,
}) {
  return using((arena) {
    final pathC = path.toChar(arena);
    return libgit2.git_pathspec_matches_path(pathspecPointer, flags, pathC) ==
        1;
  });
}

/// Match [pathspecPointer] against [repoPointer]'s workdir.
Pointer<git_pathspec_match_list> matchWorkdir({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_pathspec> pathspecPointer,
  required int flags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_pathspec_match_list>>();
    final error = libgit2.git_pathspec_match_workdir(
      out,
      repoPointer,
      flags,
      pathspecPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Match [pathspecPointer] against [indexPointer].
Pointer<git_pathspec_match_list> matchIndex({
  required Pointer<git_index> indexPointer,
  required Pointer<git_pathspec> pathspecPointer,
  required int flags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_pathspec_match_list>>();
    final error = libgit2.git_pathspec_match_index(
      out,
      indexPointer,
      flags,
      pathspecPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Match [pathspecPointer] against [treePointer].
Pointer<git_pathspec_match_list> matchTree({
  required Pointer<git_tree> treePointer,
  required Pointer<git_pathspec> pathspecPointer,
  required int flags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_pathspec_match_list>>();
    final error = libgit2.git_pathspec_match_tree(
      out,
      treePointer,
      flags,
      pathspecPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Match [pathspecPointer] against [diffPointer].
Pointer<git_pathspec_match_list> matchDiff({
  required Pointer<git_diff> diffPointer,
  required Pointer<git_pathspec> pathspecPointer,
  required int flags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_pathspec_match_list>>();
    final error = libgit2.git_pathspec_match_diff(
      out,
      diffPointer,
      flags,
      pathspecPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Return matched paths from [matchListPointer].
List<String> entries(Pointer<git_pathspec_match_list> matchListPointer) {
  final count = libgit2.git_pathspec_match_list_entrycount(matchListPointer);
  return <String>[
    for (var i = 0; i < count; i++)
      libgit2.git_pathspec_match_list_entry(matchListPointer, i).toDartString(),
  ];
}

/// Return unmatched patterns from [matchListPointer].
List<String> failedEntries(Pointer<git_pathspec_match_list> matchListPointer) {
  final count = libgit2.git_pathspec_match_list_failed_entrycount(
    matchListPointer,
  );
  return <String>[
    for (var i = 0; i < count; i++)
      libgit2
          .git_pathspec_match_list_failed_entry(matchListPointer, i)
          .toDartString(),
  ];
}

/// Free a pathspec match list.
void freeMatchList(Pointer<git_pathspec_match_list> matchList) {
  libgit2.git_pathspec_match_list_free(matchList);
}

/// Free a pathspec.
void free(Pointer<git_pathspec> pathspec) {
  libgit2.git_pathspec_free(pathspec);
}
