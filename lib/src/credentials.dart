import 'package:git2dart/git2dart.dart';

/// Abstract base class for all credential types.
///
/// This class defines the interface for different authentication methods
/// supported by git2dart. Use one of the concrete implementations:
/// - [UserPass] - For basic username/password authentication
/// - [Keypair] - For SSH key authentication with files
/// - [KeypairFromAgent] - For SSH key authentication using an SSH agent
/// - [KeypairFromMemory] - For SSH key authentication with in-memory keys
abstract class Credentials {
  /// Returns the type of authentication method used by this credential.
  GitCredential get credentialType;
}

/// Credential type for plain-text username and password authentication.
///
/// This is the simplest credential type, used for basic authentication.
/// Note that this method transmits credentials in plain text, so it should
/// only be used with HTTPS repositories and never with unencrypted protocols.
class UserPass implements Credentials {
  const UserPass({required this.username, required this.password});

  /// The username to authenticate with.
  final String username;

  /// The password of the credential.
  final String password;

  @override
  GitCredential get credentialType => GitCredential.userPassPlainText;

  @override
  String toString() {
    return 'UserPass{username: $username, password: $password}';
  }
}

/// Credential type for passphrase-protected SSH key authentication.
///
/// This credential type is used for SSH authentication with a key pair.
/// The keys should be in the standard OpenSSH format.
class Keypair implements Credentials {
  const Keypair({
    required this.username,
    required this.pubKey,
    required this.privateKey,
    required this.passPhrase,
  });

  /// The username to authenticate with.
  final String username;

  /// The path to the public key file.
  final String pubKey;

  /// The path to the private key file.
  final String privateKey;

  /// The passphrase to decrypt the private key (empty string if none).
  final String passPhrase;

  @override
  GitCredential get credentialType => GitCredential.sshKey;

  @override
  String toString() {
    return 'Keypair{username: $username, pubKey: $pubKey, '
        'privateKey: $privateKey, passPhrase: $passPhrase}';
  }
}

/// Credential type for SSH key authentication using an SSH agent.
///
/// This credential type delegates authentication to an SSH agent.
/// The agent must be running and accessible to the application.
class KeypairFromAgent implements Credentials {
  const KeypairFromAgent(this.username);

  /// The username to authenticate with.
  final String username;

  @override
  GitCredential get credentialType => GitCredential.sshKey;

  @override
  String toString() => 'KeypairFromAgent{username: $username}';
}

/// Credential type for SSH key authentication with in-memory keys.
///
/// This credential type is useful when the keys are generated dynamically
/// or stored in memory rather than on disk.
class KeypairFromMemory implements Credentials {
  const KeypairFromMemory({
    required this.username,
    required this.pubKey,
    required this.privateKey,
    required this.passPhrase,
  });

  /// The username to authenticate with.
  final String username;

  /// The public key data.
  final String pubKey;

  /// The private key data.
  final String privateKey;

  /// The passphrase to decrypt the private key (empty string if none).
  final String passPhrase;

  @override
  GitCredential get credentialType => GitCredential.sshMemory;

  @override
  String toString() {
    return 'KeypairFromMemory{username: $username, pubKey: $pubKey, '
        'privateKey: $privateKey, passPhrase: $passPhrase}';
  }
}
