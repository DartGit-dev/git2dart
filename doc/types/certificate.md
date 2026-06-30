# Certificates

Certificate values are passed to `Callbacks.certificateCheck` when libgit2 asks
whether a remote certificate should be trusted.

```dart
import 'package:git2dart/git2dart.dart';
```

## Core Usage

### Certificate callback

```dart
final callbacks = Callbacks(
  certificateCheck: (certificate, host, {required valid}) {
    if (valid) {
      return true;
    }

    if (certificate.type == GitCertificateType.hostkeyLibssh2) {
      final hostkey = certificate.hostkey;
      return host == 'github.com' && hostkey?.hasSha256 == true;
    }

    return false;
  },
);
```

`valid` is libgit2's default validation result. Return `true` to accept the
certificate or `false` to reject it.

### Certificate types

`GitCertificate.type` can be:

- `GitCertificateType.none`
- `GitCertificateType.x509`
- `GitCertificateType.hostkeyLibssh2`
- `GitCertificateType.strarray`
- `GitCertificateType.unknown`

For X.509 certificates, use `certificate.x509?.data` to read the raw bytes.

For SSH host keys, use `certificate.hostkey` to inspect available hashes and raw
key data:

```dart
final hostkey = certificate.hostkey;
final sha256 = hostkey?.sha256;
final rawType = hostkey?.rawType;
```

`GitCertificateSshRawType` identifies the raw SSH key algorithm, including RSA,
DSS, ECDSA variants, Ed25519, or `unknown`.

Certificate objects are only valid while the certificate callback is executing.

## Important Options

Use `GitCertificateType` to branch on certificate shape and `GitCertificateSshRawType` when inspecting raw SSH host keys.

## Lifecycle and Errors

`GitCertificate` and nested certificate views are callback-scoped. Do not store them after `certificateCheck` returns; copy the bytes you need inside the callback.

## See Also

- [callbacks_test.dart](../../test/callbacks_test.dart)
