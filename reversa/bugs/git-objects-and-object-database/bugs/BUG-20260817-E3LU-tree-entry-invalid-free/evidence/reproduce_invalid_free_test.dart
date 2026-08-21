import 'dart:io';

import 'package:git2dart/git2dart.dart';
import 'package:test/test.dart';

import '../../../../../test/helpers/util.dart';

void main() {
  test('freeing a borrowed tree entry corrupts native ownership', () {
    final fixture = setupRepo(Directory('test/assets/test_repo'));
    addTearDown(() {
      if (fixture.existsSync()) fixture.deleteSync(recursive: true);
    });

    final repository = Repository.open(fixture.path);
    final tree = Tree.lookup(repo: repository, oid: repository['a8ae3dd']);
    final borrowedEntry = tree[0];

    stderr.writeln('before-borrowed-free');
    borrowedEntry.free();
    stderr.writeln('after-borrowed-free');
    tree.free();
    stderr.writeln('after-parent-free');
    repository.free();
  });
}
