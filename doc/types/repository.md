# Repository

#### Instantiation

You can instantiate a `Repository` class with a path to open an existing repository:

```dart
final repo = Repository.open('path/to/repository'); // => Repository
```

You can create new repository with provided path and optional `bare` argument if you want it to be bare:

```dart
final repo = Repository.init(path: 'path/to/folder', bare: true); // => Repository
```

You can clone the existing repository at provided url into local path:

```dart
final repo = Repository.clone(
  url: 'https://some.url/',
  localPath: 'path/to/clone/into',
); // => Repository
```

Also you can discover the path to the '.git' directory of repository if you provide a path to subdirectory:

```dart
Repository.discover(startPath: '/repository/lib/src'); // => '/repository/.git/'
```

Once the repository object is instantiated (`repo` in the following examples) you can perform various operations on it.

#### Accessing repository

```dart
// Boolean repository state values
repo.isBare; // => false
repo.isEmpty; // => true
repo.isHeadDetached; // => false
repo.isBranchUnborn; // => false
repo.isWorktree; // => false

// Path getters
repo.path; // => 'path/to/repository/.git/'
repo.workdir; // => 'path/to/repository/

// The HEAD of the repository
final ref = repo.head; // => Reference

// From returned ref you can get the 'name', 'target', target 'sha' and much more
ref.name; // => 'refs/heads/master'
ref.target; // => Oid
ref.target.sha; // => '821ed6e80627b8769d170a293862f9fc60825226'

// Looking up object with oid
final oid = repo['821ed6e80627b8769d170a293862f9fc60825226']; // => Oid
final commit = Commit.lookup(repo: repo, oid: oid); // => Commit
commit.message; // => 'initial commit'
```

#### Writing to repository

```dart
// Suppose you created a new file named 'new.txt' in your freshly initialized
// repository and you want to commit it.

final index = repo.index; // => Index
index.add('new.txt');
index.write();
final tree = Tree.lookup(repo: repo, oid: index.writeTree()); // => Tree

Commit.create(
  repo: repo,
  updateRef: 'refs/heads/master',
  message: 'initial commit\n',
  author: repo.defaultSignature,
  committer: repo.defaultSignature,
  tree: tree,
  parents: [], // empty list for initial commit, 1 parent for regular and 2+ for merge commits
); // => Oid
```

### Switching branches

```dart
// Move HEAD to an existing branch
repo.setHead('refs/heads/feature');
expect(repo.head.name, 'refs/heads/feature');

// Detach HEAD at a specific commit
repo.setHead(repo['821ed6e']);
expect(repo.isHeadDetached, true);
```


---


For more examples see [test/repository_test.dart](../../test/repository_test.dart).
