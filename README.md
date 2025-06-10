# git2dart
![Pub Version](https://img.shields.io/pub/v/git2dart)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/git2dart)
![Pub Likes](https://img.shields.io/pub/likes/git2dart)

## Dart bindings to libgit2

git2dart package provides ability to use [libgit2](https://github.com/libgit2/libgit2) in Dart/Flutter.

This is a hardfork of [libgit2dart](https://github.com/SkinnyMind/libgit2dart)

Currently supported platforms are 64-bit Windows, Linux, MacOS on both Flutter and Dart VM.

- [Getting Started](#getting-started)
- [System Dependencies](#system-dependencies)
- [Usage](#usage)
  - [Repository](#repository)
  - [Commit](#commit)
  - [Tree and TreeEntry](#tree-and-treeentry)
  - [Tag](#tag)
  - [Blob](#blob)
  - [Commit Walker](#commit-walker)
  - [Index and IndexEntry](#index-and-indexentry)
  - [References and RefLog](#references-and-reflog)
  - [Branches](#branches)
  - [Diff](#diff)
  - [Patch](#patch)
  - [Config Files](#config-files)
  - [Checkout](#checkout)
  - [Merge](#merge)
  - [Stashes](#stashes)
  - [Worktrees](#worktrees)
  - [Submodules](#submodules)
  - [Remote](#remote)
  - [Reset](#reset)
  - [Blame](#blame)
  - [Describe](#describe)
  - [Note](#note)
  - [Rebase](#rebase)
  - [Mailmap](#mailmap)
  - [Credentials](#credentials)
  - [ODB](#odb-object-database)
  - [Packbuilder](#packbuilder)
  - [Signature](#signature)
  - [RevParse](#revparse)
  - [AnnotatedCommit](#annotatedcommit)
- [Contributing](#contributing)
- [Development](#development)

## Getting Started

1. Add package as a dependency in your `pubspec.yaml`
2. Import:

```dart
import 'package:git2dart/git2dart.dart';
```

3. Verify installation (should return string with version of libgit2 shipped with package):

```dart
...
print(Libgit2.version);
...
```

**Note**: The following steps only required if you are using package in Dart application (Flutter application will have libgit2 library bundled automatically when you build for release).

## System Dependencies

To use git2dart, you need to have the following system dependencies installed:

### Linux

```shell
sudo apt-get install libssl-dev libpcre3
```

### macOS

```shell
brew install openssl
```

### Windows

```powershell
choco install openssl -y
```

## Usage

git2dart provides you ability to manage Git repository. You can read and write objects (commit, tag, tree and blob), walk a tree, access the staging area, manage config and lots more.

Let's look at some of the classes and methods (you can also check [example](example/example.dart)).

### Repository

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

---

### Git Objects

There are four kinds of base object types in Git: **commits**, **trees**, **tags**, and **blobs**. git2dart have a corresponding class for each of these object types.

Lookups of these objects requires Oid object, which can be instantiated from provided SHA-1 string in two ways:

```dart
// Using alias on repository object with SHA-1 string that can be any length
// between 4 and 40 characters
final oid = repo['821ed6e'];

// Using named constructor from Oid class (rules for SHA-1 string length is
// the same)
final oid = Oid.fromSHA(repo, '821ed6e');
```

### Commit

Commit lookup and some of the getters of the object:

```dart
final commit = Commit.lookup(repo: repo, oid: repo['821ed6e']); // => Commit

commit.message; // => 'initial commit\n'
commit.time; // => 1635869993 (seconds since epoch)
commit.author; // => Signature
commit.tree; // => Tree
```

### Tree and TreeEntry

Tree and TreeEntry lookup and some of their getters and methods:

```dart
final tree = Tree.lookup(repo: repo, oid: repo['a8ae3dd']); // => Tree

tree.entries; // => [TreeEntry, TreeEntry, ...]
tree.length; // => 3
tree.oid; // => Oid

// You can lookup single tree entry in the tree with index
final entry = tree[0]; // => TreeEntry

// You can lookup single tree entry in the tree with path to file
final entry = tree['some/file.txt']; // => TreeEntry

// Or you can lookup single tree entry in the tree with filename
final entry = tree['file.txt']; // => TreeEntry

entry.oid; // => Oid
entry.name // => 'file.txt'
entry.filemode // => GitFilemode.blob
```

You can also write trees with TreeBuilder:

```dart
final builder = TreeBuilder(repo: repo); // => TreeBuilder
builder.add(
  filename: 'file.txt',
  oid: index['file.txt'].oid,
  filemode: GitFilemode.blob,
);
final treeOid = builder.write(); // => Oid

// Perform commit using that tree in arguments
...
```

### Tag

Tag create and lookup methods and some of the object getters:

```dart
// Create annotated tag
final annotated = Tag.createAnnotated(
  repo: repo,
  tagName: 'v0.1',
  target: repo['821ed6e'],
  targetType: GitObject.commit,
  tagger: repo.defaultSignature,
  message: 'tag message',
); // => Oid

// Create lightweight tag
final lightweight = Tag.createLightweight(
  repo: repo,
  tagName: 'v0.1',
  target: repo['821ed6e'],
  targetType: GitObject.commit,
); // => Oid

// Lookup tag
final tag = Tag.lookup(repo: repo, oid: repo['f0fdbf5']); // => Tag

// Get list of all the tags names in repository
repo.tags; // => ['v0.1', 'v0.2']

tag.oid; // => Oid
tag.name; // => 'v0.1'
```

### Blob

Blob create and lookup methods and some of the object getters:

```dart
// Create a new blob from the file at provided path
final oid = Blob.createFromDisk(repo: repo, path: 'path/to/file.txt'); // => Oid

// Lookup blob
final blob = Blob.lookup(repo: repo, oid: repo['e69de29']); // => Blob

blob.oid; // => Oid
blob.content; // => 'content of the file'
blob.size; // => 19
```

---

### Commit Walker

There's two ways to traverse a set of commits. Through Repository object alias or by using RevWalk class for finer control:

```dart
// Traverse a set of commits starting at provided oid
final commits = repo.log(oid: repo['821ed6e']); // => [Commit, Commit, ...]

// Use RevWalk object to fine tune traversal
final walker = RevWalk(repo); // => RevWalk

// Set desired sorting (optional)
walker.sorting({GitSort.topological, GitSort.time});

// Push Oid for the starting point
walker.push(repo['821ed6e']);

// Hide commits if you are not interested in anything beneath them
walker.hide(repo['c68ff54']);

// Perform traversal
final commits = walker.walk(); // => [Commit, Commit, ...]
```

---

### Index and IndexEntry

Some methods and getters to inspect and manipulate the Git index ("staging area"):

```dart
// Initialize Index object
final index = repo.index; // => Index

// Get number of entries in index
index.length; // => 69

// Re-read the index from disk
index.read();

// Write an existing index object to disk
index.write();

// Iterate over index entries
for (final entry in index) {
  print(entry.path); // => 'path/to/file.txt'
}

// Get a specific entry
final entry = index['file.txt']; // => IndexEntry

// Stage using path to file or IndexEntry (updates existing entry if there is one)
index.add('new.txt');

// Unstage entry from index
index.remove('new.txt');
```

---

### References and RefLog

```dart
// Get names of all of the references that can be found in repository
final refs = repo.references; // => ['refs/heads/master', 'refs/tags/v0.1', ...]

// Lookup reference
final ref = Reference.lookup(repo: repo, name: 'refs/heads/master'); // => Reference

ref.type; // => ReferenceType.direct
ref.target; // => Oid
ref.name; // => 'refs/heads/master'

// Create reference
final ref = Reference.create(
  repo: repo,
  name: 'refs/heads/feature',
  target: repo['821ed6e'],
); // => Reference

// Update reference
ref.setTarget(repo['c68ff54']);

// Rename reference
Reference.rename(repo: repo, oldName: 'refs/heads/feature', newName: 'refs/heads/feature2');

// Delete reference
Reference.delete(repo: repo, name: 'refs/heads/feature2');

// Access the reflog
final reflog = ref.log; // => RefLog
final entry = reflog.first; // RefLogEntry

entry.message; // => 'commit (initial): init'
entry.committer; // => Signature
```

---

### Branches

```dart
// Get all the branches that can be found in repository
final branches = repo.branches; // => [Branch, Branch, ...]

// Get only local/remote branches
final local = repo.branchesLocal; // => [Branch, Branch, ...]
final remote = repo.branchesRemote; // => [Branch, Branch, ...]

// Lookup branch (lookups in local branches if no value for argument `type`
// is provided)
final branch = Branch.lookup(repo: repo, name: 'master'); // => Branch

branch.target; // => Oid
branch.isHead; // => true
branch.name; // => 'master'

// Create branch
Branch.create(repo: repo, name: 'feature', target: commit); // => Branch

// Rename branch
Branch.rename(repo: repo, oldName: 'feature', newName: 'feature2');

// Delete branch
Branch.delete(repo: repo, name: 'feature2');
```

---

### Diff

There is multiple ways to get the diff:

```dart
// Diff between index (staging area) and current working directory
final diff = Diff.indexToWorkdir(repo: repo, index: repo.index); // => Diff

// Diff between tree and index (staging area)
final diff = Diff.treeToIndex(repo: repo, tree: tree, index: repo.index); // => Diff

// Diff between tree and current working directory
final diff = Diff.treeToWorkdir(repo: repo, tree: tree); // => Diff

// Diff between tree and current working directory with index
final diff = Diff.treeToWorkdirWithIndex(repo: repo, tree: tree); // => Diff

// Diff between two tree objects
final diff = Diff.treeToTree(repo: repo, oldTree: tree1, newTree: tree2); // => Diff

// Diff between two index objects
final diff = Diff.indexToIndex(repo: repo, oldIndex: repo.index, newIndex: index); // => Diff

// Read the contents of a git patch file
final diff = Diff.parse(patch.text); // => Diff
```

Some methods for inspecting Diff object:

```dart
// Get the number of diff records
diff.length; // => 3

// Get the patch
diff.patch; // => 'diff --git a/modified_file b/modified_file ...'

// Get the DiffStats object of the diff
final stats = diff.stats; // => DiffStats
stats.insertions; // => 69
stats.deletions; // => 420
stats.filesChanged; // => 1

// Get the list of DiffDelta's containing file pairs with and old and new revisions
final deltas = diff.deltas; // => [DiffDelta, DiffDelta, ...]
final delta = deltas.first; // => DiffDelta
delta.status; // => GitDelta.modified
delta.oldFile; // => DiffFile
delta.newFile; // => DiffFile
```

---

### Patch

Some API methods to generate patch:

```dart
// Patch from difference between two blobs
final patch = Patch.fromBlobs(
  oldBlob: null, // empty blob
  newBlob: blob,
  newBlobPath: 'file.txt',
); // => Patch

// Patch from entry in the diff list at provided index position
final patch = Patch.fromDiff(diff: diff, index: 0); // => Patch
```

Some methods for inspecting Patch object:

```dart
// Get the content of a patch as a single diff text
patch.text; // => 'diff --git a/modified_file b/modified_file ...'

// Get the size of a patch diff data in bytes
patch.size(); // => 1337

// Get the list of hunks in a patch
patch.hunks; // => [DiffHunk, DiffHunk, ...]
```

---

### Config files

Some methods and getters of Config object:

```dart
// Open config file at provided path
final config = Config.open('path/to/config'); // => Config

// Open configuration file for repository
final config = repo.config; // => Config

// Get value of config variable
config['user.name'].value; // => 'Some Name'

// Set value of config variable
config['user.name'] = 'Another Name';

// Delete variable from the config
config.delete('user.name');
```

---

### Checkout

Perform different types of checkout:

```dart
// Update files in the index and the working directory to match the
// content of the commit pointed at by HEAD
Checkout.head(repo: repo);

// Update files in the working directory to match the content of the index
Checkout.index(repo: repo);

// Update files in the working directory to match the content of the tree
// pointed at by the reference target
Checkout.reference(repo: repo, name: 'refs/heads/master');

// Update files in the working directory to match the content of the tree
// pointed at by the commit
Checkout.commit(repo: repo, commit: commit);

// Perform checkout using various strategies
Checkout.head(repo: repo, strategy: {GitCheckout.force});

// Checkout only required files
Checkout.head(repo: repo, paths: ['some/file.txt']);
```

---

### Merge

Some API methods:

```dart
// Find a merge base between commits
final oid = Merge.base(
  repo: repo,
  commits: [commit1.oid, commit2.oid],
); // => Oid

// Merge commit into HEAD writing the results into the working directory
Merge.commit(repo: repo, commit: annotatedCommit);

// Cherry-pick the provided commit, producing changes in the index and
// working directory.
Merge.cherryPick(repo: repo, commit: commit);
```

---

### Stashes

```dart
// Get the list of all stashed states (first being the most recent)
repo.stashes; // => [Stash, Stash, ...]

// Save local modifications to a new stash
Stash.create(repo: repo, stasher: signature, message: 'WIP'); // => Oid

// Apply stash (defaults to last saved if index is not provided)
Stash.apply(repo: repo);

// Apply only specific paths from stash
Stash.apply(repo: repo, paths: ['file.txt']);

// Drop stash (defaults to last saved if index is not provided)
Stash.drop(repo: repo);

// Pop stash (apply and drop if successful, defaults to last saved
// if index is not provided)
Stash.pop(repo: repo);
```

---

### Worktrees

```dart
// Get list of names of linked worktrees
repo.worktrees; // => ['worktree1', 'worktree2'];

// Lookup existing worktree
Worktree.lookup(repo: repo, name: 'worktree1'); // => Worktree

// Create new worktree
final worktree = Worktree.create(
  repo: repo,
  name: 'worktree3',
  path: '/worktree3/path/',
); // => Worktree

// Get name of worktree
worktree.name; // => 'worktree3'

// Get path for the worktree
worktree.path; // => '/worktree3/path/';

// Lock and unlock worktree
worktree.lock();
worktree.unlock();

// Prune the worktree (remove the git data structures on disk)
worktree.prune();
```

---

### Submodules

Some API methods for submodule management:

```dart
// Get list with all tracked submodules paths
repo.submodules; // => ['Submodule1', 'Submodule2'];

// Lookup submodule
Submodule.lookup(repo: repo, name: 'Submodule'); // => Submodule

// Init and update
Submodule.init(repo: repo, name: 'Submodule');
Submodule.update(repo: repo, name: 'Submodule');

// Add submodule
Submodule.add(repo: repo, url: 'https://some.url', path: 'submodule'); // => Submodule
```

Some methods for inspecting Submodule object:

```dart
// Get name of the submodule
submodule.name; // => 'Submodule'

// Get path to the submodule
submodule.path; // => 'Submodule'

// Get URL for the submodule
submodule.url; // => 'https://some.url'

// Set URL for the submodule in the configuration
submodule.url = 'https://updated.url';
submodule.sync();
```

---

### Remote

Some API methods for remote management:

```dart
// Get list of all remotes
Remote.list(repo); // => ['origin', 'upstream', ...]

// Lookup remote
final remote = Remote.lookup(repo: repo, name: 'origin'); // => Remote
remote.name; // => 'origin'
remote.url; // => 'https://github.com/user/repo.git'

// Create remote
final remote = Remote.create(
  repo: repo,
  name: 'upstream',
  url: 'https://github.com/upstream/repo.git',
); // => Remote

// Delete remote
Remote.delete(repo: repo, name: 'upstream');

// Rename remote
Remote.rename(repo: repo, oldName: 'origin', newName: 'github');

// Fetch from remote
final remote = Remote.lookup(repo: repo, name: 'origin');
final stats = remote.fetch(
  callbacks: Callbacks(transferProgress: (stats) {
    print('Progress: ${stats.receivedObjects}/${stats.totalObjects}');
  }),
); // => TransferProgress

// Get remote references
final refs = remote.ls(); // => [RemoteReference, RemoteReference, ...]
```

---

### Reset

Some API methods for reset operations:

```dart
// Reset repository to specific commit with different reset types
// Hard reset - updates index and working directory
repo.reset(oid: repo['821ed6e'], resetType: GitReset.hard);

// Soft reset - only moves HEAD
repo.reset(oid: repo['821ed6e'], resetType: GitReset.soft);

// Mixed reset - updates index but not working directory
repo.reset(oid: repo['821ed6e'], resetType: GitReset.mixed);

// Reset specific paths in index to match commit
repo.resetDefault(oid: repo.head.target, pathspec: ['file.txt']);
```

---

### Blame

Show what revision and author last modified each line of a file:

```dart
// Get blame for file
final blame = Blame.file(
  repo: repo,
  path: 'path/to/file.txt',
); // => Blame

// Get blame hunk for specific line
final hunk = blame.forLine(5); // => BlameHunk
hunk.finalCommitOid; // => Oid
hunk.finalCommitter; // => Signature
hunk.originalPath; // => 'path/to/file.txt'

// Get blame with options
final blame = Blame.file(
  repo: repo,
  path: 'file.txt',
  newestCommit: repo['fc38877'],
  oldestCommit: repo['f17d0d4'],
  minLine: 1,
  maxLine: 10,
);

// Get blame for buffer
final blame = Blame.buffer(
  reference: existingBlame,
  buffer: 'new content',
);
```

---

### Describe

Generate human-readable name for any commit:

```dart
// Describe current working tree state
repo.describe(); // => 'v0.2-10-g821ed6e'

// Describe specific commit
repo.describe(
  commit: Commit.lookup(repo: repo, oid: repo['821ed6e']),
); // => 'v0.1-1-g821ed6e'

// Describe with options
repo.describe(
  describeStrategy: GitDescribeStrategy.tags, // only consider tags
  abbreviatedSize: 7, // length of abbreviated commit id
  alwaysUseLongFormat: true,
  dirtySuffix: '-dirty',
); // => 'v0.1-1-g821ed6e-dirty'
```

---

### Note

Add, remove and read notes attached to objects:

```dart
// Get list of all notes
final notes = Note.list(repo); // => [Note, Note, ...]

// Lookup note for object
final note = Note.lookup(
  repo: repo,
  annotatedOid: repo.head.target,
); // => Note
note.message; // => 'Note content\n'
note.oid; // => Oid

// Create note
final noteOid = Note.create(
  repo: repo,
  author: signature,
  committer: signature,
  annotatedOid: repo.head.target,
  note: 'New note content',
  force: true, // overwrite existing note
); // => Oid

// Delete note
Note.delete(
  repo: repo,
  annotatedOid: repo.head.target,
  author: signature,
  committer: signature,
);
```

---

### Rebase

Reapply commits on top of another base commit:

```dart
// Initialize rebase
final rebase = Rebase.init(
  repo: repo,
  branch: AnnotatedCommit.fromReference(repo: repo, reference: branchRef),
  onto: AnnotatedCommit.fromReference(repo: repo, reference: ontoRef),
);

// Get operations to be performed
final operations = rebase.operations; // => [RebaseOperation, ...]

// Perform rebase operations
for (final operation in operations) {
  // Apply next operation
  rebase.next();
  
  // Commit the changes
  rebase.commit(
    committer: signature,
    message: 'Rebased commit',
  );
}

// Finish rebase
rebase.finish();

// Or abort rebase
rebase.abort();

// Open existing rebase
final rebase = Rebase.open(repo);
```

---

### Mailmap

Map author/committer names and emails:

```dart
// Create empty mailmap
final mailmap = Mailmap.empty();

// Create from buffer
final mailmap = Mailmap.fromBuffer('''
Joe Developer <joe@example.com> <joe@old.com>
Jane Doe <jane@example.com> <jane.doe@old.com>
''');

// Create from repository
final mailmap = Mailmap.fromRepository(repo);

// Add entry
mailmap.addEntry(
  realName: 'Joe Developer',
  realEmail: 'joe@example.com',
  replaceName: 'joe',
  replaceEmail: 'joe@old.com',
);

// Resolve name and email
final resolved = mailmap.resolve(
  name: 'joe',
  email: 'joe@old.com',
); // => ['Joe Developer', 'joe@example.com']

// Resolve signature
final resolvedSig = mailmap.resolveSignature(signature);
```

---

### Credentials

Handle authentication for remote operations:

```dart
// Username/password credentials
const credentials = UserPass(
  username: 'user',
  password: 'password',
);

// SSH key from files
const credentials = Keypair(
  username: 'git',
  pubKey: 'path/to/id_rsa.pub',
  privateKey: 'path/to/id_rsa',
  passPhrase: 'key passphrase',
);

// SSH key from memory
final credentials = KeypairFromMemory(
  username: 'git',
  pubKey: publicKeyContent,
  privateKey: privateKeyContent,
  passPhrase: 'key passphrase',
);

// SSH key from agent
const credentials = KeypairFromAgent('git');

// Use credentials with clone/fetch/push
final repo = Repository.clone(
  url: 'ssh://git@github.com/user/repo.git',
  localPath: 'path/to/clone',
  callbacks: Callbacks(credentials: credentials),
);
```

---

### ODB (Object Database)

Direct access to Git object database:

```dart
// Get ODB from repository
final odb = repo.odb; // => Odb

// Check if object exists
odb.contains(oid); // => true/false

// Read object
final obj = odb.read(oid); // => OdbObject
obj.type; // => GitObject.blob
obj.data; // => 'content'
obj.size; // => 7

// Write object
final oid = odb.write(
  type: GitObject.blob,
  data: 'new content',
); // => Oid

// Get all objects
final objects = odb.objects; // => [Oid, Oid, ...]

// Add alternate ODB
odb.addDiskAlternate('path/to/alternate/objects');
```

---

### Packbuilder

Build pack files:

```dart
// Create packbuilder
final packbuilder = PackBuilder(repo);

// Add objects
packbuilder.add(oid);
packbuilder.addRecursively(commitOid);
packbuilder.addCommit(commitOid);
packbuilder.addTree(treeOid);

// Add objects from revwalk
final walker = RevWalk(repo);
walker.push(repo.head.target);
packbuilder.addWalk(walker);

// Write pack file
packbuilder.write('path/to/pack');

// Pack all objects in repository
final written = repo.pack(); // => number of objects written

// Pack with options
repo.pack(
  path: 'path/to/packdir',
  threads: 4,
  packDelegate: (builder) {
    // custom logic to add objects
    builder.addCommit(someOid);
  },
);
```

---

### Signature

Create and manage signatures for commits and tags:

```dart
// Create signature with current time
final sig = Signature.create(
  name: 'Author Name',
  email: 'author@example.com',
);

// Create signature with specific time
final sig = Signature.create(
  name: 'Author Name',
  email: 'author@example.com',
  time: 1234567890, // seconds since epoch
  offset: 120, // timezone offset in minutes
);

// Access signature properties
sig.name; // => 'Author Name'
sig.email; // => 'author@example.com'
sig.time; // => 1234567890
sig.offset; // => 120
sig.sign; // => '+0200'
```

---

### RevParse

Parse revision specifications:

```dart
// Parse single revision spec
final commit = RevParse.single(repo: repo, spec: 'HEAD') as Commit;
final tree = RevParse.single(repo: repo, spec: 'HEAD^{tree}') as Tree;
final blob = RevParse.single(repo: repo, spec: 'HEAD:README.md') as Blob;

// Parse extended revision spec (returns object and reference)
final result = RevParse.ext(repo: repo, spec: 'master');
result.object; // => Commit
result.reference; // => Reference

// Parse revision range
final range = RevParse.range(repo: repo, spec: 'HEAD~10..HEAD');
range.from; // => Commit
range.to; // => Commit
range.flags; // => {GitRevSpec.range}

// Parse merge base
final range = RevParse.range(repo: repo, spec: 'HEAD...feature');
range.flags; // => {GitRevSpec.range, GitRevSpec.mergeBase}
```

---

### AnnotatedCommit

Annotated commits carry additional information for merge/rebase operations:

```dart
// Create from oid
final annotated = AnnotatedCommit.lookup(repo: repo, oid: commitOid);

// Create from reference
final annotated = AnnotatedCommit.fromReference(
  repo: repo,
  reference: branchRef,
);

// Create from revision spec
final annotated = AnnotatedCommit.fromRevSpec(
  repo: repo,
  spec: '@{-1}', // previous branch
);

// Create from fetch head
final annotated = AnnotatedCommit.fromFetchHead(
  repo: repo,
  branchName: 'master',
  remoteUrl: 'https://github.com/user/repo.git',
  oid: commitOid,
);

// Access properties
annotated.oid; // => Oid
annotated.refName; // => 'refs/heads/master'
```

---

## Contributing

Fork git2dart, improve git2dart, send a pull request.

---

## Development

### Troubleshooting

#### Linux

If you are developing on Linux using non-Debian based distrib you might encounter these errors:

- Failed to load dynamic library: libpcre.so.3: cannot open shared object file: No such file or directory
- Failed to load dynamic library: libpcreposix.so.3: cannot open shared object file: No such file or directory

That happens because dynamic library is precompiled on Ubuntu and Arch/Fedora/RedHat names for those libraries are `libpcre.so` and `libpcreposix.so`.

To fix these errors create symlinks:

```shell
sudo ln -s /usr/lib64/libpcre.so /usr/lib64/libpcre.so.3
sudo ln -s /usr/lib64/libpcreposix.so /usr/lib64/libpcreposix.so.3
```

### Running Tests

To run all tests and generate coverage report make sure to have activated packages and [lcov](https://github.com/linux-test-project/lcov) installed:

```sh
dart pub global activate coverage
```

And run:

```sh
dart pub global run coverage:test_with_coverage
open coverage/index.html
```

---

## Licence

MIT. See [LICENSE](LICENSE) file for more information.


[![Star History Chart](https://api.star-history.com/svg?repos=DartGit-dev/git2dart&type=Date)](https://www.star-history.com/#DartGit-dev/git2dart&Date)
