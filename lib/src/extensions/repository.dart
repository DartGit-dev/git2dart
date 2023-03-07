import 'package:git2dart/git2dart.dart';

extension RepositoryExtension on Repository {
  /// Retrieve the commit that HEAD is currently pointing to
  Commit get headCommit {
    return Commit.lookup(repo: this, oid: head.target);
  }

  /// Creates a new commit on HEAD from the list of passed in [files]
  Oid createCommitOnHead(
    List<String> files,
    Signature author,
    Signature committer,
    String message,
  ) {
    index.clear();

    for (final f in files) {
      index.add(f);
      index.write();
    }
    final treeOid = index.writeTree();

    final parent = headCommit;

    return Commit.create(
      repo: this,
      updateRef: 'HEAD',
      author: author,
      committer: committer,
      message: message,
      tree: Tree.lookup(repo: this, oid: treeOid),
      parents: [parent],
    );
  }
}
