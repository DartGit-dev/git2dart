import 'dart:ffi';
import 'dart:typed_data';

import 'package:git2dart/src/bindings/certificate.dart' as bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:meta/meta.dart';

/// The type of certificate presented by a remote transport.
enum GitCertificateType {
  /// No certificate was provided.
  none,

  /// An X.509 certificate.
  x509,

  /// An SSH host key provided by libssh2.
  hostkeyLibssh2,

  /// A list of certificate strings.
  strarray,

  /// A certificate type unknown to this version of git2dart.
  unknown,
}

/// The raw SSH host key algorithm.
enum GitCertificateSshRawType {
  /// The raw key type is unknown.
  unknown,

  /// RSA host key.
  rsa,

  /// DSS host key.
  dss,

  /// ECDSA P-256 host key.
  ecdsa256,

  /// ECDSA P-384 host key.
  ecdsa384,

  /// ECDSA P-521 host key.
  ecdsa521,

  /// Ed25519 host key.
  ed25519,
}

/// Certificate information provided to [Callbacks.certificateCheck].
///
/// The object is only valid while the certificate callback is executing.
class GitCertificate {
  /// Initializes a [GitCertificate] from a libgit2 certificate pointer.
  ///
  /// For internal use.
  @internal
  const GitCertificate(this._certificatePointer);

  final Pointer<git_cert> _certificatePointer;

  /// The type of certificate presented by the remote.
  GitCertificateType get type {
    return switch (bindings.type(_certificatePointer)) {
      0 => GitCertificateType.none,
      1 => GitCertificateType.x509,
      2 => GitCertificateType.hostkeyLibssh2,
      3 => GitCertificateType.strarray,
      _ => GitCertificateType.unknown,
    };
  }

  /// SSH host key information, when [type] is [GitCertificateType.hostkeyLibssh2].
  GitCertificateHostkey? get hostkey {
    if (type != GitCertificateType.hostkeyLibssh2) {
      return null;
    }

    return GitCertificateHostkey(bindings.hostkey(_certificatePointer));
  }

  /// X.509 certificate information, when [type] is [GitCertificateType.x509].
  GitCertificateX509? get x509 {
    if (type != GitCertificateType.x509) {
      return null;
    }

    return GitCertificateX509(bindings.x509(_certificatePointer));
  }
}

/// SSH host key information presented by a remote.
///
/// The object is only valid while the certificate callback is executing.
class GitCertificateHostkey {
  /// Initializes a [GitCertificateHostkey] from a libgit2 host key pointer.
  ///
  /// For internal use.
  @internal
  const GitCertificateHostkey(this._hostkeyPointer);

  final Pointer<git_cert_hostkey> _hostkeyPointer;

  /// Raw bitmask of available SSH host key fields.
  int get typeFlags => bindings.hostkeyTypeFlags(_hostkeyPointer);

  /// Whether [md5] is available.
  bool get hasMd5 => bindings.hostkeyHasMd5(_hostkeyPointer);

  /// Whether [sha1] is available.
  bool get hasSha1 => bindings.hostkeyHasSha1(_hostkeyPointer);

  /// Whether [sha256] is available.
  bool get hasSha256 => bindings.hostkeyHasSha256(_hostkeyPointer);

  /// Whether [rawHostkey] and [rawType] are available.
  bool get hasRawHostkey => bindings.hostkeyHasRaw(_hostkeyPointer);

  /// MD5 host key hash, or `null` when unavailable.
  Uint8List? get md5 {
    if (!hasMd5) {
      return null;
    }

    return bindings.hostkeyMd5(_hostkeyPointer);
  }

  /// SHA-1 host key hash, or `null` when unavailable.
  Uint8List? get sha1 {
    if (!hasSha1) {
      return null;
    }

    return bindings.hostkeySha1(_hostkeyPointer);
  }

  /// SHA-256 host key hash, or `null` when unavailable.
  Uint8List? get sha256 {
    if (!hasSha256) {
      return null;
    }

    return bindings.hostkeySha256(_hostkeyPointer);
  }

  /// Raw SSH host key algorithm.
  GitCertificateSshRawType get rawType {
    return switch (bindings.hostkeyRawType(_hostkeyPointer)) {
      1 => GitCertificateSshRawType.rsa,
      2 => GitCertificateSshRawType.dss,
      3 => GitCertificateSshRawType.ecdsa256,
      4 => GitCertificateSshRawType.ecdsa384,
      5 => GitCertificateSshRawType.ecdsa521,
      6 => GitCertificateSshRawType.ed25519,
      _ => GitCertificateSshRawType.unknown,
    };
  }

  /// Raw SSH host key bytes, or `null` when unavailable.
  Uint8List? get rawHostkey {
    if (!hasRawHostkey) {
      return null;
    }

    final result = bindings.hostkeyRaw(_hostkeyPointer);
    return result.isEmpty ? null : result;
  }
}

/// X.509 certificate information presented by a remote.
///
/// The object is only valid while the certificate callback is executing.
class GitCertificateX509 {
  /// Initializes a [GitCertificateX509] from a libgit2 certificate pointer.
  ///
  /// For internal use.
  @internal
  const GitCertificateX509(this._certificatePointer);

  final Pointer<git_cert_x509> _certificatePointer;

  /// Raw X.509 certificate bytes.
  Uint8List get data => bindings.x509Data(_certificatePointer);
}
