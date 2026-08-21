// ignore_for_file: file_names

import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/remote_callbacks.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:test/test.dart';

void main() {
  test('failed remote operation retains callback state', () {
    final temp = Directory.systemTemp.createTempSync(
      'git2dart-callback-cleanup-',
    );
    final repo = Repository.init(
      path: temp.path,
      originUrl: 'http://127.0.0.1:1/repository.git',
    );
    final remote = Remote.lookup(repo: repo, name: 'origin');

    try {
      expect(RemoteCallbacks.credentials, isNull);
      expect(
        () => remote.fetch(
          callbacks: const Callbacks(
            credentials: UserPass(
              username: 'synthetic-user',
              password: 'synthetic-password',
            ),
          ),
        ),
        throwsA(isA<LibGit2Error>()),
      );
      expect(RemoteCallbacks.credentials, isNotNull);
    } finally {
      RemoteCallbacks.reset();
      remote.free();
      repo.free();
      temp.deleteSync(recursive: true);
    }
  });
}
