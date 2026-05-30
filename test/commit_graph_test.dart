import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  late Repository repo;
  late Directory tmpDir;

  setUp(() {
    tmpDir = setupRepo(Directory(p.join('test', 'assets', 'test_repo')));
    repo = Repository.open(tmpDir.path);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('CommitGraph', () {
    test('writes and opens commit graph', () {
      final writer = CommitGraphWriter(p.join(repo.path, 'objects', 'info'));
      final revWalk = RevWalk(repo)..pushHead();

      writer.addRevWalk(revWalk);
      expect(writer.dump(), isNotEmpty);
      writer.commit();

      final graph = CommitGraph.open(p.join(repo.path, 'objects'));
      expect(() => graph.free(), returnsNormally);
      expect(() => writer.free(), returnsNormally);
    });

    test('throws when opening from invalid objects directory', () {
      expect(
        () => CommitGraph.open(p.join(tmpDir.path, 'not-there')),
        throwsA(isA<LibGit2Error>()),
      );
    });
  });
}
