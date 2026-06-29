import 'dart:ffi';
import 'dart:typed_data';

import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Return certificate type as a `GIT_CERT_` value.
int type(Pointer<git_cert> certificatePointer) {
  return certificatePointer.ref.cert_typeAsInt;
}

/// Return certificate as SSH host key structure.
Pointer<git_cert_hostkey> hostkey(Pointer<git_cert> certificatePointer) {
  return certificatePointer.cast<git_cert_hostkey>();
}

/// Return certificate as X.509 structure.
Pointer<git_cert_x509> x509(Pointer<git_cert> certificatePointer) {
  return certificatePointer.cast<git_cert_x509>();
}

/// Return raw bitmask of available SSH host key fields.
int hostkeyTypeFlags(Pointer<git_cert_hostkey> hostkeyPointer) {
  return hostkeyPointer.ref.typeAsInt;
}

/// Return whether [flag] is set in SSH host key fields.
bool hostkeyHasFlag({
  required Pointer<git_cert_hostkey> hostkeyPointer,
  required int flag,
}) {
  return hostkeyTypeFlags(hostkeyPointer) & flag != 0;
}

/// Return whether MD5 host key hash is available.
bool hostkeyHasMd5(Pointer<git_cert_hostkey> hostkeyPointer) {
  return hostkeyHasFlag(
    hostkeyPointer: hostkeyPointer,
    flag: git_cert_ssh_t.GIT_CERT_SSH_MD5.value,
  );
}

/// Return whether SHA-1 host key hash is available.
bool hostkeyHasSha1(Pointer<git_cert_hostkey> hostkeyPointer) {
  return hostkeyHasFlag(
    hostkeyPointer: hostkeyPointer,
    flag: git_cert_ssh_t.GIT_CERT_SSH_SHA1.value,
  );
}

/// Return whether SHA-256 host key hash is available.
bool hostkeyHasSha256(Pointer<git_cert_hostkey> hostkeyPointer) {
  return hostkeyHasFlag(
    hostkeyPointer: hostkeyPointer,
    flag: git_cert_ssh_t.GIT_CERT_SSH_SHA256.value,
  );
}

/// Return whether raw SSH host key is available.
bool hostkeyHasRaw(Pointer<git_cert_hostkey> hostkeyPointer) {
  return hostkeyHasFlag(
    hostkeyPointer: hostkeyPointer,
    flag: git_cert_ssh_t.GIT_CERT_SSH_RAW.value,
  );
}

/// Return MD5 host key hash.
Uint8List hostkeyMd5(Pointer<git_cert_hostkey> hostkeyPointer) {
  return _copyArray(hostkeyPointer.ref.hash_md5, 16);
}

/// Return SHA-1 host key hash.
Uint8List hostkeySha1(Pointer<git_cert_hostkey> hostkeyPointer) {
  return _copyArray(hostkeyPointer.ref.hash_sha1, 20);
}

/// Return SHA-256 host key hash.
Uint8List hostkeySha256(Pointer<git_cert_hostkey> hostkeyPointer) {
  return _copyArray(hostkeyPointer.ref.hash_sha256, 32);
}

/// Return raw SSH host key type.
int hostkeyRawType(Pointer<git_cert_hostkey> hostkeyPointer) {
  return hostkeyPointer.ref.raw_typeAsInt;
}

/// Return raw SSH host key bytes.
Uint8List hostkeyRaw(Pointer<git_cert_hostkey> hostkeyPointer) {
  final hostkey = hostkeyPointer.ref.hostkey;
  final length = hostkeyPointer.ref.hostkey_len;

  if (hostkey == nullptr || length == 0) {
    return Uint8List(0);
  }

  return Uint8List.fromList(hostkey.cast<Uint8>().asTypedList(length));
}

/// Return raw X.509 certificate bytes.
Uint8List x509Data(Pointer<git_cert_x509> certificatePointer) {
  final dataPointer = certificatePointer.ref.data;
  final length = certificatePointer.ref.len;

  if (dataPointer == nullptr || length == 0) {
    return Uint8List(0);
  }

  return Uint8List.fromList(dataPointer.cast<Uint8>().asTypedList(length));
}

Uint8List _copyArray(Array<UnsignedChar> array, int length) {
  return Uint8List.fromList(<int>[for (var i = 0; i < length; i++) array[i]]);
}
