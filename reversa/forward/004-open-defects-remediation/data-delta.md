# Data Delta: Open Defects Remediation

There is no persistent database or Git-object schema change. All deltas are
ephemeral native-memory lifecycle corrections.

| Bugs | Existing transient value | Delta |
|---|---|---|
| K2RY, X4AE, Q6JV | `git_buf` with libgit2-owned internal storage | Copy required Dart data, then dispose on all paths. |
| P5DB, QWMA | native option structures | Establish one owner; validate initializer before use; release owned allocation. |
| 3PON | `git_strarray` | Convert strings then call the matching native disposer. |
| 2TB4, Y7GX | native OID output | Copy into managed value or assign one explicit owner; free failed-call output. |
| N4FC, M2VF | lookup handles | Release exactly once after extracted Dart data or in `finally`. |
| CIKD | callback registrations | Replace process-global mutable dispatch state with isolated payload or serialized access. |
| L8WX | identity output pointers/status | Check status before reading outputs; release temporaries in guaranteed cleanup. |

Migration: n/a. Existing repository contents and public serialization stay
unchanged.
