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

  group('Pathspec', () {
    test('matches a path', () {
      final pathspec = Pathspec(['*.txt']);

      expect(pathspec.matchesPath('dir/dir_file.txt'), true);
      expect(pathspec.matchesPath('file'), false);
    });

    test('matches workdir entries and failed entries', () {
      final pathspec = Pathspec(['*.txt', 'not-there']);
      final matches = pathspec.matchWorkdir(
        repo: repo,
        flags: {GitPathspec.findFailures},
      );

      expect(matches.entries, contains('dir/dir_file.txt'));
      expect(matches.failedEntries, ['not-there']);
      expect(() => matches.free(), returnsNormally);
      expect(() => pathspec.free(), returnsNormally);
    });

    test('matches index entries', () {
      final pathspec = Pathspec(['dir/*.txt']);
      final matches = pathspec.matchIndex(index: repo.index);

      expect(matches.entries, ['dir/dir_file.txt']);
    });

    test('matches tree entries', () {
      final tree = Commit.lookup(repo: repo, oid: repo.head.target).tree;
      final pathspec = Pathspec(['dir/*.txt']);
      final matches = pathspec.matchTree(tree: tree);

      expect(matches.entries, ['dir/dir_file.txt']);
    });

    test('throws when no match is requested as an error', () {
      final pathspec = Pathspec(['not-there']);

      expect(
        () => pathspec.matchWorkdir(
          repo: repo,
          flags: {GitPathspec.noMatchError},
        ),
        throwsA(isA<LibGit2Error>()),
      );
    });
  });
}
