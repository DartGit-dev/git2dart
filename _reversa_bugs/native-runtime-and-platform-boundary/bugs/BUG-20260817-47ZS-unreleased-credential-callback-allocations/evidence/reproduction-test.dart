// ignore_for_file: file_names

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('credential callback path contains unmanaged allocations', () {
    final callbacksSource =
        File('lib/src/bindings/remote_callbacks.dart').readAsStringSync();
    final credentialsSource =
        File('lib/src/bindings/credentials.dart').readAsStringSync();

    final resetStart = callbacksSource.indexOf('static void reset()');
    final resetSource = callbacksSource.substring(resetStart);
    final sshKeyStart = credentialsSource.indexOf(
      'Pointer<git_credential> sshKey(',
    );
    final sshKeyEnd = credentialsSource.indexOf(
      'Pointer<git_credential> sshKeyFromAgent',
    );
    final sshKeySource = credentialsSource.substring(sshKeyStart, sshKeyEnd);

    expect(callbacksSource, contains('calloc<Int8>()'));
    expect(resetSource, isNot(contains('calloc.free(')));
    expect(RegExp('calloc<').allMatches(sshKeySource), hasLength(1));
    expect(RegExp(r'toCharAlloc\(').allMatches(sshKeySource), hasLength(4));
  });
}
