import 'dart:ffi';
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

  group('AttrOptions', () {
    test('initializes with default arguments', () {
      final opts = AttrOptions();

      expect(opts.pointer.ref.version, GIT_ATTR_OPTIONS_VERSION);
      expect(opts.pointer.ref.flags, GitAttributeCheck.fileThenIndex.value);
      expect(opts.pointer.ref.commit_id, equals(nullptr));

      opts.free();
    });

    test('initializes with commit and flags', () {
      final commit = repo.head.target;
      final opts = AttrOptions(
        flags: {GitAttributeCheck.indexOnly, GitAttributeCheck.noSystem},
        commit: commit,
      );

      final expectedFlags =
          GitAttributeCheck.indexOnly.value | GitAttributeCheck.noSystem.value;
      expect(opts.pointer.ref.flags, expectedFlags);
      expect(opts.pointer.ref.commit_id.address, commit.pointer.address);

      // attr_commit_id should match commit id
      for (var i = 0; i < 20; i++) {
        expect(
          opts.pointer.ref.attr_commit_id.id[i],
          commit.pointer.ref.id[i],
        );
      }

      opts.free();
    });

    test('manually releases allocated memory', () {
      final opts = AttrOptions();
      expect(() => opts.free(), returnsNormally);
    });
  });
}
