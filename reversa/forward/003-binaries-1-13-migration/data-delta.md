# Data Delta: Companion Binaries 1.13 Migration

| Extracted model | Delta | Migration |
|-----------------|-------|-----------|
| Git objects, refs, index, config, working tree | None. | None. |
| Four size-like option outputs | Transient `Pointer<Size>`. | Internal ABI adaptation. |
| Cached-memory current/allowed | Transient `Pointer<IntPtr>`. | Internal ABI adaptation. |
| Native error detail | Delivered lookup, then authorized `StateError` fallback. | No persistent migration. |
| Companion artifacts | Existing hosted 1.13.0 input is adopted. | No generation or unavailable-history claim. |

No stored field, schema, index, serialization, or repository-data change occurs.
Public Dart integer APIs remain stable.

Documentation changes are contract-description corrections only; they introduce
no serialized or public API-shape delta.
