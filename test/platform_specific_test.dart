import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformSpecific', () {
    test('initializes current platform support', () async {
      await expectLater(PlatformSpecific.initialize(), completes);
    });

    test(
      'android initialization is a no-op on non-Android platforms',
      () async {
        await expectLater(PlatformSpecific.androidInitialize(), completes);
      },
    );

    test('iOS initialization is a no-op on non-iOS platforms', () async {
      await expectLater(PlatformSpecific.iosInitialize(), completes);
    });

    test('retains Android certificate and iOS eager-loading paths', () {
      final source = File('lib/src/platform_specific.dart').readAsStringSync();

      expect(source, contains('if (Platform.isAndroid)'));
      expect(source, contains('binaries.AndroidSSLHelper.initialize()'));
      expect(source, contains('if (Platform.isIOS)'));
      expect(RegExp(r'Libgit2\.version').allMatches(source), hasLength(3));
    });
  });
}
