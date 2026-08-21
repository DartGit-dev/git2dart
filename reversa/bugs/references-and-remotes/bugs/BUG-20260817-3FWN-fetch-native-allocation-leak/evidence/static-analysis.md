# Static Evidence

- `lib/src/bindings/remote.dart:482` allocates `git_strarray` with `calloc`.
- Line 484 allocates its pointer array with `calloc`.
- Line 496 allocates `git_fetch_options` with `calloc`.
- No matching free exists before either success return or error unwind.
- Git blame associates the calloc conversion with commit `02c6784`.
