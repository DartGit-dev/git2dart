import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  late Repository repo;
  late Directory tmpDir;
  const commitSha = '78b8bf123e3952c970ae5c1ce0a3ea1d1336f6e8';
  const tagSha = 'f0fdbf506397e9f58c59b88dfdd72778ec06cc0c';
  const peeledCommitSha = '821ed6e80627b8769d170a293862f9fc60825226';

  setUp(() {
    tmpDir = setupRepo(Directory(p.join('test', 'assets', 'test_repo')));
    repo = Repository.open(tmpDir.path);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('GitObject', () {
    test('lookup, type and shortId', () {
      final object = GitObject.lookup(
        repo: repo,
        oid: repo[commitSha],
      );

      expect(object.oid.sha, commitSha);
      expect(object.type, GitObjectType.commit);
      expect(object.shortId, '78b8bf1');
      object.free();
    });

    test('peel object to commit', () {
      final tagObject = GitObject.lookup(
        repo: repo,
        oid: repo[tagSha],
        type: GitObjectType.tag,
      );

      final peeled = tagObject.peel(targetType: GitObjectType.commit);

      expect(peeled.oid.sha, peeledCommitSha);

      peeled.free();
      tagObject.free();
    });

    test('string2type and type2string', () {
      final type = GitObject.string2type('commit');
      expect(type, GitObjectType.commit);
      expect(GitObject.type2string(type), 'commit');
    });
  });
}
