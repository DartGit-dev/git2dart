import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:test/test.dart';

void main() {
  group('Callbacks', () {
    test('initializes certificate check callback', () {
      final cert = calloc<git_cert>();
      final callbacks = Callbacks(
        certificateCheck: (certificate, host, {required valid}) {
          expect(certificate, isA<GitCertificate>());
          expect(valid, isTrue);
          expect(host, 'github.com');

          return true;
        },
      );

      try {
        expect(
          callbacks.certificateCheck!(
            GitCertificate(cert),
            'github.com',
            valid: true,
          ),
          isTrue,
        );
      } finally {
        calloc.free(cert);
      }
    });

    test('allows certificate check callback to reject a certificate', () {
      final cert = calloc<git_cert>();
      final callbacks = Callbacks(
        certificateCheck: (certificate, host, {required valid}) => false,
      );

      try {
        expect(
          callbacks.certificateCheck!(
            GitCertificate(cert),
            'example.com',
            valid: false,
          ),
          isFalse,
        );
      } finally {
        calloc.free(cert);
      }
    });

    test('reads x509 certificate data', () {
      final cert = calloc<git_cert_x509>();
      final data = calloc<Uint8>(3);

      try {
        cert.ref.parent.cert_typeAsInt = 1;
        cert.ref.data = data.cast();
        cert.ref.len = 3;
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;

        final certificate = GitCertificate(cert.cast<git_cert>());

        expect(certificate.type, GitCertificateType.x509);
        expect(certificate.hostkey, isNull);
        expect(certificate.x509!.data, <int>[1, 2, 3]);
      } finally {
        calloc.free(data);
        calloc.free(cert);
      }
    });

    test('reads ssh hostkey hashes and raw key data', () {
      final cert = calloc<git_cert_hostkey>();
      final rawHostkey = calloc<Char>(4);

      try {
        cert.ref.parent.cert_typeAsInt = 2;
        cert.ref.typeAsInt =
            git_cert_ssh_t.GIT_CERT_SSH_SHA256.value |
            git_cert_ssh_t.GIT_CERT_SSH_RAW.value;
        cert.ref.raw_typeAsInt =
            git_cert_ssh_raw_type_t.GIT_CERT_SSH_RAW_TYPE_KEY_ED25519.value;
        cert.ref.hostkey = rawHostkey;
        cert.ref.hostkey_len = 4;

        for (var i = 0; i < 32; i++) {
          cert.ref.hash_sha256[i] = i;
        }

        rawHostkey[0] = 4;
        rawHostkey[1] = 3;
        rawHostkey[2] = 2;
        rawHostkey[3] = 1;

        final certificate = GitCertificate(cert.cast<git_cert>());
        final hostkey = certificate.hostkey!;

        expect(certificate.type, GitCertificateType.hostkeyLibssh2);
        expect(certificate.x509, isNull);
        expect(hostkey.hasSha256, isTrue);
        expect(hostkey.hasRawHostkey, isTrue);
        expect(hostkey.hasMd5, isFalse);
        expect(hostkey.rawType, GitCertificateSshRawType.ed25519);
        expect(hostkey.sha256, List<int>.generate(32, (i) => i));
        expect(hostkey.rawHostkey, <int>[4, 3, 2, 1]);
      } finally {
        calloc.free(rawHostkey);
        calloc.free(cert);
      }
    });
  });
}
