# Data Delta: Companion Binaries 1.13 Migration

| Extracted model | Delta | Migration |
|-----------------|-------|-----------|
| Git objects, refs, index, config, working tree | None. | None. |
| Four `size_t` option outputs (mmap window size/mapped limit/file limit, pack maximum objects) | Transient `Pointer<Size>`. | Internal ABI adaptation; preserve a `2^32` value unchanged where accepted on a 64-bit target. |
| Cached-memory current/allowed | Transient `Pointer<IntPtr>`. | Internal ABI adaptation. |
| Native error detail | Delivered lookup, then authorized `StateError` fallback. | No persistent migration. |
| Companion artifacts | Existing hosted 1.13.0 input is adopted. | No generation or unavailable-history claim. |
| Process-global option coordination | No synchronization contract is added. | Restore altered values in validation; concurrent safety remains outside scope. |

No stored field, schema, index, serialization, or repository-data change occurs.
Public Dart integer APIs remain stable.

Documentation changes are contract-description corrections only; they introduce
no serialized or public API-shape delta.
