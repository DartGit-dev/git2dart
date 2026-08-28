# Data Delta: Strict Git Validation

## Conceptual diff

| Extracted model | Delta | Migration |
|-----------------|-------|-----------|
| Git object database objects (`Oid`, object type, bytes) | None. The accepted input domain for existing write/hash calls becomes an explicit finite allow-list. | None. |
| Git references and symbolic target strings | None. Existing strings gain deterministic pre-FFI syntax validation. | None. |
| Native repository/refdb/object storage | None. Valid inputs retain existing binding and libgit2 behavior. | None. |

## New in-memory rule

The feature adds no stored field, collection, file, schema, index, serialization
format, or data migration. It adds a private predicate over `GitObject` and a
private predicate over a caller-provided `String` before native marshalling.

## Compatibility note

Consumers who supplied invalid values can observe `ArgumentError` earlier than
the old native failure. Per `requirements.md#6`, this is an intentional defect
correction, not a data migration or compatibility mode.

