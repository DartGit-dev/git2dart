import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers/util.dart';

void main() {
  late Repository repo;
  late Directory tmpDir;

  setUp(() {
    tmpDir = setupRepo(Directory(p.join('test', 'assets', 'attributes_repo')));
    repo = Repository.open(tmpDir.path);
    repo.reset(oid: repo.head.target, resetType: GitReset.hard);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('Filter', () {
    test('applies filter list to data, file and blob', () {
      final filePath = p.join(repo.workdir, 'file.crlf');
      File(filePath).writeAsStringSync('clrf\nclrf\n');

      final filter = Filter.load(
        repo: repo,
        path: 'file.crlf',
        mode: GitFilterMode.toWorktree,
      );

      expect(filter.contains('crlf'), true);
      expect(filter.applyToData('clrf\nclrf\n'), 'clrf\r\nclrf\r\n');
      expect(
        filter.applyToFile(repo: repo, path: filePath),
        'clrf\r\nclrf\r\n',
      );

      final oid = Blob.create(repo: repo, content: 'clrf\nclrf\n');
      final blob = Blob.lookup(repo: repo, oid: oid);
      expect(filter.applyToBlob(blob), 'clrf\r\nclrf\r\n');

      filter.free();
    });

    test('loads filter list with options', () {
      final options = FilterOptions();

      final filter = Filter.loadExt(
        repo: repo,
        path: 'file.crlf',
        mode: GitFilterMode.toWorktree,
        options: options,
      );

      options.free();
      expect(filter.applyToData('clrf\nclrf\n'), 'clrf\r\nclrf\r\n');
      filter.free();
    });
  });
}
