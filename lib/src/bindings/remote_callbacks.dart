import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/credentials.dart' as credentials_bindings;
import 'package:git2dart/src/bindings/remote.dart' as remote_bindings;
import 'package:git2dart/src/bindings/repository.dart' as repository_bindings;
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// A class that manages callbacks for remote operations in Git.
/// These callbacks are used during fetch, push, and clone operations
/// to provide progress updates and handle authentication.
class RemoteCallbacks {
  /// Callback function that reports transfer progress during fetch/push operations.
  /// Provides information about the number of objects being transferred.
  static void Function(TransferProgress)? transferProgress;

  /// Native callback that converts C transfer progress data to Dart [TransferProgress].
  /// Called by libgit2 during fetch/push operations.
  static int transferProgressCb(
    Pointer<git_indexer_progress> stats,
    Pointer<Void> payload,
  ) {
    transferProgress!(TransferProgress(stats));
    return 0;
  }

  /// Callback function that reports textual progress messages from the remote.
  /// Used for receiving status messages during remote operations.
  static int Function(Pointer<Char>, int, Pointer<Void>)? sidebandProgress;

  /// Native callback that handles sideband progress messages from the remote.
  /// Converts C string data to Dart format.
  static int sidebandProgressCb(
    Pointer<Char> progressOutput,
    int length,
    Pointer<Void> payload,
  ) {
    sidebandProgress!(progressOutput, length, payload);
    return 0;
  }

  /// Callback function that reports reference updates during fetch operations.
  /// Provides information about which references were updated and their new OIDs.
  static void Function(String, Oid, Oid)? updateTips;

  /// Native callback that handles reference updates during fetch.
  /// Converts C reference data to Dart format.
  static int updateTipsCb(
    Pointer<Char> refname,
    Pointer<git_oid> oldOid,
    Pointer<git_oid> newOid,
    Pointer<Void> payload,
  ) {
    updateTips!(refname.toDartString(), Oid(oldOid), Oid(newOid));
    return 0;
  }

  /// Callback function used to inform of the update status from the remote during push.
  /// If the message is not empty, the update was rejected by the remote server.
  static void Function(String, String)? pushUpdateReference;

  /// Native callback that handles push reference updates.
  /// Reports success or failure of reference updates during push.
  static int pushUpdateReferenceCb(
    Pointer<Char> refname,
    Pointer<Char> message,
    Pointer<Void> payload,
  ) {
    final messageResult = message == nullptr ? '' : message.toDartString();
    pushUpdateReference!(refname.toDartString(), messageResult);
    return 0;
  }

  /// Values used to override the remote creation and customization process
  /// during a clone operation.
  static RemoteCallback? remoteCbData;

  /// Native callback used to create the git remote during clone.
  /// Allows customization of the remote before it's used for cloning.
  static int remoteCb(
    Pointer<Pointer<git_remote>> remote,
    Pointer<git_repository> repo,
    Pointer<Char> name,
    Pointer<Char> url,
    Pointer<Void> payload,
  ) {
    late final Pointer<git_remote> remotePointer;

    if (remoteCbData!.fetch == null) {
      remotePointer = remote_bindings.create(
        repoPointer: repo,
        name: remoteCbData!.name,
        url: remoteCbData!.url,
      );
    } else {
      remotePointer = remote_bindings.createWithFetchSpec(
        repoPointer: repo,
        name: remoteCbData!.name,
        url: remoteCbData!.url,
        fetch: remoteCbData!.fetch!,
      );
    }

    remote[0] = remotePointer;

    return 0;
  }

  /// Values used to override the repository creation and customization process
  /// during a clone operation.
  static RepositoryCallback? repositoryCbData;

  /// Native callback used to create the new repository during clone.
  /// Allows customization of the repository before cloning begins.
  static int repositoryCb(
    Pointer<Pointer<git_repository>> repo,
    Pointer<Char> path,
    int bare,
    Pointer<Void> payload,
  ) {
    var flagsInt = repositoryCbData!.flags.fold(
      0,
      (int acc, e) => acc | e.value,
    );

    if (repositoryCbData!.bare) {
      flagsInt |= GitRepositoryInit.bare.value;
    }

    final repoPointer = repository_bindings.init(
      path: repositoryCbData!.path,
      flags: flagsInt,
      mode: repositoryCbData!.mode,
      workdirPath: repositoryCbData!.workdirPath,
      description: repositoryCbData!.description,
      templatePath: repositoryCbData!.templatePath,
      initialHead: repositoryCbData!.initialHead,
      originUrl: repositoryCbData!.originUrl,
    );

    repo[0] = repoPointer;

    return 0;
  }

  /// [Credentials] object used for authentication in order to connect to remote.
  /// Handles various authentication methods like username/password and SSH keys.
  static Credentials? credentials;

  /// Native callback for credential acquisition during remote operations.
  /// Called when the remote host requires authentication.
  static int credentialsCb(
    Pointer<Pointer<git_credential>> credPointer,
    Pointer<Char> url,
    Pointer<Char> username,
    int allowedTypes,
    Pointer<Void> payload,
  ) {
    if (payload.cast<Char>().value == 2) {
      throw LibGit2Error(libgit2.git_error_last());
    }

    final credentialType = credentials!.credentialType;

    if (allowedTypes & credentialType.value != credentialType.value) {
      throw LibGit2Error(libgit2.git_error_last());
    }

    if (credentials is UserPass) {
      final cred = credentials! as UserPass;
      credPointer[0] = credentials_bindings.userPass(
        username: cred.username,
        password: cred.password,
      );
      payload.cast<Int8>().value++;
    }

    if (credentials is Keypair) {
      final cred = credentials! as Keypair;
      credPointer[0] = credentials_bindings.sshKey(
        username: cred.username,
        publicKey: cred.pubKey,
        privateKey: cred.privateKey,
        passPhrase: cred.passPhrase,
      );
      payload.cast<Int8>().value++;
    }

    if (credentials is KeypairFromAgent) {
      final cred = credentials! as KeypairFromAgent;
      credPointer[0] = credentials_bindings.sshKeyFromAgent(cred.username);
      payload.cast<Int8>().value++;
    }

    if (credentials is KeypairFromMemory) {
      final cred = credentials! as KeypairFromMemory;
      credPointer[0] = credentials_bindings.sshKeyFromMemory(
        username: cred.username,
        publicKey: cred.pubKey,
        privateKey: cred.privateKey,
        passPhrase: cred.passPhrase,
      );
      payload.cast<Int8>().value++;
    }

    return 0;
  }

  /// Plugs provided callbacks into libgit2 callbacks structure.
  /// Sets up all the necessary callback functions for remote operations.
  static void plug({
    required git_remote_callbacks callbacksOptions,
    required Callbacks callbacks,
  }) {
    const except = -1;

    if (callbacks.transferProgress != null) {
      transferProgress = callbacks.transferProgress;
      callbacksOptions.transfer_progress = Pointer.fromFunction(
        transferProgressCb,
        except,
      );
    }

    if (callbacks.sidebandProgress != null) {
      sidebandProgress = (message, len, payload) {
        callbacks.sidebandProgress!(message.toDartString(), len, payload);
        return 0;
      };
      callbacksOptions.sideband_progress = Pointer.fromFunction(
        sidebandProgressCb,
        except,
      );
    }

    if (callbacks.updateTips != null) {
      updateTips = callbacks.updateTips;
      callbacksOptions.update_tips = Pointer.fromFunction(updateTipsCb, except);
    }

    if (callbacks.pushUpdateReference != null) {
      pushUpdateReference = callbacks.pushUpdateReference;
      callbacksOptions.push_update_reference = Pointer.fromFunction(
        pushUpdateReferenceCb,
        except,
      );
    }

    if (callbacks.credentials != null) {
      credentials = callbacks.credentials;
      final payload = calloc<Int8>()..value = 1;
      callbacksOptions.payload = payload.cast();
      callbacksOptions.credentials = Pointer.fromFunction(
        credentialsCb,
        except,
      );
    }
  }

  /// Resets all callback functions to their original null values.
  /// Should be called after remote operations are complete.
  static void reset() {
    transferProgress = null;
    sidebandProgress = null;
    updateTips = null;
    pushUpdateReference = null;
    remoteCbData = null;
    repositoryCbData = null;
    credentials = null;
  }
}
