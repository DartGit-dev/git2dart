import 'dart:io';
import 'dart:ffi';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/object.dart' as bindings;
import 'package:git2dart/src/libgit2.dart' as libgit2;
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

  group('object bindings', () {
    test('lookup, peel, type, shortId and free', () {
      final commitObj = bindings.lookup(
        repoPointer: repo.pointer,
        oidPointer: repo[commitSha].pointer,
        type: git_object_t.GIT_OBJECT_ANY,
      );

      expect(
        Oid.fromRaw(libgit2.libgit2.git_object_id(commitObj).ref).sha,
        commitSha,
      );
      expect(bindings.type(commitObj), git_object_t.GIT_OBJECT_COMMIT);
      expect(bindings.shortId(objectPointer: commitObj), '78b8bf1');

      final tagObj = bindings.lookup(
        repoPointer: repo.pointer,
        oidPointer: repo[tagSha].pointer,
        type: git_object_t.GIT_OBJECT_TAG,
      );
      final peeled = bindings.peel(
        objectPointer: tagObj,
        targetType: git_object_t.GIT_OBJECT_COMMIT,
      );
      expect(
        Oid.fromRaw(libgit2.libgit2.git_object_id(peeled).ref).sha,
        peeledCommitSha,
      );

      bindings.free(commitObj);
      bindings.free(tagObj);
      bindings.free(peeled);
    });

    test('string2type and type2string', () {
      final t = bindings.string2type('commit');
      expect(t, git_object_t.GIT_OBJECT_COMMIT);
      expect(bindings.type2string(t), 'commit');
    });
  });
}
