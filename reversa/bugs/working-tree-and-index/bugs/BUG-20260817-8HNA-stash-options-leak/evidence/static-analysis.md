# Static Analysis Evidence

- `lib/src/bindings/checkout.dart:184` allocates `git_checkout_options` with `calloc`.
- `lib/src/bindings/checkout.dart:197` allocates a path pointer array with `calloc` when paths are supplied.
- The function documents both as requiring release, but `lib/src/bindings/stash.dart:102-113` and `:161-172` never free them.

The leak occurs on both successful and failed native operations.
