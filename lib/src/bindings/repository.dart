import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/bindings/remote_callbacks.dart';
import 'package:git2dart/src/callbacks.dart';
import 'package:git2dart/src/error.dart';
import 'package:git2dart/src/extensions.dart';
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
  final out = calloc<Pointer<git_repository>>();
  final pathC = path.toChar();
  final error = libgit2.git_repository_open(out, pathC);

  final result = out.value;

  calloc.free(out);
  calloc.free(pathC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
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
  final out = calloc<git_buf>();
  final startPathC = startPath.toChar();
  final ceilingDirsC = ceilingDirs?.toChar() ?? nullptr;

  libgit2.git_repository_discover(out, startPathC, 0, ceilingDirsC);

  calloc.free(startPathC);
  calloc.free(ceilingDirsC);

  final result = out.ref.ptr.toDartString(length: out.ref.size);

  libgit2.git_buf_dispose(out);
  calloc.free(out);

  return result;
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
  final out = calloc<Pointer<git_repository>>();
  final pathC = path.toChar();
  final workdirPathC = workdirPath?.toChar() ?? nullptr;
  final descriptionC = description?.toChar() ?? nullptr;
  final templatePathC = templatePath?.toChar() ?? nullptr;
  final initialHeadC = initialHead?.toChar() ?? nullptr;
  final originUrlC = originUrl?.toChar() ?? nullptr;
  final opts = calloc<git_repository_init_options>();
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

  final result = out.value;

  calloc.free(out);
  calloc.free(pathC);
  calloc.free(workdirPathC);
  calloc.free(descriptionC);
  calloc.free(templatePathC);
  calloc.free(initialHeadC);
  calloc.free(originUrlC);
  calloc.free(opts);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
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
  final out = calloc<Pointer<git_repository>>();
  final urlC = url.toChar();
  final localPathC = localPath.toChar();
  final checkoutBranchC = checkoutBranch?.toChar() ?? nullptr;

  final cloneOptions = calloc<git_clone_options>();
  libgit2.git_clone_options_init(cloneOptions, GIT_CLONE_OPTIONS_VERSION);

  final fetchOptions = calloc<git_fetch_options>();
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

  final result = out.value;

  calloc.free(out);
  calloc.free(urlC);
  calloc.free(localPathC);
  calloc.free(checkoutBranchC);
  calloc.free(cloneOptions);
  calloc.free(fetchOptions);
  RemoteCallbacks.reset();

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
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
String commonDir(Pointer<git_repository> repo) {
  return libgit2.git_repository_commondir(repo).toDartString();
}

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
  final namespaceC = namespace?.toChar() ?? nullptr;
  libgit2.git_repository_set_namespace(repoPointer, namespaceC);
  calloc.free(namespaceC);
}

/// Check if the repository is bare.
///
/// A bare repository has no working directory and is typically used as a
/// central repository for collaboration.
bool isBare(Pointer<git_repository> repo) {
  return libgit2.git_repository_is_bare(repo) == 1 || false;
}

/// Check if the repository is empty.
///
/// An empty repository has just been initialized and contains no references
/// apart from HEAD, which must be pointing to the unborn master branch.
///
/// Throws a [LibGit2Error] if the repository is corrupted.
bool isEmpty(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_is_empty(repo);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return error == 1 || false;
  }
}

/// Get the repository's HEAD reference.
///
/// Returns a reference to the current HEAD, which must be freed when no longer
/// needed. The reference is resolved to its direct target.
///
/// Throws a [LibGit2Error] if HEAD cannot be retrieved.
Pointer<git_reference> head(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_reference>>();
  final error = libgit2.git_repository_head(out, repo);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// A repository's HEAD is detached when it points directly to a commit instead
/// of a branch.
///
/// Throws a [LibGit2Error] if error occured.
bool isHeadDetached(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_head_detached(repo);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return error == 1 || false;
  }
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
  final workdirC = workdir.toChar();
  final error = libgit2.git_repository_set_workdir(
    repoPointer,
    workdirC,
    updateGitlink ? 1 : 0,
  );

  calloc.free(workdirC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Get the repository's configuration.
///
/// Returns a pointer to the repository's configuration object, which must be
/// freed when no longer needed.
///
/// Throws a [LibGit2Error] if the configuration cannot be retrieved.
Pointer<git_config> config(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_config>>();
  final error = libgit2.git_repository_config(out, repo);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Get the repository's index.
///
/// Returns a pointer to the repository's index object, which must be freed
/// when no longer needed.
///
/// Throws a [LibGit2Error] if the index cannot be retrieved.
Pointer<git_index> index(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_index>>();
  final error = libgit2.git_repository_index(out, repo);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Get the repository's object database.
///
/// Returns a pointer to the repository's object database, which must be freed
/// when no longer needed.
///
/// Throws a [LibGit2Error] if the object database cannot be retrieved.
Pointer<git_odb> odb(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_odb>>();
  final error = libgit2.git_repository_odb(out, repo);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}

/// Get the repository's reference database.
///
/// Returns a pointer to the repository's reference database, which must be
/// freed when no longer needed.
///
/// Throws a [LibGit2Error] if the reference database cannot be retrieved.
Pointer<git_refdb> refdb(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_refdb>>();
  final error = libgit2.git_repository_refdb(out, repo);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
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
  final refnameC = refname.toChar();
  final error = libgit2.git_repository_set_head(repoPointer, refnameC);

  calloc.free(refnameC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
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

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Check if the current branch is unborn.
///
/// An unborn branch is one that exists in HEAD but has no commits yet.
///
/// Throws a [LibGit2Error] if error occurred.
bool isBranchUnborn(Pointer<git_repository> repo) {
  final result = libgit2.git_repository_head_unborn(repo);
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
  final nameC = name?.toChar() ?? nullptr;
  final emailC = email?.toChar() ?? nullptr;
  final error = libgit2.git_repository_set_ident(repoPointer, nameC, emailC);

  calloc.free(nameC);
  calloc.free(emailC);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
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
  final out = calloc<git_buf>();
  final error = libgit2.git_repository_message(out, repo);

  if (error < 0) {
    calloc.free(out);
    throw LibGit2Error(libgit2.git_error_last());
  }

  final result = out.ref.ptr.toDartString(length: out.ref.size);

  libgit2.git_buf_dispose(out);
  calloc.free(out);

  return result;
}

/// Remove Git's prepared message.
///
/// This removes the .git/MERGE_MSG file.
///
/// Throws a [LibGit2Error] if error occurred.
void removeMessage(Pointer<git_repository> repo) {
  final error = libgit2.git_repository_message_remove(repo);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
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

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  }
}

/// Get a snapshot of the repository's configuration.
///
/// The contents of this snapshot will not change even if the underlying
/// config files are modified.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_config> configSnapshot(Pointer<git_repository> repo) {
  final out = calloc<Pointer<git_config>>();
  final error = libgit2.git_repository_config_snapshot(out, repo);

  final result = out.value;

  calloc.free(out);

  if (error < 0) {
    throw LibGit2Error(libgit2.git_error_last());
  } else {
    return result;
  }
}
