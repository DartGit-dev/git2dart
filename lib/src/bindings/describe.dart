import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Describe a commit. The returned describe result must be freed with [free].
///
/// Perform the describe operation on the given committish object.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_describe_result> commit({
  required Pointer<git_commit> commitPointer,
  int? maxCandidatesTags,
  int? describeStrategy,
  String? pattern,
  bool? onlyFollowFirstParent,
  bool? showCommitOidAsFallback,
}) {
  return using((arena) {
    final out = arena<Pointer<git_describe_result>>();
    final opts = _initOpts(
      arena: arena,
      maxCandidatesTags: maxCandidatesTags,
      describeStrategy: describeStrategy,
      pattern: pattern,
      onlyFollowFirstParent: onlyFollowFirstParent,
      showCommitOidAsFallback: showCommitOidAsFallback,
    );

    final error = libgit2.git_describe_commit(out, commitPointer.cast(), opts);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Describe a commit. The returned describe result must be freed with [free].
///
/// Perform the describe operation on the current commit and the worktree.
/// After peforming describe on HEAD, a status is run and the description is
/// considered to be dirty if there are.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_describe_result> workdir({
  required Pointer<git_repository> repo,
  int? maxCandidatesTags,
  int? describeStrategy,
  String? pattern,
  bool? onlyFollowFirstParent,
  bool? showCommitOidAsFallback,
}) {
  return using((arena) {
    final out = arena<Pointer<git_describe_result>>();
    final opts = _initOpts(
      arena: arena,
      maxCandidatesTags: maxCandidatesTags,
      describeStrategy: describeStrategy,
      pattern: pattern,
      onlyFollowFirstParent: onlyFollowFirstParent,
      showCommitOidAsFallback: showCommitOidAsFallback,
    );

    final error = libgit2.git_describe_workdir(out, repo, opts);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Print the describe result to a buffer.
String format({
  required Pointer<git_describe_result> describeResultPointer,
  int? abbreviatedSize,
  bool? alwaysUseLongFormat,
  String? dirtySuffix,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final opts = arena<git_describe_format_options>();
    libgit2.git_describe_format_options_init(
      opts,
      GIT_DESCRIBE_FORMAT_OPTIONS_VERSION,
    );

    if (abbreviatedSize != null) {
      opts.ref.abbreviated_size = abbreviatedSize;
    }
    if (alwaysUseLongFormat != null) {
      opts.ref.always_use_long_format = alwaysUseLongFormat ? 1 : 0;
    }
    if (dirtySuffix != null) {
      opts.ref.dirty_suffix = dirtySuffix.toChar(arena);
    }

    final error = libgit2.git_describe_format(out, describeResultPointer, opts);
    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);

    return result;
  });
}

/// Free the describe result.
void free(Pointer<git_describe_result> result) {
  libgit2.git_describe_result_free(result);
}

/// Initialize git_describe_options structure.
Pointer<git_describe_options> _initOpts({
  required Arena arena,
  int? maxCandidatesTags,
  int? describeStrategy,
  String? pattern,
  bool? onlyFollowFirstParent,
  bool? showCommitOidAsFallback,
}) {
  final opts = calloc<git_describe_options>();
  libgit2.git_describe_options_init(opts, GIT_DESCRIBE_OPTIONS_VERSION);

  if (maxCandidatesTags != null) {
    opts.ref.max_candidates_tags = maxCandidatesTags;
  }
  if (describeStrategy != null) {
    opts.ref.describe_strategy = describeStrategy;
  }
  if (pattern != null) {
    opts.ref.pattern = pattern.toChar(arena);
  }
  if (onlyFollowFirstParent != null) {
    opts.ref.only_follow_first_parent = onlyFollowFirstParent ? 1 : 0;
  }
  if (showCommitOidAsFallback != null) {
    opts.ref.show_commit_oid_as_fallback = showCommitOidAsFallback ? 1 : 0;
  }

  return opts;
}

/// Allocate and initialize `git_describe_options` with optional fields.
Pointer<git_describe_options> initOptions({
  int? maxCandidatesTags,
  int? describeStrategy,
  String? pattern,
  bool? onlyFollowFirstParent,
  bool? showCommitOidAsFallback,
}) {
  return using((arena) {
    final opts = _initOpts(
      arena: arena,
      maxCandidatesTags: maxCandidatesTags,
      describeStrategy: describeStrategy,
      pattern: pattern,
      onlyFollowFirstParent: onlyFollowFirstParent,
      showCommitOidAsFallback: showCommitOidAsFallback,
    );
    // Ownership of opts is transferred to caller
    return opts; // allocated with calloc
  });
}

/// Allocate and initialize `git_describe_format_options` with optional fields.
Pointer<git_describe_format_options> initFormatOptions({
  int? abbreviatedSize,
  bool? alwaysUseLongFormat,
  String? dirtySuffix,
}) {
  return using((arena) {
    final opts = arena<git_describe_format_options>();
    libgit2.git_describe_format_options_init(
      opts,
      GIT_DESCRIBE_FORMAT_OPTIONS_VERSION,
    );

    if (abbreviatedSize != null) {
      opts.ref.abbreviated_size = abbreviatedSize;
    }
    if (alwaysUseLongFormat != null) {
      opts.ref.always_use_long_format = alwaysUseLongFormat ? 1 : 0;
    }
    if (dirtySuffix != null) {
      opts.ref.dirty_suffix = dirtySuffix.toChar(arena);
    }

    return opts;
  });
}

/// Format a describe result into a string.
///
/// The returned string must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
String formatString({
  required Pointer<git_describe_result> resultPointer,
  required Pointer<git_describe_format_options> options,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_describe_format(out, resultPointer, options);
    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);

    return result;
  });
}
