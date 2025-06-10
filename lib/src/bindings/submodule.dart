import 'dart:ffi';

import 'package:ffi/ffi.dart' show using;
import 'package:git2dart/src/bindings/remote_callbacks.dart';
import 'package:git2dart/src/callbacks.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// List of submodule paths.
///
/// IMPORTANT: make sure to clear that list since it's a global variable.
List<String> _pathsList = [];

/// Function to be called with the name of each submodule.
///
/// Returns 0 on success, non-zero to abort iteration.
int _listCb(
  Pointer<git_submodule> submodule,
  Pointer<Char> name,
  Pointer<Void> payload,
) {
  _pathsList.add(path(submodule));
  return 0;
}

/// Returns a list with all tracked submodules paths of a repository.
///
/// This function queries the repository's configuration to find all submodules
/// that have been defined and added to the working copy.
List<String> list(Pointer<git_repository> repo) {
  const except = -1;
  final callback = Pointer.fromFunction<
    Int Function(Pointer<git_submodule>, Pointer<Char>, Pointer<Void>)
  >(_listCb, except);

  final error = libgit2.git_submodule_foreach(repo, callback, nullptr);
  checkErrorAndThrow(error);

  final result = _pathsList.toList(growable: false);
  _pathsList.clear();
  return result;
}

/// Lookup submodule information by name or path. The returned submodule must
/// be freed with [free].
///
/// Given either the submodule name or path (they are usually the same), this
/// returns a structure describing the submodule. The name is the name the
/// submodule was added with (usually the path).
///
/// There are two valid ways to specify the submodule you wish to look up:
/// - By name: the name with which the submodule was added to the working copy
/// - By path: the path to the submodule's contents, relative to the repository root
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_submodule> lookup({
  required Pointer<git_repository> repoPointer,
  required String name,
}) {
  return using((arena) {
    final out = arena<Pointer<git_submodule>>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_submodule_lookup(out, repoPointer, nameC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Copy submodule info into `.git/config` file.
///
/// Just like `git submodule init`, this copies information about the
/// submodule into `.git/config`. You can run this command on a submodule
/// that has already been initialized, to update the stored URL, for instance.
///
/// By default, existing entries will not be overwritten, but setting
/// [overwrite] to true forces them to be updated.
///
/// This is a legacy command: prefer using [update] with init flag set to true.
void init({
  required Pointer<git_submodule> submodulePointer,
  bool overwrite = false,
}) {
  final overwriteC = overwrite ? 1 : 0;
  final error = libgit2.git_submodule_init(submodulePointer, overwriteC);

  checkErrorAndThrow(error);
}

/// Update a submodule's working directory to the commit specified in the index
/// of the containing repository.
///
/// If the submodule is not initialized, setting [init] to true will initialize
/// it first. Otherwise, this will return an error if attempting to update an
/// uninitialized repository.
///
/// The submodule's repository will be cloned if it is missing and the remote
/// will be fetched into if it doesn't contain the target commit. The callbacks
/// provided in [callbacks] will be used for repository access and reporting
/// progress.
///
/// After a successful update, the submodule's HEAD will be detached at the
/// commit found in the index.
///
/// Throws a [LibGit2Error] if error occurred.
void update({
  required Pointer<git_submodule> submodulePointer,
  bool init = false,
  required Callbacks callbacks,
}) {
  return using((arena) {
    final initC = init ? 1 : 0;
    final options = arena<git_submodule_update_options>();
    libgit2.git_submodule_update_options_init(
      options,
      GIT_SUBMODULE_UPDATE_OPTIONS_VERSION,
    );

    RemoteCallbacks.plug(
      callbacksOptions: options.ref.fetch_opts.callbacks,
      callbacks: callbacks,
    );

    final error = libgit2.git_submodule_update(
      submodulePointer,
      initC,
      options,
    );
    RemoteCallbacks.reset();

    checkErrorAndThrow(error);
  });
}

/// Open the repository for a submodule.
///
/// This is a newly opened repository object that must be freed by the caller
/// when done. Multiple calls to this function will return distinct repository
/// objects. This will only work if the submodule is checked out into the
/// working directory.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_repository> open(Pointer<git_submodule> submodule) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final error = libgit2.git_submodule_open(out, submodule);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Set up a new git submodule for checkout. The returned submodule must be
/// freed with [free].
///
/// This does `git submodule add` up to the fetch and checkout of the submodule
/// contents. It:
/// - Adds an entry to ".gitmodules" for the submodule
/// - Creates an empty initialized repository either at the given path in the
///   working directory or in ".git/modules" with a gitlink from the working
///   directory to the new repo
/// - Sets up the submodule's configuration in .git/config
///
/// You can then call [clone] to perform the clone step and [addFinalize] to
/// complete the module addition.
///
/// The [useGitlink] parameter controls whether the gitlink repository should
/// be used or if the repository should be created in the working directory.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_submodule> addSetup({
  required Pointer<git_repository> repoPointer,
  required String url,
  required String path,
  bool useGitlink = true,
}) {
  return using((arena) {
    final out = arena<Pointer<git_submodule>>();
    final urlC = url.toChar(arena);
    final pathC = path.toChar(arena);
    final useGitlinkC = useGitlink ? 1 : 0;
    final error = libgit2.git_submodule_add_setup(
      out,
      repoPointer,
      urlC,
      pathC,
      useGitlinkC,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Duplicate an existing submodule object.
Pointer<git_submodule> duplicate(Pointer<git_submodule> source) {
  return using((arena) {
    final out = arena<Pointer<git_submodule>>();
    final error = libgit2.git_submodule_dup(out, source);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Resolve a URL relative to the submodule.
String resolveUrl({
  required Pointer<git_repository> repoPointer,
  required String url,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final urlC = url.toChar(arena);
    final error = libgit2.git_submodule_resolve_url(out, repoPointer, urlC);
    checkErrorAndThrow(error);
    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Perform the clone step for a newly created submodule.
///
/// This is used after calling [addSetup] to do the clone step for adding
/// a new submodule. The provided [callbacks] will be used for reporting clone
/// progress and authentication if required.
///
/// Throws a [LibGit2Error] if error occurred.
void clone({
  required Pointer<git_submodule> submodule,
  required Callbacks callbacks,
}) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final options = arena<git_submodule_update_options>();
    libgit2.git_submodule_update_options_init(
      options,
      GIT_SUBMODULE_UPDATE_OPTIONS_VERSION,
    );

    RemoteCallbacks.plug(
      callbacksOptions: options.ref.fetch_opts.callbacks,
      callbacks: callbacks,
    );

    final error = libgit2.git_submodule_clone(out, submodule, options);

    RemoteCallbacks.reset();

    checkErrorAndThrow(error);
  });
}

/// Resolve the setup of a new git submodule.
///
/// This should be called on a submodule once you have called [addSetup] and
/// done the clone step with [clone]. This adds the `.gitmodules` file and the
/// newly cloned submodule to the index to be ready to be committed.
///
/// If the gitmodules file or the newly cloned repo index entries exist in the
/// index, they will be updated. If they don't exist, they will be added.
///
/// Throws a [LibGit2Error] if error occurred.
void addFinalize(Pointer<git_submodule> submodule) {
  final error = libgit2.git_submodule_add_finalize(submodule);

  checkErrorAndThrow(error);
}

/// Get the status for a submodule.
///
/// This looks at a submodule and tries to determine the status. How deeply
/// it examines the working directory to do this will depend on the
/// combination of [GitSubmoduleIgnore] values provided to [ignore].
///
/// Throws a [LibGit2Error] if error occurred.
int status({
  required Pointer<git_repository> repoPointer,
  required String name,
  required git_submodule_ignore_t ignore,
}) {
  return using((arena) {
    final out = arena<UnsignedInt>();
    final nameC = name.toChar(arena);

    final error = libgit2.git_submodule_status(out, repoPointer, nameC, ignore);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get the ignore rule for a submodule.
///
/// Returns the ignore rule that will be used for the submodule.
git_submodule_ignore_t ignoreRule(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_ignore(submodule);

/// Set the ignore rule for a submodule.
///
/// This does not affect any currently-loaded instances.
void setIgnoreRule({
  required Pointer<git_repository> repoPointer,
  required String name,
  required git_submodule_ignore_t ignore,
}) {
  using((arena) {
    final nameC = name.toChar(arena);
    final error = libgit2.git_submodule_set_ignore(repoPointer, nameC, ignore);

    checkErrorAndThrow(error);
  });
}

/// Get the update rule for a submodule.
///
/// Returns the update rule that will be used for the submodule.
git_submodule_update_t updateRule(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_update_strategy(submodule);

/// Set the update rule for a submodule.
///
/// This setting won't affect any existing instances.
void setUpdateRule({
  required Pointer<git_repository> repoPointer,
  required String name,
  required git_submodule_update_t update,
}) {
  using((arena) {
    final nameC = name.toChar(arena);
    final error = libgit2.git_submodule_set_update(repoPointer, nameC, update);

    checkErrorAndThrow(error);
  });
}

/// Get the name of a submodule.
String name(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_name(submodule).toDartString();

/// Get the path of a submodule.
String path(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_path(submodule).toDartString();

/// Get the URL of a submodule.
String url(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_url(submodule).toDartString();

/// Set the URL for a submodule.
///
/// After calling this, you may wish to call [sync] to write the changes to
/// the checked out submodule repository.
void setUrl({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String url,
}) {
  using((arena) {
    final nameC = name.toChar(arena);
    final urlC = url.toChar(arena);
    final error = libgit2.git_submodule_set_url(repoPointer, nameC, urlC);

    checkErrorAndThrow(error);
  });
}

/// Get the branch of a submodule.
String branch(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_branch(submodule).toDartString();

/// Set the branch for a submodule.
///
/// After calling this, you may wish to call [sync] to write the changes to
/// the checked out submodule repository.
void setBranch({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String branch,
}) {
  using((arena) {
    final nameC = name.toChar(arena);
    final branchC = branch.toChar(arena);
    final error = libgit2.git_submodule_set_branch(repoPointer, nameC, branchC);

    checkErrorAndThrow(error);
  });
}

/// Get the OID of the submodule in the current HEAD tree.
///
/// Returns null if the submodule is not in the HEAD.
Pointer<git_oid>? headId(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_head_id(submodule);

/// Get the OID of the submodule in the index.
///
/// Returns null if the submodule is not in the index.
Pointer<git_oid>? indexId(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_index_id(submodule);

/// Get the OID of the submodule in the current working directory.
///
/// Returns null if the submodule is not checked out.
Pointer<git_oid>? workdirId(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_wd_id(submodule);

/// Get the repository that owns this submodule.
Pointer<git_repository> owner(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_owner(submodule);

/// Sync a submodule.
///
/// This copies the information about the submodules URL into the checked out
/// submodule config, acting like `git submodule sync`. This is useful if you
/// have altered the URL for the submodule (or it has been altered by a fetch
/// of upstream changes) and you need to update your local repo.
void sync({required Pointer<git_submodule> submodulePointer}) {
  final error = libgit2.git_submodule_sync(submodulePointer);
  checkErrorAndThrow(error);
}

/// Reread submodule info from config, index, and HEAD.
///
/// Call this to reread cached submodule information for this submodule if
/// you have reason to believe that it has changed.
///
/// Set [force] to true to reload even if the data doesn't seem out of date.
void reload({
  required Pointer<git_submodule> submodulePointer,
  bool force = false,
}) {
  final forceC = force ? 1 : 0;
  final error = libgit2.git_submodule_reload(submodulePointer, forceC);
  checkErrorAndThrow(error);
}

/// Free a submodule.
void free(Pointer<git_submodule> submodule) =>
    libgit2.git_submodule_free(submodule);
