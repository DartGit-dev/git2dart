# Static Evidence

- `lib/src/bindings/remote_callbacks.dart:292-297` allocates the credential attempt payload.
- `RemoteCallbacks.reset()` clears Dart fields but does not release the native payload.
- No matching free for that payload exists in remote, repository clone, or submodule call sites.
- Error strings at lines 186-201 use `toCharAlloc()` without an explicit matching release.
- `lib/src/bindings/credentials.dart:55-70` allocates an output slot and four SSH key strings without a matching release on success or error.
