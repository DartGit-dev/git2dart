import 'dart:ffi';
import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:git2dart/src/bindings/object.dart' as object_bindings;
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

  group('Object bindings', () {
    test('lookup, type and shortId', () {
      final oid = repo[commitSha];
      final object = object_bindings.lookup(
        repoPointer: repo.pointer,
        oidPointer: oid.pointer,
        type: git_object_t.fromValue(GitObject.any.value),
      );

      expect(Oid.fromRaw(libgit2.git_object_id(object).ref).sha, commitSha);
      expect(object_bindings.type(object), git_object_t.GIT_OBJECT_COMMIT);
      expect(object_bindings.shortId(objectPointer: object), '78b8bf1');

      object_bindings.free(object);
    });

    test('peel object to commit', () {
      final tagOid = repo[tagSha];
      final tagObject = object_bindings.lookup(
        repoPointer: repo.pointer,
        oidPointer: tagOid.pointer,
        type: git_object_t.GIT_OBJECT_TAG,
      );

      final peeled = object_bindings.peel(
        objectPointer: tagObject,
        targetType: git_object_t.GIT_OBJECT_COMMIT,
      );

      expect(
        Oid.fromRaw(libgit2.git_object_id(peeled).ref).sha,
        peeledCommitSha,
      );

      object_bindings.free(peeled);
      object_bindings.free(tagObject);
    });

    test('string2type and type2string', () {
      final type = object_bindings.string2type('commit');
      expect(type, git_object_t.GIT_OBJECT_COMMIT);
      expect(object_bindings.type2string(type), 'commit');
    });
  });
}
