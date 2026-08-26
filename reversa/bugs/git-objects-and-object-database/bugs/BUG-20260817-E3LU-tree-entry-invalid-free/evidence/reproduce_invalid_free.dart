import 'dart:io';

import 'package:git2dart/git2dart.dart';

import '../../../../../../test/helpers/util.dart';

void main() {
  final temporaryRepository = setupRepo(Directory('test/assets/test_repo'));
  Repository? repository;
  Tree? tree;

  try {
    repository = Repository.open(temporaryRepository.path);
    tree = Tree.lookup(repo: repository, oid: repository['a8ae3dd']);
    final borrowedEntry = tree[0];

    stderr.writeln('borrowed-entry-before-free: ${borrowedEntry.name}');
    borrowedEntry.free();
    stderr.writeln('borrowed-entry-free-returned');

    tree.free();
    stderr.writeln('parent-tree-free-returned');
  } finally {
    repository?.free();
    if (temporaryRepository.existsSync()) {
      temporaryRepository.deleteSync(recursive: true);
    }
  }
}
