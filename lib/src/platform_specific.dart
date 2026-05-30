import 'dart:io';
import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart' as binaries;

class PlatformSpecific {
  /// Initializes platform-specific git2dart runtime support.
  ///
  /// Call this once during Flutter application startup before using git2dart
  /// APIs. It currently configures Android SSL certificates and eagerly loads
  /// libgit2 on iOS.
  static Future<void> initialize() async {
    await androidInitialize();
    await iosInitialize();
  }

  static Future<void> androidInitialize() async {
    // Initialize SSL certificates for Android
    if (Platform.isAndroid) {
      Libgit2.version;

      final certPath = await binaries.AndroidSSLHelper.initialize();
      Libgit2.setSSLCertLocations(file: certPath);
    }
  }

  /// Initializes iOS runtime support.
  ///
  /// iOS links libgit2 statically through the git2dart_binaries pod. Accessing
  /// [Libgit2.version] ensures the symbols are available and initializes the
  /// native library through the generated bindings.
  static Future<void> iosInitialize() async {
    if (Platform.isIOS) {
      Libgit2.version;
    }
  }
}
