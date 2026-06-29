import 'package:git2dart/git2dart.dart';

/// Callback for validating a remote certificate.
///
/// Return `true` to accept the certificate, or `false` to reject it.
typedef CertificateCheck =
    bool Function(
      GitCertificate certificate,
      String host, {
      required bool valid,
    });

/// A class that encapsulates various callback functions used in Git operations.
///
/// This class is primarily used with [Remote] methods and [Repository.clone]
/// operations to handle different aspects of Git operations:
/// - Authentication
/// - Progress tracking
/// - Certificate checks
/// - Reference updates
/// - Push status updates
class Callbacks {
  /// Creates a new instance of [Callbacks].
  ///
  /// All parameters are optional and can be provided based on the specific
  /// Git operation requirements:
  ///
  /// * [credentials] - Authentication credentials (see [Credentials] implementations)
  /// * [certificateCheck] - Remote certificate trust decision
  /// * [transferProgress] - Progress tracking for data transfers
  /// * [sidebandProgress] - Textual progress updates from remote
  /// * [updateTips] - Reference update notifications
  /// * [pushUpdateReference] - Push operation status updates
  const Callbacks({
    this.credentials,
    this.certificateCheck,
    this.transferProgress,
    this.sidebandProgress,
    this.updateTips,
    this.pushUpdateReference,
  });

  /// Authentication credentials for Git operations.
  ///
  /// Can be one of the following implementations:
  /// * [UserPass] - Username/password authentication
  /// * [Keypair] - SSH key pair authentication
  /// * [KeypairFromAgent] - SSH agent-based authentication
  /// * [KeypairFromMemory] - In-memory SSH key pair authentication
  final Credentials? credentials;

  /// Callback for validating a remote certificate.
  ///
  /// Return `true` to accept the certificate, or `false` to reject it. Leave
  /// this unset to use libgit2's default certificate validation behavior.
  ///
  /// This is especially useful on platforms such as Android where SSH
  /// `known_hosts` lookup may not be available.
  final CertificateCheck? certificateCheck;

  /// Callback for tracking data transfer progress.
  ///
  /// Provides real-time updates about the progress of data transfers
  /// during Git operations.
  final void Function(TransferProgress)? transferProgress;

  /// Callback for receiving textual progress updates from remote.
  ///
  /// Used to receive and process text-based progress messages
  /// from the remote repository.
  final void Function(String message, int len, void payload)? sidebandProgress;

  /// Callback for reference update notifications.
  ///
  /// Reports changes to references with:
  /// * [refname] - Name of the reference being updated
  /// * [old] - Previous OID of the reference
  /// * [newOne] - New OID of the reference
  final void Function(String refname, Oid old, Oid newOne)? updateTips;

  /// Callback for push operation status updates.
  ///
  /// Provides information about the status of push operations:
  /// * [refname] - Name of the reference being pushed
  /// * [message] - Status message from the remote
  final void Function(String refname, String message)? pushUpdateReference;
}
