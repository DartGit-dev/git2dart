import 'dart:ffi';
import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/remote.dart' as remote_bindings;
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  late Repository repo;
  late Repository originRepo;
  late Directory repoDir;
  late Directory originDir;
  late Pointer<git_remote> remote;

  setUp(() {
    repoDir = setupRepo(Directory(p.join('test', 'assets', 'test_repo')));
    originDir = Directory.systemTemp.createTempSync('remote_binding_origin');
    copyRepo(
      from: Directory(p.join('test', 'assets', 'empty_bare.git')),
      to: originDir,
    );
    repo = Repository.open(repoDir.path);
    originRepo = Repository.open(originDir.path);
    remote = remote_bindings.create(
      repoPointer: repo.pointer,
      name: 'local',
      url: originDir.path,
    );
  });

  tearDown(() {
    remote_bindings.free(remote);
    repo.free();
    originRepo.free();
    repoDir.deleteSync(recursive: true);
    originDir.deleteSync(recursive: true);
  });

  group('Remote bindings', () {
    test('create, rename and setUrl', () {
      expect(remote_bindings.name(remote), 'local');
      expect(remote_bindings.url(remote), originDir.path);

      final problems = remote_bindings.rename(
        repoPointer: repo.pointer,
        name: 'local',
        newName: 'renamed',
      );
      expect(problems, isEmpty);

      final renamed = remote_bindings.lookup(
        repoPointer: repo.pointer,
        name: 'renamed',
      );
      expect(remote_bindings.name(renamed), 'renamed');

      remote_bindings.setUrl(
        repoPointer: repo.pointer,
        remote: 'renamed',
        url: repoDir.path,
      );
      final updated = remote_bindings.lookup(
        repoPointer: repo.pointer,
        name: 'renamed',
      );
      expect(remote_bindings.url(updated), repoDir.path);

      remote_bindings.free(renamed);
      remote_bindings.free(updated);
    });

    test('connect, lsRemotes, fetch, push, disconnect and pruneRefs', () {
      final ptr = remote_bindings.lookup(
        repoPointer: repo.pointer,
        name: 'local',
      );

      remote_bindings.connect(
        remotePointer: ptr,
        direction: git_direction.fromValue(GitDirection.fetch.value),
        callbacks: const Callbacks(),
      );
      expect(remote_bindings.connected(ptr), isTrue);

      final refs = remote_bindings.lsRemotes(ptr);
      expect(refs, isNotEmpty);

      remote_bindings.disconnect(ptr);
      expect(remote_bindings.connected(ptr), isFalse);

      remote_bindings.fetch(
        remotePointer: ptr,
        refspecs: const [],
        prune: GitFetchPrune.noPrune.value,
        callbacks: const Callbacks(),
      );

      remote_bindings.push(
        remotePointer: ptr,
        refspecs: ['refs/heads/master'],
        callbacks: const Callbacks(),
      );
      expect(
        Commit.lookup(repo: originRepo, oid: originRepo.head.target).oid.sha,
        '821ed6e80627b8769d170a293862f9fc60825226',
      );

      remote_bindings.pruneRefs(remotePointer: ptr);

      remote_bindings.free(ptr);
    });

    test('throws LibGit2Error for invalid arguments', () {
      expect(
        () => remote_bindings.create(
          repoPointer: repo.pointer,
          name: '',
          url: '',
        ),
        throwsA(isA<LibGit2Error>()),
      );

      expect(
        () => remote_bindings.rename(
          repoPointer: repo.pointer,
          name: '',
          newName: '',
        ),
        throwsA(isA<LibGit2Error>()),
      );

      expect(
        () => remote_bindings.setUrl(
          repoPointer: repo.pointer,
          remote: '',
          url: '',
        ),
        throwsA(isA<LibGit2Error>()),
      );

      final invalid = remote_bindings.create(
        repoPointer: repo.pointer,
        name: 'invalid',
        url: 'https://wrong.url',
      );

      expect(
        () => remote_bindings.connect(
          remotePointer: invalid,
          direction: git_direction.fromValue(GitDirection.fetch.value),
          callbacks: const Callbacks(),
        ),
        throwsA(isA<LibGit2Error>()),
      );

      expect(
        () => remote_bindings.lsRemotes(invalid),
        throwsA(isA<LibGit2Error>()),
      );

      expect(
        () => remote_bindings.fetch(
          remotePointer: invalid,
          refspecs: const [],
          prune: GitFetchPrune.noPrune.value,
          callbacks: const Callbacks(),
        ),
        throwsA(isA<LibGit2Error>()),
      );

      expect(
        () => remote_bindings.push(
          remotePointer: invalid,
          refspecs: ['refs/heads/master'],
          callbacks: const Callbacks(),
        ),
        throwsA(isA<LibGit2Error>()),
      );

      expect(
        () => remote_bindings.pruneRefs(remotePointer: invalid),
        throwsA(isA<LibGit2Error>()),
      );

      remote_bindings.free(invalid);
    });
  });
}
