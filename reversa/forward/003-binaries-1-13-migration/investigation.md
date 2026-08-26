# Investigation: Companion Binaries 1.13 Migration

## Evidence baseline

The companion package owns declarations and native artifacts; this repository
owns hand-written calls, allocation, errors, and platform startup
(`reversa/sdd/code-analysis.md#Feature 6: Native Runtime and Platform Boundary`).
Hosted 1.13.0 resolution/baseline is already present and is adopted work, not
evidence of a newly available 1.12.2 → 1.13.0 comparison.

Approved clarification resolves the audit: mmap window size, mapped limit, file
limit, and pack maximum objects use `Pointer<Size>`; cached-memory current and
allowed use `Pointer<IntPtr>`. Missing native detail is authorized to throw
`StateError`; all obsolete construction paths are owned.

## References

- [Dart FFI Size](https://api.dart.dev/stable/dart-ffi/Size-class.html)
- [Dart FFI native types](https://dart.dev/interop/c-interop)
- [Dart dependency versioning](https://dart.dev/tools/pub/dependencies)

## Alternatives

| Alternative | Decision | Reason |
|-------------|----------|--------|
| Blanket `Size` conversion | Rejected | Cached-memory is `intptr_t`, not `size_t`. |
| Recreate globals/errors | Rejected | Conflicts with delivered runtime surface. |
| Optional platform CI | Rejected | Clarification makes it mandatory. |

## Test notes

Use set/read/reset transactions for global options. Search and cover
`error_helper.dart`, `commit.dart`, `diff.dart`, and both relevant remote
callback paths. Local tests do not prove Android/iOS native loading or other
platform behavior; require full CI.

## Documentation scope

The initial scoped documentation search finds obsolete `LibGit2Error` wording
in `doc/types/` (for example refspec documentation). During implementation,
search only public Dart `///` comments, `doc/types/`, `README.md`, and an
existing API-reference root. Update a match only when it promises the removed
constructor/error contract; retain generic correct statements about native
errors. Validate with the same scoped search and `dart doc` or an equivalent
documentation build/check.
