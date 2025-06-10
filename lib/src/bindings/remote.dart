import 'dart:ffi';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' show Arena, calloc, using;
import 'package:git2dart/src/bindings/remote_callbacks.dart';
import 'package:git2dart/src/callbacks.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart/src/oid.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Get a list of the configured remotes for a repository.
///
/// Returns a list of remote names that are configured in the repository.
List<String> list(Pointer<git_repository> repo) {
  return using((arena) {
    final out = arena<git_strarray>();
    final error = libgit2.git_remote_list(out, repo);

    checkErrorAndThrow(error);

    return <String>[
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
  });
}

/// Get the information for a particular remote. The returned remote must be
/// freed with [free].
///
/// The name will be checked for validity.
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_remote> lookup({
  required Pointer<git_repository> repoPointer,
  required String name,
}) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_remote_lookup(out, repoPointer, nameC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a copy of an existing remote.
///
/// The returned remote must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_remote> dup(Pointer<git_remote> remote) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final error = libgit2.git_remote_dup(out, remote);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get the repository that owns this remote.
///
/// Returns a pointer to the repository that owns this remote.
Pointer<git_repository> owner(Pointer<git_remote> remote) =>
    libgit2.git_remote_owner(remote);

/// Add a remote with the default fetch refspec to the repository's
/// configuration. The returned remote must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_remote> create({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String url,
}) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final nameC = name.toChar(arena);
    final urlC = url.toChar(arena);
    final error = libgit2.git_remote_create(out, repoPointer, nameC, urlC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a remote without a name in a detached repository.
///
/// The returned remote must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_remote> createAnonymous({
  required Pointer<git_repository> repoPointer,
  required String url,
}) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final urlC = url.toChar(arena);
    final error = libgit2.git_remote_create_anonymous(out, repoPointer, urlC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Create a remote without a name in a detached repository.
///
/// The returned remote must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_remote> createDetached({required String url}) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final urlC = url.toChar(arena);
    final error = libgit2.git_remote_create_detached(out, urlC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Delete an existing persisted remote.
///
/// All remote-tracking branches and configuration settings for the remote will
/// be removed.
///
/// Throws a [LibGit2Error] if error occured.
void delete({
  required Pointer<git_repository> repoPointer,
  required String name,
}) {
  using((arena) {
    final nameC = name.toChar(arena);
    final error = libgit2.git_remote_delete(repoPointer, nameC);
    checkErrorAndThrow(error);
  });
}

/// Give the remote a new name.
///
/// Returns list of non-default refspecs that cannot be renamed.
///
/// All remote-tracking branches and configuration settings for the remote are
/// updated.
///
/// The new name will be checked for validity.
///
/// No loaded instances of a the remote with the old name will change their
/// name or their list of refspecs.
///
/// Throws a [LibGit2Error] if error occured.
List<String> rename({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String newName,
}) {
  return using((arena) {
    final out = arena<git_strarray>();
    final nameC = name.toChar(arena);
    final newNameC = newName.toChar(arena);
    final error = libgit2.git_remote_rename(out, repoPointer, nameC, newNameC);

    checkErrorAndThrow(error);

    return <String>[
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
  });
}

/// Set the remote's url in the configuration.
///
/// Remote objects already in memory will not be affected. This assumes the
/// common case of a single-url remote and will otherwise return an error.
///
/// Throws a [LibGit2Error] if error occured.
void setUrl({
  required Pointer<git_repository> repoPointer,
  required String remote,
  required String url,
}) {
  using((arena) {
    final remoteC = remote.toChar(arena);
    final urlC = url.toChar(arena);
    final error = libgit2.git_remote_set_url(repoPointer, remoteC, urlC);
    checkErrorAndThrow(error);
  });
}

/// Set the remote's url for pushing in the configuration.
///
/// Remote objects already in memory will not be affected. This assumes the
/// common case of a single-url remote and will otherwise return an error.
///
/// Throws a [LibGit2Error] if error occured.
void setPushUrl({
  required Pointer<git_repository> repoPointer,
  required String remote,
  required String url,
}) {
  using((arena) {
    final remoteC = remote.toChar(arena);
    final urlC = url.toChar(arena);
    final error = libgit2.git_remote_set_pushurl(repoPointer, remoteC, urlC);
    checkErrorAndThrow(error);
  });
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

/// Get the remote's list of fetch refspecs.
List<String> fetchRefspecs(Pointer<git_remote> remote) {
  return using((arena) {
    final out = arena<git_strarray>();
    final error = libgit2.git_remote_get_fetch_refspecs(out, remote);

    checkErrorAndThrow(error);

    return <String>[
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
  });
}

/// Get the remote's list of push refspecs.
List<String> pushRefspecs(Pointer<git_remote> remote) {
  return using((arena) {
    final out = arena<git_strarray>();
    final error = libgit2.git_remote_get_push_refspecs(out, remote);

    checkErrorAndThrow(error);

    return <String>[
      for (var i = 0; i < out.ref.count; i++) out.ref.strings[i].toDartString(),
    ];
  });
}

/// Add a fetch refspec to the remote's configuration.
///
/// Add the given refspec to the fetch list in the configuration. No loaded
/// remote instances will be affected.
///
/// Throws a [LibGit2Error] if error occured.
void addFetch({
  required Pointer<git_repository> repoPointer,
  required String remote,
  required String refspec,
}) {
  using((arena) {
    final remoteC = remote.toChar(arena);
    final refspecC = refspec.toChar(arena);
    final error = libgit2.git_remote_add_fetch(repoPointer, remoteC, refspecC);
    checkErrorAndThrow(error);
  });
}

/// Add a push refspec to the remote's configuration.
///
/// Add the given refspec to the push list in the configuration. No loaded
/// remote instances will be affected.
///
/// Throws a [LibGit2Error] if error occured.
void addPush({
  required Pointer<git_repository> repoPointer,
  required String remote,
  required String refspec,
}) {
  using((arena) {
    final remoteC = remote.toChar(arena);
    final refspecC = refspec.toChar(arena);
    final error = libgit2.git_remote_add_push(repoPointer, remoteC, refspecC);
    checkErrorAndThrow(error);
  });
}

/// Open a connection to a remote.
///
/// The transport is selected based on the URL. The direction argument is due
/// to a limitation of the git protocol (over TCP or SSH) which starts up a
/// specific binary which can only do the one or the other.
///
/// [direction] specifies whether this connection will be used for fetching or pushing.
/// [callbacks] provides callbacks for the remote connection.
/// [proxyOption] can be 'auto' to try to auto-detect the proxy from the git
/// configuration or some specified url. By default connection isn't done
/// through proxy.
///
/// Throws a [LibGit2Error] if error occurred.
void connect({
  required Pointer<git_remote> remotePointer,
  required git_direction direction,
  required Callbacks callbacks,
  String? proxyOption,
}) {
  using((arena) {
    final callbacksOptions = arena<git_remote_callbacks>();
    libgit2.git_remote_init_callbacks(
      callbacksOptions,
      GIT_REMOTE_CALLBACKS_VERSION,
    );

    RemoteCallbacks.plug(
      callbacksOptions: callbacksOptions.ref,
      callbacks: callbacks,
    );

    final proxyOptions = _proxyOptionsInit(proxyOption, arena);

    final error = libgit2.git_remote_connect(
      remotePointer,
      direction,
      callbacksOptions,
      proxyOptions,
      nullptr,
    );

    checkErrorAndThrow(error);
    RemoteCallbacks.reset();
  });
}

/// Get the remote repository's reference advertisement list.
///
/// Get the list of references with which the server responds to a new
/// connection.
///
/// The remote (or more exactly its transport) must have connected to the
/// remote repository. This list is available as soon as the connection to the
/// remote is initiated and it remains available after disconnecting.
///
/// Throws a [LibGit2Error] if error occured.
List<Map<String, Object?>> lsRemotes(Pointer<git_remote> remote) {
  return using((arena) {
    final out = arena<Pointer<Pointer<git_remote_head>>>();
    final size = arena<Size>();
    final error = libgit2.git_remote_ls(out, size, remote);

    checkErrorAndThrow(error);

    final result = <Map<String, Object?>>[];

    for (var i = 0; i < size.value; i++) {
      final remote = <String, Object?>{};
      final local = out[0][i].ref.local == 1;

      remote['local'] = local;
      remote['loid'] = local ? Oid.fromRaw(out[0][i].ref.loid) : null;
      remote['name'] =
          out[0][i].ref.name == nullptr
              ? ''
              : out[0][i].ref.name.toDartString();
      remote['symref'] =
          out[0][i].ref.symref_target == nullptr
              ? ''
              : out[0][i].ref.symref_target.toDartString();
      remote['oid'] = Oid.fromRaw(out[0][i].ref.oid);

      result.add(remote);
    }

    return result;
  });
}

/// Download new data and update tips.
///
/// Convenience function to connect to a remote, download the data, disconnect
/// and update the remote-tracking branches.
///
/// [refspecs] is the list of refspecs to use for this fetch. Defaults to the
/// base refspecs.
/// [prune] determines whether to perform a prune after the fetch.
/// [reflogMessage] is the message to insert into the reflogs. Default is "fetch".
/// [proxyOption] can be 'auto' to try to auto-detect the proxy from the git
/// configuration or some specified url. By default connection isn't done
/// through proxy.
/// [callbacks] provides callbacks for the fetch operation.
///
/// Throws a [LibGit2Error] if error occurred.
void fetch({
  required Pointer<git_remote> remotePointer,
  required List<String> refspecs,
  required int prune,
  required Callbacks callbacks,
  String? reflogMessage,
  String? proxyOption,
}) {
  using((arena) {
    final refspecsC = calloc<git_strarray>();
    final refspecsPointers = refspecs.map((e) => e.toChar(arena)).toList();
    final strArray = calloc<Pointer<Char>>(refspecs.length);

    for (var i = 0; i < refspecs.length; i++) {
      strArray[i] = refspecsPointers[i];
    }

    refspecsC.ref.count = refspecs.length;
    refspecsC.ref.strings = strArray;
    final reflogMessageC = reflogMessage?.toChar(arena) ?? nullptr;

    final proxyOptions = _proxyOptionsInit(proxyOption, arena);

    final opts = calloc<git_fetch_options>();
    libgit2.git_fetch_options_init(opts, GIT_FETCH_OPTIONS_VERSION);

    RemoteCallbacks.plug(
      callbacksOptions: opts.ref.callbacks,
      callbacks: callbacks,
    );
    opts.ref.pruneAsInt = prune;
    opts.ref.proxy_opts = proxyOptions.ref;

    final error = libgit2.git_remote_fetch(
      remotePointer,
      refspecsC,
      opts,
      reflogMessageC,
    );

    checkErrorAndThrow(error);
    RemoteCallbacks.reset();
  });
}

/// Perform a push.
///
/// [refspecs] is the list of refspecs to use for pushing. Defaults to the
/// configured refspecs.
/// [proxyOption] can be 'auto' to try to auto-detect the proxy from the git
/// configuration or some specified url. By default connection isn't done
/// through proxy.
/// [callbacks] provides callbacks for the push operation.
///
/// Throws a [LibGit2Error] if error occurred.
void push({
  required Pointer<git_remote> remotePointer,
  required List<String> refspecs,
  required Callbacks callbacks,
  String? proxyOption,
}) {
  using((arena) {
    final refspecsC = arena<git_strarray>();
    final refspecsPointers = refspecs.map((e) => e.toChar(arena)).toList();
    final strArray = arena<Pointer<Char>>(refspecs.length);

    for (var i = 0; i < refspecs.length; i++) {
      strArray[i] = refspecsPointers[i];
    }

    refspecsC.ref.count = refspecs.length;
    refspecsC.ref.strings = strArray;

    final proxyOptions = _proxyOptionsInit(proxyOption, arena);

    final opts = arena<git_push_options>();
    libgit2.git_push_options_init(opts, GIT_PUSH_OPTIONS_VERSION);

    RemoteCallbacks.plug(
      callbacksOptions: opts.ref.callbacks,
      callbacks: callbacks,
    );
    opts.ref.proxy_opts = proxyOptions.ref;

    final error = libgit2.git_remote_push(remotePointer, refspecsC, opts);

    checkErrorAndThrow(error);
    RemoteCallbacks.reset();
  });
}

/// Get the statistics structure that is filled in by the fetch operation.
Pointer<git_indexer_progress> stats(Pointer<git_remote> remote) =>
    libgit2.git_remote_stats(remote);

/// Close the connection to the remote.
void disconnect(Pointer<git_remote> remote) =>
    libgit2.git_remote_disconnect(remote);

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

/// Check if the remote is connected.
bool connected(Pointer<git_remote> remote) =>
    libgit2.git_remote_connected(remote) == 1;

/// Stop the remote's current operation.
///
/// Throws a [LibGit2Error] if error occurred.
void stop(Pointer<git_remote> remote) {
  final error = libgit2.git_remote_stop(remote);
  checkErrorAndThrow(error);
}

/// Free the memory associated with a remote.
///
/// This also disconnects from the remote, if the connection has not been closed
/// yet (using [disconnect]).
void free(Pointer<git_remote> remote) => libgit2.git_remote_free(remote);

/// Validate that the provided remote name is well formed.
bool nameIsValid(String name) {
  return using((arena) {
    final out = arena<Int>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_remote_name_is_valid(out, nameC);

    checkErrorAndThrow(error);
    return out.value == 1;
  });
}

/// Download new data from the remote without updating tracking refs.
///
/// Throws a [LibGit2Error] if error occurred.
void download({
  required Pointer<git_remote> remotePointer,
  required List<String> refspecs,
  required Pointer<git_fetch_options> optionsPointer,
}) {
  using((arena) {
    final refspecsC = arena<git_strarray>();
    final pointers = refspecs.map((e) => e.toChar(arena)).toList();
    final arr = arena<Pointer<Char>>(refspecs.length);
    for (var i = 0; i < refspecs.length; i++) {
      arr[i] = pointers[i];
    }
    refspecsC.ref.count = refspecs.length;
    refspecsC.ref.strings = arr;

    final error = libgit2.git_remote_download(
      remotePointer,
      refspecsC,
      optionsPointer,
    );

    checkErrorAndThrow(error);
  });
}

/// Update the tips after a fetch operation.
///
/// Throws a [LibGit2Error] if error occurred.
void updateTips({
  required Pointer<git_remote> remotePointer,
  required Pointer<git_remote_callbacks> callbacksPointer,
  required int updateFlags,
  required git_remote_autotag_option_t downloadTags,
  String? reflogMessage,
}) {
  using((arena) {
    final msgC = reflogMessage?.toChar(arena) ?? nullptr;
    final error = libgit2.git_remote_update_tips(
      remotePointer,
      callbacksPointer,
      updateFlags,
      downloadTags,
      msgC,
    );

    checkErrorAndThrow(error);
  });
}

/// Return the remote's default branch as a reference name.
///
/// Throws a [LibGit2Error] if the information is not available.
String defaultBranch(Pointer<git_remote> remotePointer) {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_remote_default_branch(out, remotePointer);

    checkErrorAndThrow(error);
    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Initialize [git_remote_create_options] structure with default values.
Pointer<git_remote_create_options> createOptionsInit(Arena arena) {
  final opts = arena<git_remote_create_options>();
  libgit2.git_remote_create_options_init(
    opts,
    GIT_REMOTE_CREATE_OPTIONS_VERSION,
  );
  return opts;
}

/// Create a remote using the provided options.
Pointer<git_remote> createWithOpts({
  required String url,
  required Pointer<git_remote_create_options> optionsPointer,
}) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final error = libgit2.git_remote_create_with_opts(
      out,
      url.toChar(arena),
      optionsPointer,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Initializes git_proxy_options structure.
///
/// [proxyOption] can be 'auto' to try to auto-detect the proxy from the git
/// configuration or some specified url. By default connection isn't done
/// through proxy.
Pointer<git_proxy_options> _proxyOptionsInit(String? proxyOption, Arena arena) {
  final proxyOptions = arena<git_proxy_options>();
  libgit2.git_proxy_options_init(proxyOptions, GIT_PROXY_OPTIONS_VERSION);

  if (proxyOption == null) {
    proxyOptions.ref.typeAsInt = git_proxy_t.GIT_PROXY_NONE.value;
  } else if (proxyOption == 'auto') {
    proxyOptions.ref.typeAsInt = git_proxy_t.GIT_PROXY_AUTO.value;
  } else {
    proxyOptions.ref.typeAsInt = git_proxy_t.GIT_PROXY_SPECIFIED.value;
    proxyOptions.ref.url = proxyOption.toChar(arena);
  }

  return proxyOptions;
}

/// Add a remote with a custom fetch refspec to the repository's configuration.
/// The returned remote must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
Pointer<git_remote> createWithFetchSpec({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String url,
  required String fetch,
}) {
  return using((arena) {
    final out = arena<Pointer<git_remote>>();
    final nameC = name.toChar(arena);
    final urlC = url.toChar(arena);
    final fetchC = fetch.toChar(arena);
    final error = libgit2.git_remote_create_with_fetchspec(
      out,
      repoPointer,
      nameC,
      urlC,
      fetchC,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}
