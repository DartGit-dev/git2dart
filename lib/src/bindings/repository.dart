import 'dart:ffi';

import 'package:ffi/ffi.dart' show calloc, using;
import 'package:git2dart/src/bindings/remote_callbacks.dart';
import 'package:git2dart/src/callbacks.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart/src/remote.dart';
import 'package:git2dart/src/repository.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Open an existing Git repository at the specified path.
///
/// This function attempts to open a repository at the given [path], which can be
/// either a normal or bare repository. The repository must exist and be valid.
///
/// The returned repository must be freed with [free] when no longer needed.
///
/// Throws a [LibGit2Error] if the repository cannot be opened or is invalid.
Pointer<git_repository> open(String path) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_repository_open(out, pathC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Discover the path to a Git repository by walking up from [startPath].
///
/// This function searches for a Git repository starting from [startPath] and
/// walking up through parent directories until either:
/// - A repository is found
/// - A directory listed in [ceilingDirs] is reached
/// - The root directory is reached
///
/// Returns the absolute path to the discovered repository, or throws a
/// [LibGit2Error] if no repository is found.
String discover({required String startPath, String? ceilingDirs}) {
  return using((arena) {
    final out = arena<git_buf>();
    final startPathC = startPath.toChar(arena);
    final ceilingDirsC = ceilingDirs?.toChar(arena) ?? nullptr;

    final error = libgit2.git_repository_discover(
      out,
      startPathC,
      0,
      ceilingDirsC,
    );

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Initialize a new Git repository with the specified options.
///
/// Creates a new Git repository at [path] with the following options:
/// - [flags]: Repository initialization flags (e.g., bare, no_reinit)
/// - [mode]: Repository initialization mode (e.g., shared)
/// - [workdirPath]: Path to the working directory (for non-bare repos)
/// - [description]: Repository description
/// - [templatePath]: Path to the template directory
/// - [initialHead]: Name of the initial branch
/// - [originUrl]: URL of the origin remote
///
/// The returned repository must be freed with [free] when no longer needed.
///
/// Throws a [LibGit2Error] if initialization fails.
Pointer<git_repository> init({
  required String path,
  required int flags,
  required int mode,
  String? workdirPath,
  String? description,
  String? templatePath,
  String? initialHead,
  String? originUrl,
}) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final pathC = path.toChar(arena);
    final workdirPathC = workdirPath?.toChar(arena) ?? nullptr;
    final descriptionC = description?.toChar(arena) ?? nullptr;
    final templatePathC = templatePath?.toChar(arena) ?? nullptr;
    final initialHeadC = initialHead?.toChar(arena) ?? nullptr;
    final originUrlC = originUrl?.toChar(arena) ?? nullptr;
    final opts = arena<git_repository_init_options>();

    libgit2.git_repository_init_options_init(
      opts,
      GIT_REPOSITORY_INIT_OPTIONS_VERSION,
    );

    opts.ref.flags = flags;
    opts.ref.mode = mode;
    opts.ref.workdir_path = workdirPathC;
    opts.ref.description = descriptionC;
    opts.ref.template_path = templatePathC;
    opts.ref.initial_head = initialHeadC;
    opts.ref.origin_url = originUrlC;

    final error = libgit2.git_repository_init_ext(out, pathC, opts);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Clone a remote repository with the specified options.
///
/// Creates a local copy of the repository at [url] in [localPath] with options:
/// - [bare]: Whether to create a bare repository
/// - [remoteCallback]: Optional callback for remote creation
/// - [repositoryCallback]: Optional callback for repository creation
/// - [checkoutBranch]: Branch to checkout after cloning
/// - [callbacks]: Callbacks for remote operations
///
/// The returned repository must be freed with [free] when no longer needed.
///
/// Throws a [LibGit2Error] if cloning fails.
Pointer<git_repository> clone({
  required String url,
  required String localPath,
  required bool bare,
  RemoteCallback? remoteCallback,
  RepositoryCallback? repositoryCallback,
  String? checkoutBranch,
  required Callbacks callbacks,
}) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final urlC = url.toChar(arena);
    final localPathC = localPath.toChar(arena);
    final checkoutBranchC = checkoutBranch?.toChar(arena) ?? nullptr;

    final cloneOptions = arena<git_clone_options>();
    libgit2.git_clone_options_init(cloneOptions, GIT_CLONE_OPTIONS_VERSION);

    final fetchOptions = arena<git_fetch_options>();
    libgit2.git_fetch_options_init(fetchOptions, GIT_FETCH_OPTIONS_VERSION);

    RemoteCallbacks.plug(
      callbacksOptions: fetchOptions.ref.callbacks,
      callbacks: callbacks,
    );

    const except = -1;

    git_remote_create_cb remoteCb = nullptr;
    if (remoteCallback != null) {
      RemoteCallbacks.remoteCbData = remoteCallback;
      remoteCb = Pointer.fromFunction(RemoteCallbacks.remoteCb, except);
    }

    git_repository_create_cb repositoryCb = nullptr;
    if (repositoryCallback != null) {
      RemoteCallbacks.repositoryCbData = repositoryCallback;
      repositoryCb = Pointer.fromFunction(RemoteCallbacks.repositoryCb, except);
    }

    cloneOptions.ref.bare = bare ? 1 : 0;
    cloneOptions.ref.remote_cb = remoteCb;
    cloneOptions.ref.checkout_branch = checkoutBranchC;
    cloneOptions.ref.repository_cb = repositoryCb;
    cloneOptions.ref.fetch_opts = fetchOptions.ref;

    final error = libgit2.git_clone(out, urlC, localPathC, cloneOptions);

    checkErrorAndThrow(error);
    RemoteCallbacks.reset();
    return out.value;
  });
}

/// Get the path to the repository's Git directory.
///
/// For normal repositories, this is the path to the `.git` directory.
/// For bare repositories, this is the path to the repository itself.
String path(Pointer<git_repository> repo) {
  return libgit2.git_repository_path(repo).toDartString();
}

/// Get the path to the repository's common directory.
///
/// This is the directory that contains all the Git objects and references:
/// - For normal repositories: the `.git` directory
/// - For bare repositories: the repository root
/// - For worktrees: the parent repository's `.git` directory
String commonDir(Pointer<git_repository> repo) =>
    libgit2.git_repository_commondir(repo).toDartString();

/// Get the repository's current namespace.
///
/// The namespace affects all reference operations. If no namespace is set or
/// the namespace is not valid UTF-8, returns an empty string.
String getNamespace(Pointer<git_repository> repo) {
  final result = libgit2.git_repository_get_namespace(repo);
  return result == nullptr ? '' : result.toDartString();
}

/// Set the repository's namespace.
///
/// The namespace affects all reference operations. The [namespace] should not
/// include the refs folder. For example, to namespace all references under
/// refs/namespaces/foo/, use "foo" as the namespace.
///
/// Set [namespace] to null to remove the current namespace.
void setNamespace({
  required Pointer<git_repository> repoPointer,
  String? namespace,
}) {
  using((arena) {
    final namespaceC = namespace?.toChar(arena) ?? nullptr;
    libgit2.git_repository_set_namespace(repoPointer, namespaceC);
  });
}

/// Check if the repository is bare.
///
/// A bare repository has no working directory and is typically used as a
/// central repository for collaboration.
bool isBare(Pointer<git_repository> repo) =>
    libgit2.git_repository_is_bare(repo) == 1;

/// Check if the repository is empty.
///
/// An empty repository has just been initialized and contains no references
/// apart from HEAD, which must be pointing to the unborn master branch.
///
/// Throws a [LibGit2Error] if the repository is corrupted.
bool isEmpty(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_is_empty(repo);
  checkErrorAndThrow(error);
  return error == 1;
}

/// Get the repository's HEAD reference.
///
/// Returns a reference to the current HEAD, which must be freed when no longer
/// needed. The reference is resolved to its direct target.
///
/// Throws a [LibGit2Error] if HEAD cannot be retrieved.
Pointer<git_reference> head(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_reference>>();
    final error = libgit2.git_repository_head(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// A repository's HEAD is detached when it points directly to a commit instead
/// of a branch.
///
/// Throws a [LibGit2Error] if error occured.
bool isHeadDetached(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_head_detached(repo);
  checkErrorAndThrow(error);
  return error == 1;
}

/// Get the path to the repository's working directory.
///
/// For bare repositories, this returns an empty string.
String workdir(Pointer<git_repository> repo) {
  final result = libgit2.git_repository_workdir(repo);
  return result == nullptr ? '' : result.toDartString();
}

/// Set the repository's working directory.
///
/// The working directory doesn't need to be the same one that contains the
/// .git folder. For bare repositories, setting a working directory will turn
/// it into a normal repository.
///
/// [updateGitlink] if true, creates/updates gitlink in workdir and sets
/// config "core.worktree" if workdir is not the parent of the .git directory.
///
/// Throws a [LibGit2Error] if error occurred.
void setWorkdir({
  required Pointer<git_repository> repoPointer,
  required String workdir,
  required bool updateGitlink,
}) {
  using((arena) {
    final workdirC = workdir.toChar(arena);
    final error = libgit2.git_repository_set_workdir(
      repoPointer,
      workdirC,
      updateGitlink ? 1 : 0,
    );

    checkErrorAndThrow(error);
  });
}

/// Get the repository's configuration.
///
/// Returns a pointer to the repository's configuration object, which must be
/// freed when no longer needed.
///
/// Throws a [LibGit2Error] if the configuration cannot be retrieved.
Pointer<git_config> config(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_repository_config(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the repository's index.
///
/// Returns a pointer to the repository's index object, which must be freed
/// when no longer needed.
///
/// Throws a [LibGit2Error] if the index cannot be retrieved.
Pointer<git_index> index(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_index>>();
    final error = libgit2.git_repository_index(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the repository's object database.
///
/// Returns a pointer to the repository's object database, which must be freed
/// when no longer needed.
///
/// Throws a [LibGit2Error] if the object database cannot be retrieved.
Pointer<git_odb> odb(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_odb>>();
    final error = libgit2.git_repository_odb(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the repository's reference database.
///
/// Returns a pointer to the repository's reference database, which must be
/// freed when no longer needed.
///
/// Throws a [LibGit2Error] if the reference database cannot be retrieved.
Pointer<git_refdb> refdb(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_refdb>>();
    final error = libgit2.git_repository_refdb(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Assign a custom reference database to the repository.
void setRefdb({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_refdb> refdbPointer,
}) {
  final error = libgit2.git_repository_set_refdb(repoPointer, refdbPointer);
  checkErrorAndThrow(error);
}

/// Create a repository wrapper around an existing object database.
Pointer<git_repository> wrapOdb(Pointer<git_odb> odbPointer) {
  return using((arena) {
    final out = arena<Pointer<git_repository>>();
    final error = libgit2.git_repository_wrap_odb(out, odbPointer);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Retrieve the path for a repository item.
String itemPath({
  required Pointer<git_repository> repoPointer,
  required git_repository_item_t item,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_repository_item_path(out, repoPointer, item);
    checkErrorAndThrow(error);
    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Cache all submodule information for the repository.
void submoduleCacheAll(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_submodule_cache_all(repo);
  checkErrorAndThrow(error);
}

/// Clear the repository's submodule cache.
void submoduleCacheClear(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_submodule_cache_clear(repo);
  checkErrorAndThrow(error);
}

/// Reinitialize a repository's filesystem structure.
void reinitFilesystem({
  required Pointer<git_repository> repoPointer,
  required bool recurseSubmodules,
}) {
  final error = libgit2.git_repository_reinit_filesystem(
    repoPointer,
    recurseSubmodules ? 1 : 0,
  );
  checkErrorAndThrow(error);
}

/// Toggle the repository's bare status.
void setBare({required Pointer<git_repository> repoPointer}) {
  final error = libgit2.git_repository_set_bare(repoPointer);
  checkErrorAndThrow(error);
}

/// Free a repository object.
///
/// This will free the repository and all associated resources. The repository
/// must not be used after this call.
void free(Pointer<git_repository> repo) {
  libgit2.git_repository_free(repo);
}

/// Set the repository's HEAD to point to a reference.
///
/// The [refname] should be a valid reference name (e.g., "refs/heads/master").
///
/// Throws a [LibGit2Error] if error occurred.
void setHead({
  required Pointer<git_repository> repoPointer,
  required String refname,
}) {
  using((arena) {
    final refnameC = refname.toChar(arena);
    final error = libgit2.git_repository_set_head(repoPointer, refnameC);
    checkErrorAndThrow(error);
  });
}

/// Set the repository's HEAD to point to a commit.
///
/// This will detach the HEAD from any branch.
///
/// Throws a [LibGit2Error] if error occurred.
void setHeadDetached({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_oid> commitishPointer,
}) {
  final error = libgit2.git_repository_set_head_detached(
    repoPointer,
    commitishPointer,
  );
  checkErrorAndThrow(error);
}

/// Check if the current branch is unborn.
///
/// An unborn branch is one that exists in HEAD but has no commits yet.
///
/// Throws a [LibGit2Error] if error occurred.
bool isBranchUnborn(Pointer<git_repository> repo) {
  final result = libgit2.git_repository_head_unborn(repo);
  checkErrorAndThrow(result);
  return result == 1;
}

/// Set the identity to be used for writing reflogs.
///
/// If both [name] and [email] are set, they will be used for writing reflogs.
/// If either is null, the identity will be taken from the repository's configuration.
///
/// Throws a [LibGit2Error] if error occurred.
void setIdentity({
  required Pointer<git_repository> repoPointer,
  required String? name,
  required String? email,
}) {
  using((arena) {
    final nameC = name?.toChar(arena) ?? nullptr;
    final emailC = email?.toChar(arena) ?? nullptr;
    final error = libgit2.git_repository_set_ident(repoPointer, nameC, emailC);
    checkErrorAndThrow(error);
  });
}

/// Get the configured identity for writing reflogs.
///
/// Returns a list containing [name, email] if configured, or empty list if not.
List<String> identity(Pointer<git_repository> repo) {
  final name = calloc<Pointer<Char>>();
  final email = calloc<Pointer<Char>>();
  libgit2.git_repository_ident(name, email, repo);

  final result = <String>[];
  if (name.value != nullptr) {
    result.add(name.value.toDartString());
  }
  if (email.value != nullptr) {
    result.add(email.value.toDartString());
  }

  calloc.free(name);
  calloc.free(email);

  return result;
}

/// Check if the repository was a shallow clone.
bool isShallow(Pointer<git_repository> repo) {
  return libgit2.git_repository_is_shallow(repo) == 1;
}

/// Check if the repository is a linked work tree.
bool isWorktree(Pointer<git_repository> repo) {
  return libgit2.git_repository_is_worktree(repo) == 1;
}

/// Get Git's prepared message.
///
/// This is used for operations like merge, revert, cherry-pick that stop
/// before creating a commit and save their message in .git/MERGE_MSG.
///
/// Throws a [LibGit2Error] if error occurred.
String message(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_repository_message(out, repo);
    checkErrorAndThrow(error);
    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Remove Git's prepared message.
///
/// This removes the .git/MERGE_MSG file.
///
/// Throws a [LibGit2Error] if error occurred.
void removeMessage(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_message_remove(repo);
  checkErrorAndThrow(error);
}

/// Get the repository's state.
///
/// Returns the current state of the repository (e.g., merge, revert, etc.).
int state(Pointer<git_repository> repo) {
  return libgit2.git_repository_state(repo);
}

/// Clean up the repository's state.
///
/// Removes all metadata associated with ongoing operations like merge,
/// revert, cherry-pick, etc.
///
/// Throws a [LibGit2Error] if error occurred.
void stateCleanup(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_state_cleanup(repo);
  checkErrorAndThrow(error);
}

/// Get a snapshot of the repository's configuration.
///
/// The contents of this snapshot will not change even if the underlying
/// config files are modified.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_config> configSnapshot(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_repository_config_snapshot(out, repo);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Prune tracking refs that are no longer present on remote.
///
/// Throws a [LibGit2Error] if error occurred.
void prune({
  required Pointer<git_remote> remotePointer,
  required Pointer<git_remote_callbacks> flags,
}) {
  final error = libgit2.git_remote_prune(remotePointer, flags);
  checkErrorAndThrow(error);
}

/// Prune tracking refs that are no longer present on remote.
///
/// Throws a [LibGit2Error] if error occurred.
void pruneRefs({required Pointer<git_remote> remotePointer}) {
  final error = libgit2.git_remote_prune_refs(remotePointer);
  checkErrorAndThrow(error);
}

/// Stop the remote's current operation.
///
/// Throws a [LibGit2Error] if error occurred.
void stop(Pointer<git_remote> remote) {
  final error = libgit2.git_remote_stop(remote);
  checkErrorAndThrow(error);
}

/// Get the remote's name.
///
/// Returns the name of the remote or an empty string if the remote is anonymous.
String name(Pointer<git_remote> remote) {
  final result = libgit2.git_remote_name(remote);
  return result == nullptr ? '' : result.toDartString();
}

/// Get the remote's url.
///
/// Returns the URL of the remote repository.
String url(Pointer<git_remote> remote) =>
    libgit2.git_remote_url(remote).toDartString();

/// Get the remote's url for pushing.
///
/// Returns empty string if no special url for pushing is set.
String pushUrl(Pointer<git_remote> remote) {
  final result = libgit2.git_remote_pushurl(remote);
  return result == nullptr ? '' : result.toDartString();
}

/// Get the number of refspecs for a remote.
int refspecCount(Pointer<git_remote> remote) =>
    libgit2.git_remote_refspec_count(remote);

/// Get a refspec from the remote at provided position.
Pointer<git_refspec> getRefspec({
  required Pointer<git_remote> remotePointer,
  required int position,
}) => libgit2.git_remote_get_refspec(remotePointer, position);

/// Get the statistics structure that is filled in by the fetch operation.
Pointer<git_indexer_progress> stats(Pointer<git_remote> remote) =>
    libgit2.git_remote_stats(remote);
