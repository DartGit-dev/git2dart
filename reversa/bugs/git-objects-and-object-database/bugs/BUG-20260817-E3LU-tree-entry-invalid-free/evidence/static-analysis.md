# Static Analysis Evidence

- `lib/src/bindings/tree.dart:83-136` distinguishes borrowed index/name/OID entries from caller-owned path entries.
- `lib/src/tree.dart:104-150` wraps all variants in `TreeEntry`.
- `lib/src/tree.dart:306-312` exposes an unconditional public `free` that calls the native destructor.
- The documentation warning does not prevent deterministic invalid free or later parent double-free.
