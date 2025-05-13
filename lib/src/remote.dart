import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:ffi/ffi.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/remote.dart' as remote_bindings;
import 'package:git2dart/src/bindings/remote_callbacks.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// A class representing a Git remote repository.
///
/// This class provides methods to interact with remote repositories, including
/// fetching, pushing, and managing remote configuration.
@immutable
class Remote extends Equatable {
  /// Lookups remote with provided [name] in a [repo]sitory.
  ///
  /// The [name] will be checked for validity. If the remote doesn't exist,
  /// a [LibGit2Error] will be thrown.
  ///
  /// Throws a [LibGit2Error] if error occurred while looking up the remote.
  Remote.lookup({required Repository repo, required String name}) {
    _remotePointer = remote_bindings.lookup(
      repoPointer: repo.pointer,
      name: name,
    );
    _finalizer.attach(this, _remotePointer, detach: this);
  }

  /// Adds remote with provided [name] and [url] to the [repo]sitory's
  /// configuration.
  ///
  /// If [fetch] is provided, it will be used as the fetch refspec. Otherwise,
  /// the default fetch refspec will be used.
  ///
  /// The [name] and [url] will be checked for validity.
  ///
  /// Throws a [LibGit2Error] if error occurred while creating the remote.
  Remote.create({
    required Repository repo,
    required String name,
    required String url,
    String? fetch,
  }) {
    _remotePointer =
        fetch == null
            ? remote_bindings.create(
              repoPointer: repo.pointer,
              name: name,
              url: url,
            )
            : remote_bindings.createWithFetchSpec(
              repoPointer: repo.pointer,
              name: name,
              url: url,
              fetch: fetch,
            );
    _finalizer.attach(this, _remotePointer, detach: this);
  }

  /// Pointer to memory address for allocated remote object.
  late final Pointer<git_remote> _remotePointer;

  /// Deletes an existing persisted remote with provided [name].
  ///
  /// All remote-tracking branches and configuration settings for the remote
  /// will be removed. This operation cannot be undone.
  ///
  /// Throws a [LibGit2Error] if error occurred while deleting the remote.
  static void delete({required Repository repo, required String name}) =>
      remote_bindings.delete(repoPointer: repo.pointer, name: name);

  /// Renames remote with provided [oldName] to [newName].
  ///
  /// Returns list of non-default refspecs that cannot be renamed.
  ///
  /// All remote-tracking branches and configuration settings for the remote
  /// are updated to reflect the new name.
  ///
  /// The [newName] will be checked for validity.
  ///
  /// No loaded instances of a the remote with the old name will change their
  /// name or their list of refspecs.
  ///
  /// Throws a [LibGit2Error] if error occurred while renaming the remote.
  static List<String> rename({
    required Repository repo,
    required String oldName,
    required String newName,
  }) => remote_bindings.rename(
    repoPointer: repo.pointer,
    name: oldName,
    newName: newName,
  );

  /// Returns a list of the configured remotes for a [repo]sitory.
  ///
  /// This includes all remotes that have been added to the repository's
  /// configuration, regardless of whether they are currently valid or accessible.
  static List<String> list(Repository repo) =>
      remote_bindings.list(repo.pointer);

  /// Sets the [remote]'s [url] in the configuration.
  ///
  /// Remote objects already in memory will not be affected. This assumes the
  /// common case of a single-url remote and will otherwise return an error.
  ///
  /// The [url] will be checked for validity.
  ///
  /// Throws a [LibGit2Error] if error occurred while setting the URL.
  static void setUrl({
    required Repository repo,
    required String remote,
    required String url,
  }) => remote_bindings.setUrl(
    repoPointer: repo.pointer,
    remote: remote,
    url: url,
  );

  /// Sets the [remote]'s [url] for pushing in the configuration.
  ///
  /// Remote objects already in memory will not be affected. This assumes the
  /// common case of a single-url remote and will otherwise return an error.
  ///
  /// The [url] will be checked for validity.
  ///
  /// Throws a [LibGit2Error] if error occurred while setting the push URL.
  static void setPushUrl({
    required Repository repo,
    required String remote,
    required String url,
  }) => remote_bindings.setPushUrl(
    repoPointer: repo.pointer,
    remote: remote,
    url: url,
  );

  /// Adds a fetch [refspec] to the [remote]'s configuration.
  ///
  /// The [refspec] will be checked for validity.
  ///
  /// No loaded remote instances will be affected.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  static void addFetch({
    required Repository repo,
    required String remote,
    required String refspec,
  }) {
    remote_bindings.addFetch(
      repoPointer: repo.pointer,
      remote: remote,
      refspec: refspec,
    );
  }

  /// Adds a push [refspec] to the [remote]'s configuration.
  ///
  /// The [refspec] will be checked for validity.
  ///
  /// No loaded remote instances will be affected.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  static void addPush({
    required Repository repo,
    required String remote,
    required String refspec,
  }) {
    remote_bindings.addPush(
      repoPointer: repo.pointer,
      remote: remote,
      refspec: refspec,
    );
  }

  /// Remote's name.
  ///
  /// Returns the name of the remote or an empty string if the remote is anonymous.
  String get name => remote_bindings.name(_remotePointer);

  /// Remote's url.
  ///
  /// Returns the URL of the remote repository.
  String get url => remote_bindings.url(_remotePointer);

  /// Remote's url for pushing.
  ///
  /// Returns empty string if no special url for pushing is set.
  String get pushUrl => remote_bindings.pushUrl(_remotePointer);

  /// Number of refspecs for a remote.
  ///
  /// This includes both fetch and push refspecs.
  int get refspecCount => remote_bindings.refspecCount(_remotePointer);

  /// [Refspec] object from the remote at provided position.
  ///
  /// The [index] must be between 0 and [refspecCount] - 1.
  ///
  /// Throws a [LibGit2Error] if error occurred while getting the refspec.
  Refspec getRefspec(int index) => Refspec(
    remote_bindings.getRefspec(remotePointer: _remotePointer, position: index),
  );

  /// List of fetch refspecs.
  ///
  /// Returns all refspecs that are used for fetching from the remote.
  List<String> get fetchRefspecs =>
      remote_bindings.fetchRefspecs(_remotePointer);

  /// List of push refspecs.
  ///
  /// Returns all refspecs that are used for pushing to the remote.
  List<String> get pushRefspecs => remote_bindings.pushRefspecs(_remotePointer);

  /// Returns the remote repository's reference list and their associated
  /// commit ids.
  ///
  /// This method connects to the remote repository and retrieves a list of
  /// all references (branches, tags, etc.) that are available on the remote.
  ///
  /// [proxy] can be 'auto' to try to auto-detect the proxy from the git
  /// configuration or some specified url. By default connection isn't done
  /// through proxy.
  ///
  /// [callbacks] is the combination of callback functions from [Callbacks]
  /// object.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  List<RemoteReference> ls({
    String? proxy,
    Callbacks callbacks = const Callbacks(),
  }) {
    remote_bindings.connect(
      remotePointer: _remotePointer,
      direction: git_direction.fromValue(GitDirection.fetch.value),
      callbacks: callbacks,
      proxyOption: proxy,
    );
    final refs = remote_bindings.lsRemotes(_remotePointer);
    remote_bindings.disconnect(_remotePointer);

    return <RemoteReference>[
      for (final ref in refs)
        RemoteReference._(
          isLocal: ref['local']! as bool,
          localId: ref['loid'] as Oid?,
          name: ref['name']! as String,
          oid: ref['oid']! as Oid,
          symRef: ref['symref']! as String,
        ),
    ];
  }

  /// Downloads new data and updates tips.
  ///
  /// This method connects to the remote repository, downloads any new data,
  /// and updates the local repository's remote-tracking branches.
  ///
  /// [refspecs] is the list of refspecs to use for this fetch. Defaults to the
  /// base refspecs.
  ///
  /// [reflogMessage] is the message to insert into the reflogs. Default is
  /// "fetch".
  ///
  /// [prune] determines whether to perform a prune after the fetch.
  ///
  /// [proxy] can be 'auto' to try to auto-detect the proxy from the git
  /// configuration or some specified url. By default connection isn't done
  /// through proxy.
  ///
  /// [callbacks] is the combination of callback functions from [Callbacks]
  /// object.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  TransferProgress fetch({
    List<String> refspecs = const [],
    String? reflogMessage,
    GitFetchPrune prune = GitFetchPrune.unspecified,
    String? proxy,
    Callbacks callbacks = const Callbacks(),
  }) {
    remote_bindings.fetch(
      remotePointer: _remotePointer,
      refspecs: refspecs,
      prune: prune.value,
      callbacks: callbacks,
      reflogMessage: reflogMessage,
      proxyOption: proxy,
    );
    return TransferProgress(remote_bindings.stats(_remotePointer));
  }

  /// Performs a push.
  ///
  /// This method connects to the remote repository and pushes the specified
  /// references to it.
  ///
  /// [refspecs] is the list of refspecs to use for pushing. Defaults to the
  /// configured refspecs.
  ///
  /// [proxy] can be 'auto' to try to auto-detect the proxy from the git
  /// configuration or some specified url. By default connection isn't done
  /// through proxy.
  ///
  /// [callbacks] is the combination of callback functions from [Callbacks]
  /// object.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void push({
    List<String> refspecs = const [],
    String? proxy,
    Callbacks callbacks = const Callbacks(),
  }) {
    remote_bindings.push(
      remotePointer: _remotePointer,
      refspecs: refspecs,
      callbacks: callbacks,
      proxyOption: proxy,
    );
  }

  /// Prunes tracking refs that are no longer present on remote.
  ///
  /// This method removes any remote-tracking branches that no longer exist
  /// on the remote repository.
  ///
  /// [callbacks] is the combination of callback functions from [Callbacks]
  /// object.
  ///
  /// Throws a [LibGit2Error] if error occurred.
  void prune([Callbacks callbacks = const Callbacks()]) {
    using((arena) {
      final remoteCallbacks = arena<git_remote_callbacks>();
      remoteCallbacks.ref.version = 1;
      RemoteCallbacks.plug(
        callbacksOptions: remoteCallbacks.ref,
        callbacks: callbacks,
        arena: arena,
      );
      remote_bindings.prune(
        remotePointer: _remotePointer,
        flags: remoteCallbacks,
      );
    });
  }

  /// Releases memory allocated for remote object.
  ///
  /// This method should be called when you are done with the remote object
  /// to free the allocated memory.
  void free() {
    remote_bindings.free(_remotePointer);
    _finalizer.detach(this);
  }

  @override
  String toString() {
    return 'Remote{name: $name, url: $url, pushUrl: $pushUrl, '
        'refspecCount: $refspecCount}';
  }

  @override
  List<Object?> get props => [name];
}

// coverage:ignore-start
final _finalizer = Finalizer<Pointer<git_remote>>(
  (pointer) => remote_bindings.free(pointer),
);
// coverage:ignore-end

/// Provides callers information about the progress of indexing a packfile,
/// either directly or part of a fetch or clone that downloads a packfile.
class TransferProgress {
  /// Initializes a new instance of [TransferProgress] class from provided
  /// pointer to transfer progress object in memory.
  ///
  /// Note: For internal use.
  @internal
  const TransferProgress(this._transferProgressPointer);

  /// Pointer to memory address for allocated transfer progress object.
  final Pointer<git_indexer_progress> _transferProgressPointer;

  /// Total number of objects to download.
  int get totalObjects => _transferProgressPointer.ref.total_objects;

  /// Number of objects that have been indexed.
  int get indexedObjects => _transferProgressPointer.ref.indexed_objects;

  /// Number of objects that have been downloaded.
  int get receivedObjects => _transferProgressPointer.ref.received_objects;

  /// Number of local objects that have been used to fix the thin pack.
  int get localObjects => _transferProgressPointer.ref.local_objects;

  /// Total number of deltas in the pack.
  int get totalDeltas => _transferProgressPointer.ref.total_deltas;

  /// Number of deltas that have been indexed.
  int get indexedDeltas => _transferProgressPointer.ref.indexed_deltas;

  /// Number of bytes received up to now.
  int get receivedBytes => _transferProgressPointer.ref.received_bytes;

  @override
  String toString() {
    return 'TransferProgress{totalObjects: $totalObjects, '
        'indexedObjects: $indexedObjects, receivedObjects: $receivedObjects, '
        'localObjects: $localObjects, totalDeltas: $totalDeltas, '
        'indexedDeltas: $indexedDeltas, receivedBytes: $receivedBytes}';
  }
}

/// Values used to override the remote creation and customization process
/// during a repository clone operation.
class RemoteCallback {
  /// Remote will have provided [name] and [url] with the default [fetch]
  /// refspec if none provided.
  const RemoteCallback({required this.name, required this.url, this.fetch});

  /// Remote's name.
  final String name;

  /// Remote's url.
  final String url;

  /// Remote's fetch refspec.
  final String? fetch;
}

/// A class representing a reference in a remote repository.
@immutable
class RemoteReference extends Equatable {
  const RemoteReference._({
    required this.isLocal,
    required this.localId,
    required this.name,
    required this.oid,
    required this.symRef,
  });

  /// Whether remote head is available locally.
  final bool isLocal;

  /// Oid of the object the local copy of the remote head is currently pointing
  /// to. Null if there is no local copy of the remote head.
  final Oid? localId;

  /// Name of the reference.
  final String name;

  /// Oid of the object the remote head is currently pointing to.
  final Oid oid;

  /// Target of the symbolic reference or empty string if reference is direct.
  final String symRef;

  @override
  String toString() {
    return 'RemoteReference{isLocal: $isLocal, localId: $localId, '
        'name: $name, oid: $oid, symRef: $symRef}';
  }

  @override
  List<Object?> get props => [isLocal, localId, name, oid, symRef];
}
