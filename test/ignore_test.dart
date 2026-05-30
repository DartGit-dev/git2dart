import 'dart:io';

import 'package:git2dart/git2dart.dart';
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

  group('Ignore', () {
    test('adds internal ignore rule and checks ignored path', () {
      Ignore.addRule(repo: repo, rules: '*.tmp');

      expect(Ignore.pathIsIgnored(repo: repo, path: 'generated.tmp'), true);
      expect(Ignore.pathIsIgnored(repo: repo, path: 'generated.txt'), false);
    });

    test('clears internal ignore rules', () {
      Ignore.addRule(repo: repo, rules: '*.tmp');
      expect(Ignore.pathIsIgnored(repo: repo, path: 'generated.tmp'), true);

      Ignore.clearInternalRules(repo);

      expect(Ignore.pathIsIgnored(repo: repo, path: 'generated.tmp'), false);
    });

    test('returns false for path that is not ignored', () {
      expect(Ignore.pathIsIgnored(repo: repo, path: 'file'), false);
    });
  });
}
