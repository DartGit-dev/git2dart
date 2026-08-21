# Git Objects and Object Database — Edge Cases

> 🟢 **CONFIRMED** — Each case records the required result or an explicit validation gap.

| ID | Edge case | Expected behavior | Confidence |
| --- | --- | --- | --- |
| EC-OBJ-01 | OID text contains non-hex characters or unsupported length | Reject before unsafe native use. | 🟢 CONFIRMED |
| EC-OBJ-02 | OID prefix has no match | Throw lookup error; do not return null success. | 🟢 CONFIRMED |
| EC-OBJ-03 | OID prefix is ambiguous | Throw ambiguity error. | 🟢 CONFIRMED |
| EC-OBJ-04 | Requested shortened OID is not unique | Increase/return only a unique abbreviation under native rules. | 🟢 CONFIRMED |
| EC-OBJ-05 | SHA-256 OID is syntactically valid | Validation may succeed, but operation-wide support is not implied. | 🔴 GAP |
| EC-OBJ-06 | Commit has no parents | Create a root commit with parent count zero. | 🟢 CONFIRMED |
| EC-OBJ-07 | Commit has multiple parents | Preserve supplied parent order exactly. | 🟢 CONFIRMED |
| EC-OBJ-08 | Tree or parent belongs to another repository | Native strict creation rejects invalid composition. | 🟢 CONFIRMED |
| EC-OBJ-09 | Commit amendment field is null | Preserve the original field. | 🟢 CONFIRMED |
| EC-OBJ-10 | Commit message contains non-ASCII/line endings | Preserve native UTF-8 serialization behavior; exact normalization is not added by wrapper. | 🟡 INFERRED |
| EC-OBJ-11 | Commit lookup OID identifies another object kind | Type-specific lookup throws. | 🟢 CONFIRMED |
| EC-OBJ-12 | Tree indexed position is out of range | Fail according to wrapper/native lookup contract. | 🟢 CONFIRMED |
| EC-OBJ-13 | Tree selector contains a slash | Interpret as path lookup rather than simple filename. | 🟢 CONFIRMED |
| EC-OBJ-14 | TreeUpdate OID is null | Encode removal; file mode is not an upsert requirement. | 🟢 CONFIRMED |
| EC-OBJ-15 | TreeUpdate OID is non-null but mode is absent/invalid | Reject or surface native failure; do not silently create an invalid entry. | 🟢 CONFIRMED |
| EC-OBJ-16 | Two ordered updates touch the same path | Result follows native ordered-update behavior; exact duplicate policy needs focused proof. | 🟡 INFERRED |
| EC-OBJ-17 | Tree entry has unsupported pseudo object kind | Throw `ArgumentError` rather than produce an untyped wrapper. | 🟢 CONFIRMED |
| EC-OBJ-18 | Blob contains NUL or invalid UTF-8 bytes | `contentBytes` remains correct; text convenience may not be lossless. | 🟢 CONFIRMED |
| EC-OBJ-19 | Empty blob is created | Store zero-length content and return its canonical OID. | 🟢 CONFIRMED |
| EC-OBJ-20 | Disk/workdir blob path is missing | Translate native filesystem error. | 🟢 CONFIRMED |
| EC-OBJ-21 | Stream receives several writes before commit | Preserve byte order across writes. | 🟢 CONFIRMED |
| EC-OBJ-22 | Stream is committed twice or used after commit | Supported safe behavior is not established; prevent double ownership transfer. | 🔴 GAP |
| EC-OBJ-23 | Stream is abandoned | Finalizer/destructor is fallback cleanup. | 🟢 CONFIRMED |
| EC-OBJ-24 | Annotated tag name already exists with force false | Reject duplicate update. | 🟢 CONFIRMED |
| EC-OBJ-25 | Tag force is true | Replace/update according to native tag/reference semantics. | 🟢 CONFIRMED |
| EC-OBJ-26 | Tag target is commit/tree/blob/tag | Return the corresponding typed wrapper. | 🟢 CONFIRMED |
| EC-OBJ-27 | Tag target kind is unsupported | Throw explicit type error. | 🟢 CONFIRMED |
| EC-OBJ-28 | ODB write/hash receives `any`, `invalid`, `ofsDelta`, or `refDelta` | Reject locally with `ArgumentError`. | 🟢 CONFIRMED |
| EC-OBJ-29 | ODB read OID is absent | Throw native lookup error. | 🟢 CONFIRMED |
| EC-OBJ-30 | ODB prefix is ambiguous | Throw rather than select arbitrary content. | 🟢 CONFIRMED |
| EC-OBJ-31 | ODB foreach callback data is retained as raw pointer | Unsupported; copy/project before callback returns. | 🟢 CONFIRMED |
| EC-OBJ-32 | Backend index is invalid | Translate native range/backend failure. | 🟢 CONFIRMED |
| EC-OBJ-33 | Explicit object wrapper free is repeated | Idempotency is not established. | 🔴 GAP |
| EC-OBJ-34 | Borrowed tree entry outlives parent tree | Lifetime safety is not established unless data is copied. | 🔴 GAP |
| EC-OBJ-35 | Native failure occurs after a manual temporary allocation | Matching cleanup is required; exhaustive proof is absent. | 🔴 GAP |
| EC-OBJ-36 | Very large remote-declared object is unpacked | Process-global pack maximum may reject it to bound memory exposure. | 🟢 CONFIRMED |

## Required Characterization

- 🔴 **GAP** — SHA-1/SHA-256 full and prefix operations across every object type.
- 🔴 **GAP** — Stream commit/free/post-commit lifecycle under injected failures.
- 🔴 **GAP** — Borrowed entry lifetime and parent release ordering.
- 🔴 **GAP** — Native allocation/free balance for lookup, create, amend, update, tag, and ODB failures.

