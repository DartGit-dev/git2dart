# Data Dictionary

> Consolidated data structures extracted by Archaeologist. `Required` describes the Dart API contract, not whether the corresponding C field can be null internally.

## Repository Lifecycle

### Repository

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `pointer` | `Pointer<git_repository>` | Yes | Owned native repository handle exposed for internal package use | 🟢 |
| `path` | `String` | Yes | Repository metadata directory path | 🟢 |
| `commonDir` | `String` | Yes | Common metadata directory shared by linked worktrees | 🟢 |
| `namespace` | `String` | Yes | Current reference namespace; empty when unset | 🟢 |
| `isBare` | `bool` | Yes | Whether no working directory is attached | 🟢 |
| `isEmpty` | `bool` | Yes | Whether the repository has no commits | 🟢 |
| `isHeadDetached` | `bool` | Yes | Whether HEAD points directly to an object | 🟢 |
| `isBranchUnborn` | `bool` | Yes | Whether HEAD points to a branch without a commit | 🟢 |
| `state` | `GitRepositoryState` | Yes | Active operation state such as merge or rebase | 🟢 |
| `workdir` | `String` | Yes | Working-directory path; empty for bare repositories | 🟢 |

### RepositoryCallback

| Field | Type | Required | Default | Meaning | Confidence |
| --- | --- | --- | --- | --- | --- |
| `bare` | `bool?` | No | `null` | Optional override for clone-created repository type | 🟢 |
| `flags` | `Set<GitRepositoryInit>?` | No | `null` | Initialization flags | 🟢 |
| `mode` | `int?` | No | `null` | Filesystem mode used during initialization | 🟢 |
| `workdirPath` | `String?` | No | `null` | Alternate working directory | 🟢 |
| `description` | `String?` | No | `null` | Repository description | 🟢 |
| `templatePath` | `String?` | No | `null` | Template directory | 🟢 |
| `initialHead` | `String?` | No | `null` | Initial branch/ref name | 🟢 |
| `originUrl` | `String?` | No | `null` | Origin remote URL | 🟢 |

### Identity

| Field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `name` | `String` | Yes | Repository-scoped identity name | 🟢 |
| `email` | `String` | Yes | Repository-scoped identity email | 🟢 |

### Worktree

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `name` | `String` | Yes | Linked worktree name | 🟢 |
| `path` | `String` | Yes | Worktree filesystem path | 🟢 |
| `isLocked` | `bool` | Yes | Whether administrative mutation is locked | 🟢 |
| `isPrunable` | `bool` | Yes | Whether current metadata satisfies prune rules | 🟢 |

## Git Objects and Object Database

### Oid

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `pointer` | `Pointer<git_oid>` | Yes | Native object identifier storage | 🟢 |
| `sha` | `String` | Yes | Full hexadecimal object identifier | 🟢 |

### Commit

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Commit object identifier | 🟢 |
| `message` | `String` | Yes | Decoded commit message | 🟢 |
| `messageRaw` | `String` | Yes | Unprocessed commit message | 🟢 |
| `summary` | `String` | Yes | First-line summary | 🟢 |
| `body` | `String` | Yes | Message body | 🟢 |
| `author` | `Signature` | Yes | Original author identity and time | 🟢 |
| `committer` | `Signature` | Yes | Committer identity and time | 🟢 |
| `tree` | `Tree` | Yes | Root tree snapshot | 🟢 |
| `parents` | `List<Commit>` | Yes | Ordered parent commits; empty for root | 🟢 |

### Signature

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `name` | `String` | Yes | Author or committer display name | 🟢 |
| `email` | `String` | Yes | Author or committer email | 🟢 |
| `time` | `int` | Yes | Unix timestamp | 🟢 |
| `offset` | `int` | Yes | Timezone offset in minutes | 🟢 |
| `sign` | `String` | Yes | Timezone sign character | 🟢 |

### TreeUpdate

| Field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `path` | `String` | Yes | Relative tree path | 🟢 |
| `oid` | `Oid?` | For upsert | Null means removal; non-null identifies the new target | 🟢 |
| `filemode` | `GitFilemode?` | For upsert | Mode of the inserted or replaced entry | 🟢 |

### TreeEntry

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Target object identifier | 🟢 |
| `name` | `String` | Yes | Entry name | 🟢 |
| `filemode` | `GitFilemode` | Yes | Git file mode | 🟢 |
| `type` | `GitObject` | Yes | Target object kind | 🟢 |

### Blob

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Blob object identifier | 🟢 |
| `content` | `String` | Yes | Text-decoded content | 🟢 |
| `contentBytes` | `Uint8List` | Yes | Binary-safe content | 🟢 |
| `size` | `int` | Yes | Content size in bytes | 🟢 |
| `isBinary` | `bool` | Yes | libgit2 binary-content heuristic | 🟢 |

### Tag

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Annotated tag object identifier | 🟢 |
| `name` | `String` | Yes | Tag name | 🟢 |
| `message` | `String` | Yes | Annotation message | 🟢 |
| `tagger` | `Signature` | Yes | Annotation identity and time | 🟢 |
| `targetOid` | `Oid` | Yes | Tagged object identifier | 🟢 |

### OdbObject

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Stored object's identifier | 🟢 |
| `type` | `GitObject` | Yes | Stored object's concrete kind | 🟢 |
| `dataBytes` | `Uint8List` | Yes | Binary-safe raw object body | 🟢 |
| `size` | `int` | Yes | Raw body size | 🟢 |

## Working Tree and Index

### IndexEntry

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Blob identifier stored in the entry | 🟢 |
| `path` | `String` | Yes | Repository-relative path | 🟢 |
| `mode` | `GitFilemode` | Yes | Git file mode | 🟢 |
| `stage` | `int` | Yes | Merge stage (normal, ancestor, ours, theirs) | 🟢 |
| `isConflict` | `bool` | Yes | Whether the entry belongs to a conflict stage | 🟢 |

### ConflictEntry

| Field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `ancestor` | `IndexEntry?` | No | Common ancestor side | 🟢 |
| `our` | `IndexEntry?` | No | Current side | 🟢 |
| `their` | `IndexEntry?` | No | Incoming side | 🟢 |

### IndexReucEntry

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `path` | `String` | Yes | Resolved path | 🟢 |
| `ancestorMode` / `ourMode` / `theirMode` | `GitFilemode` | Yes | Previous conflict-side modes | 🟢 |
| `ancestorOid` / `ourOid` / `theirOid` | `Oid` | Yes | Previous conflict-side object identifiers | 🟢 |

### DiffDelta and DiffFile

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `status` | `GitDelta` | Yes | Added, deleted, modified, renamed, copied, or other delta kind | 🟢 |
| `flags` | `Set<GitDiffFlag>` | Yes | Binary/valid-ID/existence metadata | 🟢 |
| `similarity` | `int` | Yes | Similarity score used for rename/copy classification | 🟢 |
| `oldFile` / `newFile` | `DiffFile` | Yes | Before and after file descriptors | 🟢 |
| `DiffFile.path` | `String` | Yes | File path | 🟢 |
| `DiffFile.oid` | `Oid` | Yes | File content identifier | 🟢 |
| `DiffFile.size` | `int` | Yes | File size | 🟢 |
| `DiffFile.mode` | `GitFilemode` | Yes | File mode | 🟢 |

### Patch, DiffHunk, and DiffLine

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `Patch.delta` | `DiffDelta` | Yes | File-level change represented by the patch | 🟢 |
| `DiffHunk.oldStart` / `newStart` | `int` | Yes | Starting line positions | 🟢 |
| `DiffHunk.oldLines` / `newLines` | `int` | Yes | Line spans | 🟢 |
| `DiffHunk.header` | `String` | Yes | Unified-diff hunk header | 🟢 |
| `DiffLine.origin` | `GitDiffLine` | Yes | Context/add/delete/etc. line kind | 🟢 |
| `DiffLine.content` | `String` | Yes | Line content | 🟢 |

### Stash

| Field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `index` | `int` | Yes | Position in stash list | 🟢 |
| `message` | `String` | Yes | Stash message | 🟢 |
| `oid` | `Oid` | Yes | Stash commit identifier | 🟢 |

### PathspecMatchList

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `entries` | `List<String>` | Yes | Matching paths | 🟢 |
| `failedEntries` | `List<String>` | Yes | Patterns that matched no path when requested | 🟢 |

## References and Remotes

### Reference

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `type` | `ReferenceType` | Yes | Direct or symbolic representation | 🟢 |
| `target` | `Oid` | Yes | Resolved object identifier | 🟢 |
| `peeledTarget` | `Oid?` | No | Cached peeled target for an annotated tag reference | 🟢 |
| `name` | `String` | Yes | Full reference name | 🟢 |
| `shorthand` | `String` | Yes | Human-readable short name | 🟢 |
| `hasLog` | `bool` | Yes | Whether a reflog exists | 🟢 |

### Branch

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `target` | `Oid` | Yes | Commit-like target | 🟢 |
| `name` | `String` | Yes | Local or remote branch name | 🟢 |
| `isHead` | `bool` | Yes | Whether current HEAD points here | 🟢 |
| `isCheckedOut` | `bool` | Yes | Whether any linked worktree HEAD points here | 🟢 |
| `upstream` | `Reference` | When configured | Tracking reference | 🟢 |

### RefLogEntry

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `message` | `String` | Yes | Reflog action message | 🟢 |
| `committer` | `Signature` | Yes | Actor and timestamp | 🟢 |
| `oldOid` | `Oid` | Yes | Previous target | 🟢 |
| `newOid` | `Oid` | Yes | New target | 🟢 |

### Refspec

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `source` | `String` | Yes | Source reference pattern | 🟢 |
| `destination` | `String` | Yes | Destination reference pattern | 🟢 |
| `force` | `bool` | Yes | Whether non-fast-forward replacement is requested | 🟢 |
| `direction` | `GitDirection` | Yes | Fetch or push transformation direction | 🟢 |

### Remote, RemoteReference, and TransferProgress

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `Remote.name` | `String` | Yes | Configured remote name | 🟢 |
| `Remote.url` | `String` | Yes | Fetch URL | 🟢 |
| `Remote.pushUrl` | `String` | Yes | Push URL or fetch URL fallback | 🟢 |
| `RemoteReference.name` | `String` | Yes | Advertised reference name | 🟢 |
| `RemoteReference.oid` | `Oid` | Yes | Advertised target | 🟢 |
| `RemoteReference.localId` | `Oid?` | No | Local OID when available | 🟢 |
| `RemoteReference.symRef` | `String` | Yes | Symbolic target, possibly empty | 🟢 |
| `TransferProgress.totalObjects` | `int` | Yes | Total objects expected | 🟢 |
| `TransferProgress.receivedObjects` | `int` | Yes | Objects downloaded | 🟢 |
| `TransferProgress.receivedBytes` | `int` | Yes | Bytes downloaded | 🟢 |

### Credentials and Callbacks

| Entity/field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `UserPass.username` / `password` | `String` | Yes | Plaintext credential material | 🟢 |
| `Keypair.username` | `String` | Yes | SSH user | 🟢 |
| `Keypair.pubKey` / `privateKey` | `String` | Yes | Filesystem key paths | 🟢 |
| `KeypairFromMemory.pubKey` / `privateKey` | `String` | Yes | In-memory SSH key material | 🟢 |
| `Callbacks.certificateCheck` | `CertificateCheck?` | No | Final remote certificate trust decision | 🟢 |
| `Callbacks.transferProgress` | `void Function(TransferProgress)?` | No | Transfer progress receiver | 🟢 |
| `Callbacks.updateTips` | `void Function(String, Oid, Oid)?` | No | Reference update notification | 🟢 |

### GitCertificateHostkey

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `typeFlags` | `int` | Yes | Availability bitmask | 🟢 |
| `md5` / `sha1` / `sha256` | `Uint8List?` | No | Available host key fingerprints | 🟢 |
| `rawType` | `GitCertificateSshRawType` | When raw key exists | SSH key algorithm | 🟢 |
| `rawHostkey` | `Uint8List?` | No | Raw host key bytes | 🟢 |

## History and Integration Operations

### RevSpec

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `from` | `Commit` | Yes | Left/start revision | 🟢 |
| `to` | `Commit?` | No | Right/end revision for range forms | 🟢 |
| `flags` | `Set<GitRevSpec>` | Yes | Parsed single/range/merge-base semantics | 🟢 |

### MergeAnalysis

| Field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `result` | `Set<GitMergeAnalysis>` | Yes | Applicable merge outcomes | 🟢 |
| `mergePreference` | `GitMergePreference` | Yes | Configured fast-forward preference | 🟢 |

### RebaseOperation

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `type` | `GitRebaseOperation` | Yes | Pick, reword, edit, squash, fixup, or exec | 🟢 |
| `oid` | `Oid` | Yes | Commit associated with the operation | 🟢 |

### BlameHunk

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `linesCount` | `int` | Yes | Number of lines in the hunk | 🟢 |
| `isBoundary` | `bool` | Yes | Whether history was truncated at a boundary | 🟢 |
| `finalStartLineNumber` | `int` | Yes | Line in final file | 🟢 |
| `finalCommitOid` | `Oid` | Yes | Final attribution commit | 🟢 |
| `originStartLineNumber` | `int` | Yes | Line in origin file | 🟢 |
| `originCommitOid` | `Oid` | Yes | Original attribution commit | 🟢 |
| `originPath` | `String` | Yes | Original path | 🟢 |

### Note

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `oid` | `Oid` | Yes | Note blob identifier | 🟢 |
| `annotatedOid` | `Oid` | Yes | Object receiving the note | 🟢 |
| `message` | `String` | Yes | Note content | 🟢 |
| `author` / `committer` | `Signature` | Yes | Note identities | 🟢 |

### Submodule

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `name` | `String` | Yes | Logical submodule name | 🟢 |
| `path` | `String` | Yes | Parent-relative path | 🟢 |
| `url` | `String` | Yes | Configured repository URL | 🟢 |
| `branch` | `String` | Yes | Tracking branch | 🟢 |
| `headOid` | `Oid?` | No | OID recorded in parent HEAD tree | 🟢 |
| `indexOid` | `Oid?` | No | OID recorded in parent index | 🟢 |
| `workdirOid` | `Oid?` | No | Checked-out nested HEAD | 🟢 |
| `location` | `Set<GitSubmoduleStatus>` | Yes | Places where submodule metadata/content exists | 🟢 |

## Native Runtime and Platform Boundary

### CachedMemory

| Field | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `current` | `int` | Yes | Current native object-cache bytes | 🟢 |
| `allowed` | `int` | Yes | Configured maximum cache bytes | 🟢 |

### Git2DartError

| Field/property | Type | Required | Meaning | Confidence |
| --- | --- | --- | --- | --- |
| `message` | `String` | Yes | Human-readable package error | 🟢 |
| `stackTrace` | `StackTrace?` | Yes | Stack captured when read | 🟢 |

### Native Pointer Ownership Categories

| Category | Dart representation | Release rule | Confidence |
| --- | --- | --- | --- |
| Persistent owned object | `Pointer<git_*>` inside wrapper | Matching `free()` or wrapper finalizer | 🟢 |
| Temporary output/input | Arena pointer | Automatically released when `using` exits | 🟢 |
| Temporary manual allocation | `calloc<T>()` | Explicit `calloc.free` after conversion | 🟢 |
| Native buffer | `git_buf` | `git_buf_dispose` before outer pointer release | 🟢 |
| Borrowed callback view | Certificate/progress/reference pointer | Valid only during callback/native owner lifetime | 🟢 |

### Global Runtime Options

| Option family | Dart type | Meaning | Confidence |
| --- | --- | --- | --- |
| `mmapWindowSize`, mapped/file limits | `int` | Memory-mapped I/O limits | 🟢 |
| cache object/max size and enablement | `int` / toggle | Native object cache policy | 🟢 |
| config search/template/SSL paths | `String` / `String?` | Global filesystem lookup paths | 🟢 |
| strict object/ref/hash/index safety | toggle | Validation and overwrite safety policy | 🟢 |
| pack max objects/object size/keep checks | `int` / toggle | Pack memory and retention policy | 🟢 |
| extensions | `List<String>` | Accepted Git repository extensions | 🟢 |
| owner validation | `bool` | Repository-directory ownership check | 🟢 |

### Git Enums and Flag Sets

`git_types.dart` contains the Dart domain vocabulary for reference/object kinds, file modes, status and delta bits, repository states, merge/checkout/diff options, credentials, submodules, filters, index behavior, and worktree pruning. Each value carries the integer expected by libgit2; combinable flags are represented as sets and folded with bitwise OR.

