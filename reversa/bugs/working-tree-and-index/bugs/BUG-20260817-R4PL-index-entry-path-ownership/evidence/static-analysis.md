# Static Analysis Evidence

- `lib/src/bindings/index.dart:160-164` states that entries returned by index lookup are not modifiable and must not be freed.
- `lib/src/index.dart:485-508` wraps that borrowed pointer and exposes setters, including a path setter that overwrites the native field.
- `toCharAlloc` creates a standalone allocation; no owner or finalizer is attached to it.
- `test/index_test.dart:120-132` exercises the mutation for value behavior but not lifetime or index invariants.
