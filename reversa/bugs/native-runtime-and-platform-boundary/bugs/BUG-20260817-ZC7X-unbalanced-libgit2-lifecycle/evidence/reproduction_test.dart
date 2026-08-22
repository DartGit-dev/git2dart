// ignore_for_file: avoid_print

import 'package:git2dart/git2dart.dart' as git2dart;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:test/test.dart';

int probeInitializationCount() {
  final count = libgit2.git_libgit2_init();
  final restored = libgit2.git_libgit2_shutdown();
  if (restored != count - 1) {
    throw StateError('Probe did not restore the initialization count.');
  }
  return count;
}

void main() {
  test('repeated public calls increase the native initialization count', () {
    final beforePublicCalls = probeInitializationCount();
    final firstVersion = git2dart.Libgit2.version;
    final afterFirstCall = probeInitializationCount();
    final secondVersion = git2dart.Libgit2.version;
    final afterSecondCall = probeInitializationCount();

    libgit2.git_libgit2_shutdown();
    libgit2.git_libgit2_shutdown();

    print('version1=$firstVersion');
    print('version2=$secondVersion');
    print('before=$beforePublicCalls');
    print('afterFirst=$afterFirstCall');
    print('afterSecond=$afterSecondCall');

    expect(afterFirstCall, beforePublicCalls + 1);
    expect(afterSecondCall, afterFirstCall + 1);
  });
}
