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

  group('FilterOptions', () {
    test('initializes with default arguments', () {
      final opts = FilterOptions();

      expect(opts.pointer.ref.version, GIT_FILTER_OPTIONS_VERSION);
      expect(opts.pointer.ref.flags, GitFilterFlag.defaults.value);
      expect(opts.pointer.ref.commit_id, equals(nullptr));

      opts.free();
    });

    test('initializes with commit and flags', () {
      final commit = repo.head.target;
      final opts = FilterOptions(
        flags: {
          GitFilterFlag.noSystemAttributes,
          GitFilterFlag.attributesFromCommit,
        },
        commit: commit,
      );

      final expectedFlags =
          GitFilterFlag.noSystemAttributes.value |
          GitFilterFlag.attributesFromCommit.value;
      expect(opts.pointer.ref.flags, expectedFlags);
      expect(opts.pointer.ref.commit_id.address, commit.pointer.address);

      opts.free();
    });

    test('manually releases allocated memory', () {
      final opts = FilterOptions();
      expect(() => opts.free(), returnsNormally);
    });
  });
}
