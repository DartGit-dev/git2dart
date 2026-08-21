# Git Objects and Object Database Requirements

> 🟢 **CONFIRMED** — This unit specifies immutable Git object identity, lookup, creation, transformation, raw object-database access, signatures, annotated commits, commit-graph helpers, and streaming blob writes.

## Overview and Responsibilities

- 🟢 **CONFIRMED** — Represent SHA-based object identifiers as typed `Oid` values with validation, prefix lookup, comparison, and shortening.
- 🟢 **CONFIRMED** — Represent commits, trees, blobs, tags, signatures, annotated commits, ODB objects, and streams as typed wrappers over libgit2.
- 🟢 **CONFIRMED** — Create new immutable objects and return new OIDs rather than mutating stored Git objects.
- 🟢 **CONFIRMED** — Preserve repository ownership relationships for commit trees, parents, object lookup, and graph operations.
- 🟢 **CONFIRMED** — Restrict raw ODB writes/hashes to concrete writable object kinds.
- 🟢 **CONFIRMED** — Pair persistent native objects with explicit/finalizer cleanup and release temporary memory at the binding boundary.

## Business Rules

| ID | Rule | Confidence | Evidence |
| --- | --- | --- | --- |
| BR-OBJ-01 | Git objects are immutable; create, amend, and tree-update operations produce a new OID/object. | 🟢 CONFIRMED | `lib/src/commit.dart`, `lib/src/tree.dart`, domain rule 3 |
| BR-OBJ-02 | A root commit has zero parents; non-root parent order is preserved. | 🟢 CONFIRMED | `lib/src/commit.dart:70-98` |
| BR-OBJ-03 | A commit tree and all parent commits must belong to the target repository. | 🟢 CONFIRMED | Commit public contract and native strict creation |
| BR-OBJ-04 | Commit amendment preserves every null replacement field from the existing commit and preserves its parent list. | 🟢 CONFIRMED | `lib/src/commit.dart:133-189` |
| BR-OBJ-05 | A `TreeUpdate` with null OID removes a path; non-null OID plus file mode upserts it. | 🟢 CONFIRMED | `lib/src/tree.dart:63-90` |
| BR-OBJ-06 | Tree/tag target conversion supports commit, tree, blob, and tag; unexpected types are rejected. | 🟢 CONFIRMED | `lib/src/tree.dart:278-296`, `lib/src/tag.dart:92-133` |
| BR-OBJ-07 | ODB write/hash rejects `any`, `invalid`, `ofsDelta`, and `refDelta` pseudo-types. | 🟢 CONFIRMED | `lib/src/odb.dart:140-147` |
| BR-OBJ-08 | Binary-safe content is exposed as bytes; text getters decode content for convenience. | 🟢 CONFIRMED | `lib/src/blob.dart`, `lib/src/odb.dart` |
| BR-OBJ-09 | Blob stream ownership may transfer to libgit2 when committed and must not be released twice. | 🟢 CONFIRMED | `lib/src/writestream.dart`, ADR-003 |
| BR-OBJ-10 | Full or sufficiently long hexadecimal prefixes may resolve an OID; ambiguous/unavailable prefixes fail. | 🟢 CONFIRMED | `lib/src/oid.dart`, OID tests |
| BR-OBJ-11 | Complete end-to-end SHA-256 repository support is not established. | 🔴 GAP | `domain.md`, `architecture.md` |

## Functional Requirements

| ID | Requirement | Priority | Acceptance summary | Confidence |
| --- | --- | --- | --- | --- |
| FR-OBJ-01 | Validate, parse, compare, copy, shorten, and resolve full/prefix OIDs. | Must | Valid identifiers round-trip; invalid, ambiguous, or unavailable values fail explicitly. | 🟢 CONFIRMED |
| FR-OBJ-02 | Lookup commits, trees, blobs, tags, annotated commits, and raw ODB objects by OID/prefix. | Must | A matching object returns the correct typed wrapper; missing/wrong-type lookup throws. | 🟢 CONFIRMED |
| FR-OBJ-03 | Create commits from signatures, message, tree, ordered parents, and optional update reference. | Must | The new OID identifies a commit with the supplied values and parent order. | 🟢 CONFIRMED |
| FR-OBJ-04 | Create a commit buffer without writing the commit to ODB. | Could | Returned bytes/text represent the commit serialization without a stored commit side effect. | 🟢 CONFIRMED |
| FR-OBJ-05 | Amend a commit by replacing only non-null fields. | Should | Unspecified fields and parents remain unchanged; a new OID is returned. | 🟢 CONFIRMED |
| FR-OBJ-06 | Read trees and entries by index, path, or name and convert entries to supported object types. | Must | Valid selectors return typed entries/objects; invalid selectors/types fail. | 🟢 CONFIRMED |
| FR-OBJ-07 | Create and update trees using builders and ordered `TreeUpdate` operations. | Must | Upsert/remove semantics produce a new immutable tree. | 🟢 CONFIRMED |
| FR-OBJ-08 | Create/read blobs from bytes, text, disk, workdir, and streaming writes. | Must | Content and size are preserved; stream commit returns the blob OID. | 🟢 CONFIRMED |
| FR-OBJ-09 | Create, lookup, list, peel, and delete lightweight/annotated tags under force rules. | Should | Target and tagger/message semantics are preserved; duplicate policy is enforced. | 🟢 CONFIRMED |
| FR-OBJ-10 | Read, hash, write, enumerate, and inspect raw ODB objects/backends. | Must | Concrete types round-trip bytes; pseudo-types are rejected before unsafe write/hash. | 🟢 CONFIRMED |
| FR-OBJ-11 | Create and project signatures with name, email, time, and offset. | Must | Identity/time values round-trip through native structures. | 🟢 CONFIRMED |
| FR-OBJ-12 | Provide commit-graph and annotated-commit helpers required by merge/history operations. | Should | Graph reachability/descendant and annotated identity results match libgit2. | 🟢 CONFIRMED |
| FR-OBJ-13 | Release every owned native object explicitly or by finalizer fallback. | Must | Manual release detaches fallback cleanup; borrowed views do not become independently owned. | 🟢 CONFIRMED |

## Non-Functional Requirements

| Type | Requirement | Evidence | Confidence |
| --- | --- | --- | --- |
| Integrity | Repository/object ownership and object-kind checks shall fail closed before invalid native composition. | Commit/tree/ODB contracts | 🟢 CONFIRMED |
| Binary safety | Raw blob/ODB content shall remain available as bytes without mandatory text decoding. | `Blob.contentBytes`, `OdbObject.dataBytes` | 🟢 CONFIRMED |
| Memory safety | Owned objects, streams, buffers, and temporary arrays shall follow explicit ownership/disposer rules. | ADR-003, binding patterns | 🟢 CONFIRMED |
| Error consistency | Native lookup/create/write failures shall use centralized translation; invalid local types/formats shall use Dart validation errors. | ADR-004, object wrappers | 🟢 CONFIRMED |
| Compatibility | OID/object behavior shall remain compatible with the constrained generated declarations/native ABI. | ADR-001 | 🟢 CONFIRMED |
| Hash-format support | No SHA-256 completeness claim shall be made without an operation matrix. | Architecture gap | 🔴 GAP |

## Acceptance Criteria

🟢 **CONFIRMED**

```gherkin
Dado valid signatures, a tree, and an ordered parent list from one repository
Quando a commit is created
Então the returned Oid resolves to a commit preserving message, tree, identities, and parent order
```

🟢 **CONFIRMED**

```gherkin
Dado a tree and ordered TreeUpdate values
Quando null-Oid removals and non-null upserts are applied
Então a new tree is returned with exactly the requested immutable changes
```

🟢 **CONFIRMED**

```gherkin
Dado raw object bytes and a concrete writable GitObject type
Quando the ODB hashes or writes the value
Então the resulting Oid identifies content of that type
```

🟢 **CONFIRMED**

```gherkin
Dado raw bytes and a pseudo or delta GitObject type
Quando an ODB write or hash is requested
Então ArgumentError is raised before an invalid stored object is created
```

🟢 **CONFIRMED**

```gherkin
Dado a blob write stream and binary content
Quando content is written and the stream is committed
Então the returned Oid resolves to a blob with identical bytes and ownership is released exactly once
```

🔴 **GAP**

```gherkin
Dado a SHA-256 repository
Quando full and abbreviated OIDs are used across every object operation
Então complete supported behavior requires fresh cross-operation validation
```

## MoSCoW

| Capability | Priority | Rationale | Confidence |
| --- | --- | --- | --- |
| OID, commit/tree/blob lookup and creation | Must | Foundation for nearly every repository feature. | 🟢 CONFIRMED |
| ODB integrity, object-kind dispatch, ownership | Must | Incorrect behavior risks corrupt objects or native memory. | 🟢 CONFIRMED |
| Tags, annotated commits, commit graph | Should | Required by common history/integration flows but not every consumer. | 🟡 INFERRED |
| Commit buffer and specialized shortening/stream helpers | Could | Useful specialized alternatives to primary creation APIs. | 🟡 INFERRED |
| Unverified full SHA-256 compatibility | Won't claim | Static evidence is insufficient. | 🔴 GAP |

## Traceability

| Legacy area | Coverage | Confidence |
| --- | --- | --- |
| `lib/src/oid.dart`, `test/oid_test.dart` | OID parsing, lookup, shortening, equality | 🟢 CONFIRMED |
| `lib/src/commit.dart`, `test/commit_test.dart` | Commit lookup/create/buffer/amend/parents | 🟢 CONFIRMED |
| `lib/src/tree.dart`, `lib/src/treebuilder.dart`, corresponding tests | Tree entries, traversal, update, builder | 🟢 CONFIRMED |
| `lib/src/blob.dart`, `lib/src/writestream.dart`, blob tests | Blob content and streaming | 🟢 CONFIRMED |
| `lib/src/tag.dart`, `test/tag_test.dart` | Tags and target conversion | 🟢 CONFIRMED |
| `lib/src/odb.dart`, ODB tests | Raw storage and object-kind validation | 🟢 CONFIRMED |
| `lib/src/signature.dart`, `lib/src/annotated.dart`, `lib/src/commit_graph.dart` | Supporting identity/graph types | 🟢 CONFIRMED |
| `lib/src/bindings/*` counterparts | Native calls, conversion, ownership | 🟢 CONFIRMED |
