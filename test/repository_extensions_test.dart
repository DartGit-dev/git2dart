import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  late Repository repo;
  late Directory tmpDir;
  const lastCommit = '821ed6e80627b8769d170a293862f9fc60825226';

  setUp(() {
    tmpDir = setupRepo(Directory(p.join('test', 'assets', 'test_repo')));
    repo = Repository.open(tmpDir.path);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('Repository entensions', () {
    test('get head commit', () {
      expect(repo.headCommit.oid.sha, lastCommit);
    });

    test('create commit on HEAD', () {
      final signature = Signature.create(
        name: 'Author',
        email: 'author@email.com',
        time: 1234,
      );

      final fileName = 'modified_file';
      File(p.join(tmpDir.path, fileName))
        ..createSync()
        ..writeAsStringSync("contents");

      final oid = repo.createCommitOnHead(
        [fileName],
        signature,
        signature,
        'test',
      );

      expect(repo.headCommit.oid, oid);
    });
  });
}
