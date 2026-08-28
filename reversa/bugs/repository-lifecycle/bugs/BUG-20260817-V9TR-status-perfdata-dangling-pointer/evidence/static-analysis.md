# Static Analysis Evidence

- `lib/src/bindings/status.dart:134-141` allocates `git_diff_perfdata` from the local arena and returns that pointer from the `using` callback.
- Arena teardown occurs before `listPerfdata` returns, so every returned pointer is invalid.
