import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
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
  return using((arena) {
    final out = arena<Pointer<git_credential>>();
    final usernameC = username.toChar(arena);
    final passwordC = password.toChar(arena);

    final error = libgit2.git_credential_userpass_plaintext_new(
      out,
      usernameC,
      passwordC,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
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
  final usernameC = username.toCharAlloc();
  final publicKeyC = publicKey.toCharAlloc();
  final privateKeyC = privateKey.toCharAlloc();
  final passPhraseC = passPhrase.toCharAlloc();

  final error = libgit2.git_credential_ssh_key_new(
    out,
    usernameC,
    publicKeyC,
    privateKeyC,
    passPhraseC,
  );
  checkErrorAndThrow(error);

  return out.value;
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
  return using((arena) {
    final out = arena<Pointer<git_credential>>();
    final usernameC = username.toChar(arena);

    final error = libgit2.git_credential_ssh_key_from_agent(out, usernameC);
    checkErrorAndThrow(error);

    return out.value;
  });
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
  return using((arena) {
    final out = arena<Pointer<git_credential>>();
    final usernameC = username.toChar(arena);
    final publicKeyC = publicKey.toChar(arena);
    final privateKeyC = privateKey.toChar(arena);
    final passPhraseC = passPhrase.toChar(arena);

    final error = libgit2.git_credential_ssh_key_memory_new(
      out,
      usernameC,
      publicKeyC,
      privateKeyC,
      passPhraseC,
    );
    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Creates a new default credential usable for Negotiate mechanisms like NTLM
/// or Kerberos authentication.
Pointer<git_credential> defaultCredential() {
  return using((arena) {
    final out = arena<Pointer<git_credential>>();
    final error = libgit2.git_credential_default_new(out);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Creates a credential object that only contains a username.
Pointer<git_credential> username(String username) {
  return using((arena) {
    final out = arena<Pointer<git_credential>>();
    final usernameC = username.toChar(arena);
    final error = libgit2.git_credential_username_new(out, usernameC);
    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Check whether a credential object contains username information.
bool hasUsername(Pointer<git_credential> cred) =>
    libgit2.git_credential_has_username(cred) == 1;

/// Return the username associated with a credential object, if any.
String? getUsername(Pointer<git_credential> cred) {
  final result = libgit2.git_credential_get_username(cred);
  return result == nullptr ? null : result.toDartString();
}

/// Free a previously allocated credential.
void free(Pointer<git_credential> cred) => libgit2.git_credential_free(cred);
