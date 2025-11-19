import 'dart:io';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart' as binaries;

class PlatformSpecific {
  static Future<void> androidInitialize() async {
    // Initialize SSL certificates for Android
    if (Platform.isAndroid) {
      Libgit2.version;

      final certPath = await binaries.AndroidSSLHelper.initialize();
      Libgit2.setSSLCertLocations(file: certPath);
    }
  }
}
