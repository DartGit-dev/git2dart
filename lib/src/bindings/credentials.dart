import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Creates a new plain-text username and password credential object.
///
/// This is the simplest credential type, used for basic authentication.
/// Note that this method transmits credentials in plain text, so it should
/// only be used with HTTPS repositories and never with unencrypted protocols.
///
/// [username] - The username to authenticate with
/// [password] - The password to authenticate with
///
/// Returns a pointer to the newly created credential object.
Pointer<git_credential> userPass({
  required String username,
  required String password,
}) {
  final out = calloc<Pointer<git_credential>>();
  final usernameC = username.toChar();
  final passwordC = password.toChar();

  libgit2.git_credential_userpass_plaintext_new(out, usernameC, passwordC);

  final result = out.value;

  calloc.free(out);
  calloc.free(usernameC);
  calloc.free(passwordC);

  return result;
}

/// Creates a new passphrase-protected SSH key credential object.
///
/// This credential type is used for SSH authentication with a key pair.
/// The keys should be in the standard OpenSSH format.
///
/// [username] - The username to authenticate with
/// [publicKey] - Path to the public key file
/// [privateKey] - Path to the private key file
/// [passPhrase] - Passphrase to decrypt the private key (empty string if none)
///
/// Returns a pointer to the newly created credential object.
Pointer<git_credential> sshKey({
  required String username,
  required String publicKey,
  required String privateKey,
  required String passPhrase,
}) {
  final out = calloc<Pointer<git_credential>>();
  final usernameC = username.toChar();
  final publicKeyC = publicKey.toChar();
  final privateKeyC = privateKey.toChar();
  final passPhraseC = passPhrase.toChar();

  libgit2.git_credential_ssh_key_new(
    out,
    usernameC,
    publicKeyC,
    privateKeyC,
    passPhraseC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(usernameC);
  calloc.free(publicKeyC);
  calloc.free(privateKeyC);
  calloc.free(passPhraseC);

  return result;
}

/// Creates a new SSH key credential object that uses an SSH agent.
///
/// This credential type delegates authentication to an SSH agent.
/// The agent must be running and accessible to the application.
///
/// [username] - The username to authenticate with
///
/// Returns a pointer to the newly created credential object.
Pointer<git_credential> sshKeyFromAgent(String username) {
  final out = calloc<Pointer<git_credential>>();
  final usernameC = username.toChar();

  libgit2.git_credential_ssh_key_from_agent(out, usernameC);

  final result = out.value;

  calloc.free(out);
  calloc.free(usernameC);

  return result;
}

/// Creates a new SSH key credential object with keys stored in memory.
///
/// This credential type is useful when the keys are generated dynamically
/// or stored in memory rather than on disk.
///
/// [username] - The username to authenticate with
/// [publicKey] - The public key data
/// [privateKey] - The private key data
/// [passPhrase] - Passphrase to decrypt the private key (empty string if none)
///
/// Returns a pointer to the newly created credential object.
Pointer<git_credential> sshKeyFromMemory({
  required String username,
  required String publicKey,
  required String privateKey,
  required String passPhrase,
}) {
  final out = calloc<Pointer<git_credential>>();
  final usernameC = username.toChar();
  final publicKeyC = publicKey.toChar();
  final privateKeyC = privateKey.toChar();
  final passPhraseC = passPhrase.toChar();

  libgit2.git_credential_ssh_key_memory_new(
    out,
    usernameC,
    publicKeyC,
    privateKeyC,
    passPhraseC,
  );

  final result = out.value;

  calloc.free(out);
  calloc.free(usernameC);
  calloc.free(publicKeyC);
  calloc.free(privateKeyC);
  calloc.free(passPhraseC);

  return result;
}
