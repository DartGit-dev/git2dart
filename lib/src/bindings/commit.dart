import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Lookup a commit object from a repository. The returned commit must be
/// freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_commit> lookup({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_commit>>();

    final error = libgit2.git_commit_lookup(out, repoPointer, oidPointer);
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Lookup a commit object from a repository by its short [oid].
/// The returned commit must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_commit> lookupPrefix({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> oidPointer,
  required int len,
}) {
  return using((arena) {
    final out = arena<Pointer<git_commit>>();
    final error =
        libgit2.git_commit_lookup_prefix(out, repoPointer, oidPointer, len);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create new commit in the repository.
///
/// The [message] will not be cleaned up automatically. I.e. excess whitespace
/// will not be removed and no trailing newline will be added.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> create({
  required Pointer<git_repository> repoPointer,
  required String updateRef,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  String? messageEncoding,
  required String message,
  required Pointer<git_tree> treePointer,
  required int parentCount,
  required List<Pointer<git_commit>> parents,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final updateRefC = updateRef.toChar(arena);
    final messageEncodingC = messageEncoding?.toChar(arena) ?? nullptr;
    final messageC = message.toChar(arena);
    final parentsC = arena<Pointer<git_commit>>(parentCount);

    if (parents.isNotEmpty) {
      for (var i = 0; i < parentCount; i++) {
        parentsC[i] = parents[i];
      }
    } else {
      parentsC[0] = nullptr;
    }

    final error = libgit2.git_commit_create(
      out,
      repoPointer,
      updateRefC,
      authorPointer,
      committerPointer,
      messageEncodingC,
      messageC,
      treePointer,
      parentCount,
      parentsC,
    );

    checkErrorAndThrow(error);

    return out;
  });
}

/// Create a commit and write it into a buffer.
///
/// Create a commit as with [create] but instead of writing it to the objectdb,
/// write the contents of the object into a buffer.
///
/// Throws a [LibGit2Error] if error occured.
String createBuffer({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  String? messageEncoding,
  required String message,
  required Pointer<git_tree> treePointer,
  required int parentCount,
  required List<Pointer<git_commit>> parents,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final messageEncodingC = messageEncoding?.toChar(arena) ?? nullptr;
    final messageC = message.toChar(arena);
    final parentsC = arena<Pointer<git_commit>>(parentCount);

    if (parents.isNotEmpty) {
      for (var i = 0; i < parentCount; i++) {
        parentsC[i] = parents[i];
      }
    } else {
      parentsC[0] = nullptr;
    }

    final error = libgit2.git_commit_create_buffer(
      out,
      repoPointer,
      authorPointer,
      committerPointer,
      messageEncodingC,
      messageC,
      treePointer,
      parentCount,
      parentsC,
    );

    checkErrorAndThrow(error);
    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Create a new commit with precomputed parent oids and tree oid.
/// The created commit will be written to the Object Database and the given
/// reference will be updated to point to it.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> createFromIds({
  required Pointer<git_repository> repoPointer,
  required String updateRef,
  required Pointer<git_signature> authorPointer,
  required Pointer<git_signature> committerPointer,
  String? messageEncoding,
  required String message,
  required Pointer<git_oid> treeOidPointer,
  required int parentCount,
  required List<Pointer<git_oid>> parents,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final updateRefC = updateRef.toChar(arena);
    final messageEncodingC = messageEncoding?.toChar(arena) ?? nullptr;
    final messageC = message.toChar(arena);
    final parentsC = arena<Pointer<git_oid>>(parentCount);

    if (parents.isNotEmpty) {
      for (var i = 0; i < parentCount; i++) {
        parentsC[i] = parents[i];
      }
    } else {
      parentsC[0] = nullptr;
    }

    final error = libgit2.git_commit_create_from_ids(
      out,
      repoPointer,
      updateRefC,
      authorPointer,
      committerPointer,
      messageEncodingC,
      messageC,
      treeOidPointer,
      parentCount,
      parentsC,
    );

    checkErrorAndThrow(error);
    return out;
  });
}

/// Create a new commit from a serialized commit content and signature.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> createWithSignature({
  required Pointer<git_repository> repoPointer,
  required String commitContent,
  String? signature,
  String? signatureField,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final commitContentC = commitContent.toChar(arena);
    final signatureC = signature?.toChar(arena) ?? nullptr;
    final fieldC = signatureField?.toChar(arena) ?? nullptr;

    final error = libgit2.git_commit_create_with_signature(
      out,
      repoPointer,
      commitContentC,
      signatureC,
      fieldC,
    );

    checkErrorAndThrow(error);
    return out;
  });
}

/// Extract the signature and signed data from a commit.
///
/// Throws a [LibGit2Error] if error occured.
MapEntry<String, String> extractSignature({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> commitOid,
  String? field,
}) {
  return using((arena) {
    final signatureOut = arena<git_buf>();
    final signedDataOut = arena<git_buf>();
    final fieldC = field?.toChar(arena) ?? nullptr;

    final error = libgit2.git_commit_extract_signature(
      signatureOut,
      signedDataOut,
      repoPointer,
      commitOid,
      fieldC,
    );

    checkErrorAndThrow(error);

    final signatureStr =
        signatureOut.ref.ptr.toDartString(length: signatureOut.ref.size);
    final signedDataStr =
        signedDataOut.ref.ptr.toDartString(length: signedDataOut.ref.size);
    return MapEntry(signatureStr, signedDataStr);
  });
}

/// Amend an existing commit by replacing only non-null values.
///
/// This creates a new commit that is exactly the same as the old commit,
/// except that any non-null values will be updated. The new commit has the
/// same parents as the old commit.
///
/// The [updateRef] value works as in the regular [create], updating the ref to
/// point to the newly rewritten commit. If you want to amend a commit that is
/// not currently the tip of the branch and then rewrite the following commits
/// to reach a ref, pass this as null and update the rest of the commit chain
/// and ref separately.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_oid> amend({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> commitPointer,
  String? updateRef,
  required Pointer<git_signature>? authorPointer,
  required Pointer<git_signature>? committerPointer,
  String? messageEncoding,
  String? message,
  required Pointer<git_tree>? treePointer,
}) {
  return using((arena) {
    final out = calloc<git_oid>();
    final updateRefC = updateRef?.toChar(arena) ?? nullptr;
    final messageEncodingC = messageEncoding?.toChar(arena) ?? nullptr;
    final messageC = message?.toChar(arena) ?? nullptr;

    final error = libgit2.git_commit_amend(
      out,
      commitPointer,
      updateRefC,
      authorPointer ?? nullptr,
      committerPointer ?? nullptr,
      messageEncodingC,
      messageC,
      treePointer ?? nullptr,
    );

    checkErrorAndThrow(error);
    return out;
  });
}

/// Create an in-memory copy of a commit. The returned copy must be
/// freed with [free].
Pointer<git_commit> duplicate(Pointer<git_commit> source) {
  return using((arena) {
    final out = arena<Pointer<git_commit>>();

    libgit2.git_commit_dup(out, source);

    return out.value;
  });
}

/// Get the encoding for the message of a commit, as a string representing a
/// standard encoding name.
///
/// If the encoding header in the commit is missing UTF-8 is assumed.
String messageEncoding(Pointer<git_commit> commit) {
  final result = libgit2.git_commit_message_encoding(commit);
  return result == nullptr ? 'utf-8' : result.toDartString();
}

/// Get the full message of a commit.
///
/// The returned message will be slightly prettified by removing any potential
/// leading newlines.
String message(Pointer<git_commit> commit) {
  return libgit2.git_commit_message(commit).toDartString();
}

/// Get the short "summary" of the git commit message.
///
/// The returned message is the summary of the commit, comprising the first
/// paragraph of the message with whitespace trimmed and squashed.
///
/// Throws a [LibGit2Error] if error occured.
String summary(Pointer<git_commit> commit) {
  final result = libgit2.git_commit_summary(commit);

  if (result == nullptr) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result.toDartString();
  }
}

/// Get the long "body" of the git commit message.
///
/// The returned message is the body of the commit, comprising everything but
/// the first paragraph of the message. Leading and trailing whitespaces are
/// trimmed.
String body(Pointer<git_commit> commit) {
  final result = libgit2.git_commit_body(commit);
  return result == nullptr ? '' : result.toDartString();
}

/// Get an arbitrary header field.
///
/// Throws a [LibGit2Error] if error occured.
String headerField({
  required Pointer<git_commit> commitPointer,
  required String field,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final fieldC = field.toChar(arena);

    final error = libgit2.git_commit_header_field(out, commitPointer, fieldC);
    checkErrorAndThrow(error);

    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Get the id of a commit.
Pointer<git_oid> id(Pointer<git_commit> commit) =>
    libgit2.git_commit_id(commit);

/// Get the number of parents of this commit.
int parentCount(Pointer<git_commit> commit) =>
    libgit2.git_commit_parentcount(commit);

/// Get the oid of a specified parent for a commit.
Pointer<git_oid> parentId({
  required Pointer<git_commit> commitPointer,
  required int position,
}) {
  return libgit2.git_commit_parent_id(commitPointer, position);
}

/// Get the specified parent of the commit (0-based).
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_commit> parent({
  required Pointer<git_commit> commitPointer,
  required int position,
}) {
  return using((arena) {
    final out = arena<Pointer<git_commit>>();
    final error = libgit2.git_commit_parent(out, commitPointer, position);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the commit object that is the nth generation ancestor of the named
/// commit object, following only the first parents. The returned commit must
/// be freed with [free].
///
/// Passing 0 as the generation number returns another instance of the base
/// commit itself.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_commit> nthGenAncestor({
  required Pointer<git_commit> commitPointer,
  required int n,
}) {
  return using((arena) {
    final out = arena<Pointer<git_commit>>();
    final error = libgit2.git_commit_nth_gen_ancestor(out, commitPointer, n);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get the commit time (i.e. committer time) of a commit.
int time(Pointer<git_commit> commit) => libgit2.git_commit_time(commit);

/// Get the commit timezone offset in minutes (i.e. committer's preferred
/// timezone) of a commit.
int timeOffset(Pointer<git_commit> commit) =>
    libgit2.git_commit_time_offset(commit);

/// Get the committer of a commit.
Pointer<git_signature> committer(Pointer<git_commit> commit) =>
    libgit2.git_commit_committer(commit);

/// Get the author of a commit.
///
/// The returned signature must be freed.
Pointer<git_signature> author(Pointer<git_commit> commit) =>
    libgit2.git_commit_author(commit);

/// Get the id of the tree pointed to by a commit.
Pointer<git_oid> treeOid(Pointer<git_commit> commit) =>
    libgit2.git_commit_tree_id(commit);

/// Get the tree pointed to by a commit.
///
/// The returned tree must be freed.
Pointer<git_tree> tree(Pointer<git_commit> commit) {
  return using((arena) {
    final out = arena<Pointer<git_tree>>();
    libgit2.git_commit_tree(out, commit);
    return out.value;
  });
}

/// Reverts the given commit, producing changes in the index and working
/// directory.
///
/// Throws a [LibGit2Error] if error occured.
void revert({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> commitPointer,
  required int mainline,
  int? mergeFavor,
  int? mergeFlags,
  int? mergeFileFlags,
  int? checkoutStrategy,
  String? checkoutDirectory,
  List<String>? checkoutPaths,
}) {
  using((arena) {
    final opts = arena<git_revert_options>();
    libgit2.git_revert_options_init(opts, GIT_REVERT_OPTIONS_VERSION);

    opts.ref.mainline = mainline;

    if (mergeFavor != null) opts.ref.merge_opts.file_favorAsInt = mergeFavor;
    if (mergeFlags != null) opts.ref.merge_opts.flags = mergeFlags;
    if (mergeFileFlags != null) opts.ref.merge_opts.file_flags = mergeFileFlags;

    if (checkoutStrategy != null) {
      opts.ref.checkout_opts.checkout_strategy = checkoutStrategy;
    }
    if (checkoutDirectory != null) {
      opts.ref.checkout_opts.target_directory = checkoutDirectory.toChar(arena);
    }

    Pointer<Pointer<Char>> strArray = nullptr;
    if (checkoutPaths != null) {
      final pathPointers = checkoutPaths.map((e) => e.toChar(arena)).toList();
      strArray = arena(checkoutPaths.length);
      for (var i = 0; i < checkoutPaths.length; i++) {
        strArray[i] = pathPointers[i];
      }
      opts.ref.checkout_opts.paths.strings = strArray;
      opts.ref.checkout_opts.paths.count = checkoutPaths.length;
    }

    final error = libgit2.git_revert(repoPointer, commitPointer, opts);

    checkErrorAndThrow(error);
  });
}

/// Reverts the given commit against the given "our" commit, producing an index
/// that reflects the result of the revert.
///
/// The returned index must be freed.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_index> revertCommit({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_commit> revertCommitPointer,
  required Pointer<git_commit> ourCommitPointer,
  required int mainline,
  int? mergeFavor,
  int? mergeFlags,
  int? mergeFileFlags,
}) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final opts = arena<git_merge_options>();
    libgit2.git_merge_options_init(opts, GIT_MERGE_OPTIONS_VERSION);

    if (mergeFavor != null) opts.ref.file_favorAsInt = mergeFavor;
    if (mergeFlags != null) opts.ref.flags = mergeFlags;
    if (mergeFileFlags != null) opts.ref.file_flags = mergeFileFlags;

    final error = libgit2.git_revert_commit(
      out,
      repoPointer,
      revertCommitPointer,
      ourCommitPointer,
      mainline,
      opts,
    );
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the repository that contains the commit.
Pointer<git_repository> owner(Pointer<git_commit> commit) =>
    libgit2.git_commit_owner(commit);

/// Close an open commit to release memory.
void free(Pointer<git_commit> commit) => libgit2.git_commit_free(commit);
