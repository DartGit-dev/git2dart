# Static Evidence

- `lib/src/bindings/remote_callbacks.dart:24-174` declares process-static callback and credential fields.
- `RemoteCallbacks.plug()` replaces those fields for each operation.
- Native bridge functions dispatch exclusively through the shared fields.
- Connect, fetch, push, clone, and submodule operations use the same global bridge.
- No lock, serialization guard, operation token, or payload-local callback object is present.
