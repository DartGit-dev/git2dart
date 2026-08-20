# User Stories — Git Objects and Object Database

> 🟢 **CONFIRMED** — Stories express typed immutable-object and raw-storage outcomes.

## US-OBJ-01 — Resolve Object Identity

🟢 **CONFIRMED** — As a Dart developer, I want validated full and abbreviated OIDs so that object identity is typed and ambiguous/missing values fail explicitly.

## US-OBJ-02 — Create Immutable History

🟢 **CONFIRMED** — As a Git application, I want to create/amend commits with signatures, trees, and ordered parents so that new immutable history is faithful.

```gherkin
Dado a tree, signatures, and ordered parent commits from one repository
Quando a commit is created
Então a new Oid identifies the exact immutable commit and optional reference update
```

## US-OBJ-03 — Build Trees and Blobs

🟢 **CONFIRMED** — As a content tool, I want tree entry/update/builder and byte-safe blob/stream APIs so that I can construct snapshots without raw pointers or lossy binary conversion.

## US-OBJ-04 — Access Raw ODB Safely

🟢 **CONFIRMED** — As an advanced consumer, I want raw read/hash/write/enumeration with concrete object-type validation so that invalid pseudo-objects cannot be persisted.

## US-OBJ-05 — Manage Native Lifetime

🟢 **CONFIRMED** — As a maintainer, I want owned, borrowed, temporary, and transferred resources distinguished so that objects/streams release exactly once.

## Unresolved Persona Need

🔴 **GAP** — Full SHA-256 compatibility, borrowed-view lifetime, and stream/post-free terminal behavior require validation.

